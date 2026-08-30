// lib/features/reports/profit_report_screen.dart

import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/styles.dart';
import '../../database/app_database.dart';
import '../../database/daos/sales_dao.dart';
import '../../shared/pdf_report.dart';

class ProfitReportScreen extends StatelessWidget {
  const ProfitReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = getDatabase();
    final salesDao = SalesDao(db);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: FutureBuilder<double>(
        future: salesDao.getTotalProfit(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _ProfitLoadingState();
          }

          if (snapshot.hasError) {
            return _ProfitErrorState(error: snapshot.error.toString());
          }

          final totalProfit = snapshot.data ?? 0.0;

          return _buildContent(context, totalProfit);
        },
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final responsive = context.responsive;

    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: true,
      titleSpacing: responsive.horizontalPadding,
      toolbarHeight: responsive.controlHeight + AppSpacing.md,
      title: Row(
        children: [
          Container(
            width: AppSizes.iconButton,
            height: AppSizes.iconButton,
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Icon(Icons.trending_up, color: AppColors.success),
          ),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              'Profit Report',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.title.copyWith(
                fontSize: responsive.isCompact
                    ? AppTextStyles.title.fontSize
                    : AppTextStyles.heading.fontSize,
              ),
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.divider),
      ),
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent(BuildContext context, double totalProfit) {
    final responsive = context.responsive;
    final status = _getProfitStatus(totalProfit);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: responsive.horizontalPadding,
        vertical: responsive.verticalPadding,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: responsive.contentMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPageHeader(context, status),

              const SizedBox(height: AppSpacing.xxl),

              _buildMainProfitCard(context, totalProfit, status),

              const SizedBox(height: AppSpacing.xxl),

              _buildSummaryCards(context, totalProfit, status),

              const SizedBox(height: AppSpacing.xxxl),

              _buildProfitSummarySection(context, totalProfit, status),

              const SizedBox(height: AppSpacing.xxl),

              _buildReportInformation(context),

              const SizedBox(height: AppSpacing.xxxl),

              _buildExportSection(context, totalProfit, status),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PAGE HEADER
  // ============================================================

  Widget _buildPageHeader(BuildContext context, _ProfitStatus status) {
    final responsive = context.responsive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profit overview',
          style: responsive.isCompact
              ? AppTextStyles.heading
              : AppTextStyles.dashboardTitle,
        ),

        const SizedBox(height: AppSpacing.xs),

        const Text(
          'Review the total profit calculated from recorded sales.',
          style: AppTextStyles.bodySecondary,
        ),

        const SizedBox(height: AppSpacing.sm),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Icon(
                status.icon,
                size: AppSpacing.lg,
                color: status.color,
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            Expanded(
              child: Text(
                status.description,
                style: AppTextStyles.small.copyWith(
                  color: status.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // MAIN PROFIT CARD
  // ============================================================

  Widget _buildMainProfitCard(
    BuildContext context,
    double totalProfit,
    _ProfitStatus status,
  ) {
    final responsive = context.responsive;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        responsive.isCompact ? AppSpacing.lg : AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: AppSpacing.lg,
            offset: Offset(0, AppSpacing.sm),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: AppSizes.iconButton,
                height: AppSizes.iconButton,
                decoration: BoxDecoration(
                  color: status.lightColor,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Icon(
                  status.icon,
                  color: status.color,
                  size: AppSpacing.xl,
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total business profit',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.title,
                    ),

                    SizedBox(height: AppSpacing.xs),

                    Text(
                      'Calculated from recorded sales',
                      style: AppTextStyles.small,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(
            height: responsive.isCompact ? AppSpacing.xl : AppSpacing.xxl,
          ),

          Text(
            _formatCurrency(totalProfit),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.price.copyWith(
              fontSize: responsive.isCompact
                  ? AppTextStyles.price.fontSize
                  : AppTextStyles.dashboardCardValue.fontSize,
              color: status.color,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: status.lightColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(status.icon, size: AppSpacing.lg, color: status.color),

                const SizedBox(width: AppSpacing.xs),

                Flexible(
                  child: Text(
                    status.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.small.copyWith(
                      color: status.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY CARDS
  // ============================================================

  Widget _buildSummaryCards(
    BuildContext context,
    double totalProfit,
    _ProfitStatus status,
  ) {
    final responsive = context.responsive;

    final cards = [
      _SummaryCardData(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Total Profit',
        value: _formatCurrency(totalProfit),
        color: status.color,
        lightColor: status.lightColor,
      ),
      const _SummaryCardData(
        icon: Icons.receipt_long_outlined,
        title: 'Report Type',
        value: 'All Sales',
        color: AppColors.primary,
        lightColor: AppColors.primaryLight,
      ),
      _SummaryCardData(
        icon: status.icon,
        title: 'Status',
        value: status.label,
        color: status.color,
        lightColor: status.lightColor,
      ),
    ];

    if (responsive.isCompact) {
      return Column(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            _buildSummaryCard(context, cards[i]),
            if (i < cards.length - 1) const SizedBox(height: AppSpacing.md),
          ],
        ],
      );
    }

    if (responsive.isTablet) {
      return Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
        children: [
          for (final card in cards)
            SizedBox(
              width:
                  (responsive.width -
                      (responsive.horizontalPadding * 2) -
                      AppSpacing.md) /
                  2,
              child: _buildSummaryCard(context, card),
            ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < cards.length; i++) ...[
          Expanded(child: _buildSummaryCard(context, cards[i])),
          if (i < cards.length - 1) const SizedBox(width: AppSpacing.md),
        ],
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, _SummaryCardData data) {
    return Container(
      constraints: const BoxConstraints(minHeight: AppSizes.cardMinHeight),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: AppSpacing.xxxl,
            height: AppSpacing.xxxl,
            decoration: BoxDecoration(
              color: data.lightColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(data.icon, color: data.color, size: AppSpacing.xl),
          ),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.small,
                ),

                const SizedBox(height: AppSpacing.xs),

                Text(
                  data.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title.copyWith(
                    fontSize: AppTextStyles.body.fontSize,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROFIT SUMMARY
  // ============================================================

  Widget _buildProfitSummarySection(
    BuildContext context,
    double totalProfit,
    _ProfitStatus status,
  ) {
    return _SectionCard(
      title: 'Profit summary',
      icon: Icons.summarize_outlined,
      child: Column(
        children: [
          _SummaryRow(
            label: 'Total Profit',
            value: _formatCurrency(totalProfit),
            valueColor: status.color,
            bold: true,
          ),

          const Divider(height: AppSpacing.xxl),

          _SummaryRow(
            label: 'Profit Status',
            value: status.label,
            valueColor: status.color,
            icon: status.icon,
          ),

          const Divider(height: AppSpacing.xxl),

          const _SummaryRow(
            label: 'Calculation',
            value: 'Based on recorded sales',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REPORT INFORMATION
  // ============================================================

  Widget _buildReportInformation(BuildContext context) {
    return _SectionCard(
      title: 'Report information',
      icon: Icons.info_outline,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: AppSpacing.xl,
              color: AppColors.warning,
            ),

            SizedBox(width: AppSpacing.md),

            Expanded(
              child: Text(
                'This report currently uses the total profit '
                'calculated from recorded sales. Detailed revenue, '
                'cost, margin, daily profit, and category analysis '
                'can be added when those values are available '
                'from the sales database.',
                style: AppTextStyles.small,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EXPORT
  // ============================================================

  Widget _buildExportSection(
    BuildContext context,
    double totalProfit,
    _ProfitStatus status,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: AppSpacing.lg,
            offset: Offset(0, AppSpacing.sm),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final responsive = context.responsive;

          if (responsive.isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildExportContent(),

                const SizedBox(height: AppSpacing.lg),

                SizedBox(
                  width: double.infinity,
                  child: _buildExportButton(context, totalProfit, status),
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _buildExportContent()),

              const SizedBox(width: AppSpacing.xl),

              _buildExportButton(context, totalProfit, status),
            ],
          );
        },
      ),
    );
  }

  Widget _buildExportContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.picture_as_pdf_outlined,
          color: Colors.white,
          size: AppSpacing.xxxl,
        ),

        const SizedBox(width: AppSpacing.md),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Export profit report',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontSize: AppTextStyles.title.fontSize,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: AppSpacing.xs),

              Text(
                'Generate a PDF containing the current '
                'profit summary.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white70,
                  fontSize: AppTextStyles.small.fontSize,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExportButton(
    BuildContext context,
    double totalProfit,
    _ProfitStatus status,
  ) {
    return SizedBox(
      height: AppSizes.buttonHeight,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        icon: const Icon(Icons.download_outlined, size: AppSpacing.xl),
        label: const Text(
          'Export PDF',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        onPressed: () {
          _exportReport(context, totalProfit, status);
        },
      ),
    );
  }

  // ============================================================
  // PDF EXPORT
  // ============================================================

  Future<void> _exportReport(
    BuildContext context,
    double totalProfit,
    _ProfitStatus status,
  ) async {
    try {
      final file = await PdfReport.generateReport(
        title: 'Profit Report',
        sections: [
          {
            'title': 'Profit Summary',
            'headers': ['Metric', 'Value'],
            'rows': [
              ['Total Profit', _formatCurrency(totalProfit)],
              ['Profit Status', status.label],
              ['Calculation', 'Based on recorded sales'],
            ],
          },
        ],
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
          content: Text(
            'PDF saved at ${file.path}',
            style: const TextStyle(fontFamily: 'Poppins', color: Colors.white),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
          content: Text(
            'Unable to generate PDF: $e',
            style: const TextStyle(fontFamily: 'Poppins', color: Colors.white),
          ),
        ),
      );
    }
  }

  // ============================================================
  // PROFIT STATUS
  // ============================================================

  static _ProfitStatus _getProfitStatus(double profit) {
    if (profit > 0) {
      return const _ProfitStatus(
        label: 'Profitable',
        description: 'Business is currently generating profit',
        icon: Icons.trending_up,
        color: AppColors.success,
        lightColor: AppColors.successLight,
      );
    }

    if (profit < 0) {
      return const _ProfitStatus(
        label: 'Operating at a Loss',
        description: 'Recorded sales are currently below costs',
        icon: Icons.trending_down,
        color: AppColors.danger,
        lightColor: AppColors.dangerLight,
      );
    }

    return const _ProfitStatus(
      label: 'Break-even',
      description: 'No profit or loss has been recorded',
      icon: Icons.remove,
      color: AppColors.textMuted,
      lightColor: AppColors.surfaceSoft,
    );
  }

  // ============================================================
  // CURRENCY FORMATTER
  // ============================================================

  static String _formatCurrency(double value) {
    final absoluteValue = value.abs();
    final formatted = absoluteValue.toStringAsFixed(2);

    return value < 0 ? '-₦$formatted' : '₦$formatted';
  }
}

// ================================================================
// PROFIT STATUS
// ================================================================

class _ProfitStatus {
  final String label;
  final String description;
  final IconData icon;
  final Color color;
  final Color lightColor;

  const _ProfitStatus({
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
    required this.lightColor,
  });
}

// ================================================================
// SUMMARY CARD DATA
// ================================================================

class _SummaryCardData {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final Color lightColor;

  const _SummaryCardData({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.lightColor,
  });
}

// ================================================================
// SECTION CARD
// ================================================================

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: AppSpacing.xl, color: AppColors.primary),

              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title.copyWith(
                    fontSize: AppTextStyles.body.fontSize,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          child,
        ],
      ),
    );
  }
}

// ================================================================
// SUMMARY ROW
// ================================================================

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final IconData? icon;
  final bool bold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.icon,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.small.copyWith(
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),

        if (icon != null) ...[
          Icon(
            icon,
            size: AppSpacing.lg,
            color: valueColor ?? AppColors.textMuted,
          ),

          const SizedBox(width: AppSpacing.xs),
        ],

        Flexible(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: AppTextStyles.small.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ================================================================
// LOADING STATE
// ================================================================

class _ProfitLoadingState extends StatelessWidget {
  const _ProfitLoadingState();

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(responsive.horizontalPadding),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             CircularProgressIndicator(color: AppColors.primary),

             SizedBox(height: AppSpacing.lg),

             Text(
              'Loading profit report...',
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// ERROR STATE
// ================================================================

class _ProfitErrorState extends StatelessWidget {
  final String error;

  const _ProfitErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(responsive.horizontalPadding),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSizes.maxFormWidth + AppSpacing.xxxl,
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(
              responsive.isCompact ? AppSpacing.xl : AppSpacing.xxxl,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: AppSizes.iconButton,
                  height: AppSizes.iconButton,
                  decoration: BoxDecoration(
                    color: AppColors.dangerLight,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: AppColors.danger,
                    size: AppSpacing.xxl,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                const Text(
                  'Unable to load profit report',
                  style: AppTextStyles.title,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.sm),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: SelectableText(
                    error,
                    style: AppTextStyles.small,
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
