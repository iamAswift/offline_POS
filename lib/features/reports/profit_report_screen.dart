// lib/features/reports/profit_report_screen.dart

import 'package:flutter/material.dart';

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
      appBar: _buildAppBar(),
      body: FutureBuilder<double>(
        future: salesDao.getTotalProfit(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _ProfitLoadingState();
          }

          if (snapshot.hasError) {
            return _ProfitErrorState(
              error: snapshot.error.toString(),
            );
          }

          final totalProfit = snapshot.data ?? 0.0;

          return _buildContent(
            context,
            totalProfit,
          );
        },
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: true,
      titleSpacing: 20,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.trending_up,
              color: AppColors.success,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            "Profit Report",
            style: AppTextStyles.title,
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppColors.divider,
        ),
      ),
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent(
    BuildContext context,
    double totalProfit,
  ) {
    final status = _getProfitStatus(totalProfit);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 32 : 16,
            vertical: 24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1200,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPageHeader(
                    totalProfit,
                    status,
                  ),

                  const SizedBox(height: 24),

                  _buildMainProfitCard(
                    totalProfit,
                    status,
                  ),

                  const SizedBox(height: 24),

                  _buildSummaryCards(
                    totalProfit,
                    status,
                    isWide,
                  ),

                  const SizedBox(height: 28),

                  _buildProfitSummarySection(
                    totalProfit,
                    status,
                  ),

                  const SizedBox(height: 24),

                  _buildReportInformation(),

                  const SizedBox(height: 28),

                  _buildExportSection(
                    context,
                    totalProfit,
                    status,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // PAGE HEADER
  // ============================================================

  Widget _buildPageHeader(
    double totalProfit,
    _ProfitStatus status,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Profit overview",
          style: AppTextStyles.heading,
        ),
        const SizedBox(height: 6),
        const Text(
          "Review the total profit calculated from recorded sales.",
          style: AppTextStyles.bodySecondary,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(
              status.icon,
              size: 15,
              color: status.color,
            ),
            const SizedBox(width: 6),
            Text(
              status.description,
              style: AppTextStyles.small.copyWith(
                color: status.color,
                fontWeight: FontWeight.w600,
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
    double totalProfit,
    _ProfitStatus status,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: status.lightColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  status.icon,
                  color: status.color,
                  size: 25,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total business profit",
                      style: AppTextStyles.title,
                    ),
                    SizedBox(height: 3),
                    Text(
                      "Calculated from recorded sales",
                      style: AppTextStyles.small,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Text(
            _formatCurrency(totalProfit),
            style: AppTextStyles.price.copyWith(
              fontSize: 34,
              color: status.color,
            ),
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: status.lightColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  status.icon,
                  size: 16,
                  color: status.color,
                ),
                const SizedBox(width: 6),
                Text(
                  status.label,
                  style: AppTextStyles.small.copyWith(
                    color: status.color,
                    fontWeight: FontWeight.w700,
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
    double totalProfit,
    _ProfitStatus status,
    bool isWide,
  ) {
    final cards = [
      _SummaryCardData(
        icon: Icons.account_balance_wallet_outlined,
        title: "Total Profit",
        value: _formatCurrency(totalProfit),
        color: status.color,
        lightColor: status.lightColor,
      ),
      const _SummaryCardData(
        icon: Icons.receipt_long_outlined,
        title: "Report Type",
        value: "All Sales",
        color: AppColors.primary,
        lightColor: AppColors.primaryLight,
      ),
      _SummaryCardData(
        icon: status.icon,
        title: "Status",
        value: status.label,
        color: status.color,
        lightColor: status.lightColor,
      ),
    ];

    if (!isWide) {
      return Column(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            _buildSummaryCard(cards[i]),
            if (i < cards.length - 1)
              const SizedBox(height: 12),
          ],
        ],
      );
    }

    return Row(
      children: [
        for (int i = 0; i < cards.length; i++) ...[
          Expanded(
            child: _buildSummaryCard(cards[i]),
          ),
          if (i < cards.length - 1)
            const SizedBox(width: 14),
        ],
      ],
    );
  }

  Widget _buildSummaryCard(
    _SummaryCardData data,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: data.lightColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              data.icon,
              color: data.color,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: AppTextStyles.small,
                ),
                const SizedBox(height: 4),
                Text(
                  data.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title.copyWith(
                    fontSize: 15,
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
    double totalProfit,
    _ProfitStatus status,
  ) {
    return _SectionCard(
      title: "Profit summary",
      icon: Icons.summarize_outlined,
      child: Column(
        children: [
          _SummaryRow(
            label: "Total Profit",
            value: _formatCurrency(totalProfit),
            valueColor: status.color,
            bold: true,
          ),

          const Divider(height: 24),

          _SummaryRow(
            label: "Profit Status",
            value: status.label,
            valueColor: status.color,
            icon: status.icon,
          ),

          const Divider(height: 24),

          const _SummaryRow(
            label: "Calculation",
            value: "Based on recorded sales",
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REPORT INFORMATION
  // ============================================================

  Widget _buildReportInformation() {
    return _SectionCard(
      title: "Report information",
      icon: Icons.info_outline,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 20,
              color: AppColors.warning,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "This report currently uses the total profit "
                "calculated from recorded sales. Detailed revenue, "
                "cost, margin, daily profit, and category analysis "
                "can be added when those values are available "
                "from the sales database.",
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 600;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildExportContent(),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: _buildExportButton(
                    context,
                    totalProfit,
                    status,
                  ),
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: _buildExportContent(),
              ),
              const SizedBox(width: 20),
              _buildExportButton(
                context,
                totalProfit,
                status,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildExportContent() {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.picture_as_pdf_outlined,
          color: Colors.white,
          size: 30,
        ),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Export profit report",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Generate a PDF containing the current "
                "profit summary.",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white70,
                  fontSize: 12,
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
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      icon: const Icon(
        Icons.download_outlined,
        size: 19,
      ),
      label: const Text(
        "Export PDF",
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
      ),
      onPressed: () {
        _exportReport(
          context,
          totalProfit,
          status,
        );
      },
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
        title: "Profit Report",
        sections: [
          {
            "title": "Profit Summary",
            "headers": [
              "Metric",
              "Value",
            ],
            "rows": [
              [
                "Total Profit",
                _formatCurrency(totalProfit),
              ],
              [
                "Profit Status",
                status.label,
              ],
              [
                "Calculation",
                "Based on recorded sales",
              ],
            ],
          },
        ],
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
          content: Text(
            "PDF saved at ${file.path}",
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
            ),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
          content: Text(
            "Unable to generate PDF: $e",
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }

  // ============================================================
  // PROFIT STATUS
  // ============================================================

  static _ProfitStatus _getProfitStatus(
    double profit,
  ) {
    if (profit > 0) {
      return const _ProfitStatus(
        label: "Profitable",
        description: "Business is currently generating profit",
        icon: Icons.trending_up,
        color: AppColors.success,
        lightColor: AppColors.successLight,
      );
    }

    if (profit < 0) {
      return const _ProfitStatus(
        label: "Operating at a Loss",
        description: "Recorded sales are currently below costs",
        icon: Icons.trending_down,
        color: AppColors.danger,
        lightColor: AppColors.dangerLight,
      );
    }

    return const _ProfitStatus(
      label: "Break-even",
      description: "No profit or loss has been recorded",
      icon: Icons.remove,
      color: AppColors.textMuted,
      lightColor: AppColors.surfaceSoft,
    );
  }

  // ============================================================
  // CURRENCY FORMATTER
  // ============================================================

  static String _formatCurrency(
    double value,
  ) {
    final absoluteValue = value.abs();

    final formatted = absoluteValue.toStringAsFixed(2);

    return value < 0
        ? "-₦$formatted"
        : "₦$formatted";
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.title.copyWith(
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
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
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.small.copyWith(
              fontWeight: bold
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
        ),
        if (icon != null) ...[
          Icon(
            icon,
            size: 16,
            color: valueColor ?? AppColors.textMuted,
          ),
          const SizedBox(width: 6),
        ],
        Text(
          value,
          style: AppTextStyles.small.copyWith(
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: bold
                ? FontWeight.w800
                : FontWeight.w600,
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
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppColors.primary,
            ),
            SizedBox(height: 16),
            Text(
              "Loading profit report...",
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

  const _ProfitErrorState({
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 600,
          ),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.dangerLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: AppColors.danger,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Unable to load profit report",
                style: AppTextStyles.title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.border,
                  ),
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
    );
  }
}