// lib/features/reports/stock_value_report_screen.dart

import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/styles.dart';
import '../../database/app_database.dart';
import '../../database/daos/sales_dao.dart';
import '../../shared/pdf_report.dart';

class StockValueReportScreen extends StatefulWidget {
  const StockValueReportScreen({super.key});

  @override
  State<StockValueReportScreen> createState() =>
      _StockValueReportScreenState();
}

class _StockValueReportScreenState
    extends State<StockValueReportScreen> {
  late final SalesDao salesDao;

  double _totalStockValue = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    final db = getDatabase();
    salesDao = SalesDao(db);

    _loadReport();
  }

  // ============================================================
  // LOAD REPORT
  // ============================================================

  Future<void> _loadReport() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final value = await salesDao.getTotalStockValue();

      if (!mounted) return;

      setState(() {
        _totalStockValue = _toDouble(value);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar() {
    final responsive = context.responsive;

    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: true,
      titleSpacing: responsive.isCompact
          ? AppSpacing.lg
          : AppSpacing.xl,
      title: Row(
        children: [
          Container(
            width: responsive.isCompact ? 38 : 40,
            height: responsive.isCompact ? 38 : 40,
            decoration: BoxDecoration(
              color: AppColors.inventory.withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(
                AppRadius.lg,
              ),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: AppColors.inventory,
              size: responsive.isCompact ? 21 : 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const Text(
            'Stock Value Report',
            style: AppTextStyles.title,
          ),
        ],
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(
            right: responsive.isCompact
                ? AppSpacing.sm
                : AppSpacing.lg,
          ),
          child: IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _loadReport,
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
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
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (_isLoading) {
      return const _StockValueLoadingState();
    }

    if (_error != null) {
      return _StockValueErrorState(
        error: _error!,
        onRetry: _loadReport,
      );
    }

    final responsive = context.responsive;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadReport,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: responsive.horizontalPadding,
          vertical: responsive.verticalPadding,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: responsive.contentMaxWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPageHeader(),

                const SizedBox(
                  height: AppSpacing.xxl,
                ),

                _buildOverviewSection(
                  totalStockValue: _totalStockValue,
                ),

                const SizedBox(
                  height: AppSpacing.xxxl,
                ),

                _buildInformationSection(
                  totalStockValue: _totalStockValue,
                ),

                const SizedBox(
                  height: AppSpacing.xxxl,
                ),

                _buildExportSection(
                  totalStockValue: _totalStockValue,
                ),

                const SizedBox(
                  height: AppSpacing.xxl,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PAGE HEADER
  // ============================================================

  Widget _buildPageHeader() {
    final responsive = context.responsive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Inventory valuation',
          style: responsive.isCompact
              ? AppTextStyles.title.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                )
              : AppTextStyles.heading,
        ),
        const SizedBox(height: AppSpacing.xs + 2),
        const Text(
          'View the current value of all inventory in your business.',
          style: AppTextStyles.bodySecondary,
        ),
        const SizedBox(height: AppSpacing.sm + 2),
        const Row(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 14,
              color: AppColors.textMuted,
            ),
            SizedBox(width: AppSpacing.sm - 2),
            Text(
              'Current inventory',
              style: AppTextStyles.small,
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // OVERVIEW
  // ============================================================

  Widget _buildOverviewSection({
    required double totalStockValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: AppTextStyles.title,
        ),
        const SizedBox(
          height: AppSpacing.md,
        ),
        _buildStockValueCard(
          totalStockValue: totalStockValue,
        ),
      ],
    );
  }

  // ============================================================
  // STOCK VALUE CARD
  // ============================================================

  Widget _buildStockValueCard({
    required double totalStockValue,
  }) {
    final responsive = context.responsive;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        responsive.isCompact
            ? AppSpacing.lg
            : AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.xl,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 600;

          if (compact) {
            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _buildStockValueIcon(),
                const SizedBox(
                  height: AppSpacing.lg,
                ),
                _buildStockValueContent(
                  totalStockValue,
                ),
                const SizedBox(
                  height: AppSpacing.lg,
                ),
                _buildStatusBadge(),
              ],
            );
          }

          return Row(
            children: [
              _buildStockValueIcon(),
              const SizedBox(
                width: AppSpacing.lg,
              ),
              Expanded(
                child: _buildStockValueContent(
                  totalStockValue,
                ),
              ),
              const SizedBox(
                width: AppSpacing.xl,
              ),
              _buildStatusBadge(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStockValueIcon() {
    final responsive = context.responsive;

    final size = responsive.isCompact ? 54.0 : 58.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.inventory.withValues(
          alpha: 0.10,
        ),
        borderRadius: BorderRadius.circular(
          AppRadius.lg,
        ),
      ),
      child: Icon(
        Icons.inventory_2_outlined,
        color: AppColors.inventory,
        size: responsive.isCompact ? 26 : 28,
      ),
    );
  }

  Widget _buildStockValueContent(
    double totalStockValue,
  ) {
    final responsive = context.responsive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Total Stock Value',
          style: AppTextStyles.bodySecondary,
        ),
        const SizedBox(
          height: AppSpacing.xs + 2,
        ),
        Text(
          _formatCurrency(totalStockValue),
          style: AppTextStyles.price.copyWith(
            fontSize: responsive.isCompact ? 24 : 28,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(
          height: AppSpacing.xs,
        ),
        const Text(
          'Current estimated value of inventory',
          style: AppTextStyles.small,
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md - 1,
        vertical: AppSpacing.sm - 1,
      ),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(
          AppRadius.md,
        ),
        border: Border.all(
          color: AppColors.success.withValues(
            alpha: 0.20,
          ),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 15,
            color: AppColors.success,
          ),
          SizedBox(width: AppSpacing.xs + 2),
          Text(
            'Inventory tracked',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFORMATION SECTION
  // ============================================================

  Widget _buildInformationSection({
    required double totalStockValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stock valuation',
          style: AppTextStyles.title,
        ),
        const SizedBox(
          height: AppSpacing.md,
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(
            AppSpacing.lg + 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(
              AppRadius.lg,
            ),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            children: [
              _informationRow(
                icon: Icons.inventory_2_outlined,
                title: 'Current stock value',
                value: _formatCurrency(
                  totalStockValue,
                ),
                color: AppColors.inventory,
              ),
              const Divider(
                height: AppSpacing.xxl,
                color: AppColors.divider,
              ),
              _informationRow(
                icon: Icons.assessment_outlined,
                title: 'Valuation status',
                value: 'Up to date',
                color: AppColors.success,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _informationRow({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final responsive = context.responsive;

    return Row(
      children: [
        Container(
          width: responsive.isCompact ? 36 : 38,
          height: responsive.isCompact ? 36 : 38,
          decoration: BoxDecoration(
            color: color.withValues(
              alpha: 0.10,
            ),
            borderRadius: BorderRadius.circular(
              AppRadius.md + 1,
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: responsive.isCompact ? 18 : 19,
          ),
        ),
        const SizedBox(
          width: AppSpacing.md,
        ),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.bodySecondary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(
          width: AppSpacing.md,
        ),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.bodySecondary.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EXPORT
  // ============================================================

  Widget _buildExportSection({
    required double totalStockValue,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          AppRadius.xl,
        ),
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
          final compact = constraints.maxWidth < 650;

          if (compact) {
            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _exportContent(),
                const SizedBox(
                  height: AppSpacing.lg,
                ),
                _exportButton(
                  totalStockValue: totalStockValue,
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: _exportContent(),
              ),
              const SizedBox(
                width: AppSpacing.xl,
              ),
              _exportButton(
                totalStockValue: totalStockValue,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _exportContent() {
    return const Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.picture_as_pdf_outlined,
          color: Colors.white,
          size: 30,
        ),
        SizedBox(
          width: AppSpacing.md + 2,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Export stock valuation',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                height: AppSpacing.xs + 1,
              ),
              Text(
                'Generate a PDF containing the current inventory valuation.',
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

  Widget _exportButton({
    required double totalStockValue,
  }) {
    final responsive = context.responsive;

    return SizedBox(
      height: responsive.buttonHeight,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg + 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppRadius.md + 2,
            ),
          ),
        ),
        icon: const Icon(
          Icons.download_outlined,
          size: 19,
        ),
        label: const Text(
          'Export PDF',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: () => _exportPdf(
          totalStockValue: totalStockValue,
        ),
      ),
    );
  }

  // ============================================================
  // PDF EXPORT
  // ============================================================

  Future<void> _exportPdf({
    required double totalStockValue,
  }) async {
    try {
      final file = await PdfReport.generateReport(
        title: 'Stock Value Report',
        sections: [
          {
            'title': 'Stock Value Summary',
            'headers': [
              'Metric',
              'Value',
            ],
            'rows': [
              [
                'Total Stock Value',
                _formatCurrency(
                  totalStockValue,
                ),
              ],
            ],
          },
        ],
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
          content: Text(
            'PDF saved at ${file.path}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
          content: Text(
            'Unable to generate PDF: $e',
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
  // FORMATTING
  // ============================================================

  String _formatCurrency(double value) {
    return '₦${_formatNumber(value.round())}';
  }

  String _formatNumber(num value) {
    final number = value.toInt();
    final string = number.toString();

    final buffer = StringBuffer();

    for (int i = 0; i < string.length; i++) {
      if (i > 0 &&
          (string.length - i) % 3 == 0) {
        buffer.write(',');
      }

      buffer.write(string[i]);
    }

    return buffer.toString();
  }

  double _toDouble(dynamic value) {
    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}

// ============================================================
// LOADING STATE
// ============================================================

class _StockValueLoadingState
    extends StatelessWidget {
  const _StockValueLoadingState();

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(
          responsive.isCompact
              ? AppSpacing.xxxl
              : AppSpacing.huge,
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppColors.primary,
            ),
            SizedBox(
              height: AppSpacing.lg,
            ),
            Text(
              'Loading stock valuation...',
              style:
                  AppTextStyles.bodySecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ERROR STATE
// ============================================================

class _StockValueErrorState
    extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _StockValueErrorState({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(
          responsive.isCompact
              ? AppSpacing.xl
              : AppSpacing.xxxl,
        ),
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 600,
          ),
          padding: EdgeInsets.all(
            responsive.isCompact
                ? AppSpacing.xl
                : AppSpacing.xxxl,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(
              AppRadius.xl,
            ),
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
                  borderRadius:
                      BorderRadius.circular(
                    AppRadius.lg + 2,
                  ),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: AppColors.danger,
                  size: 30,
                ),
              ),
              const SizedBox(
                height: AppSpacing.lg,
              ),
              const Text(
                'Unable to load stock value',
                style: AppTextStyles.title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: AppSpacing.sm + 2,
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(
                  AppSpacing.md + 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius:
                      BorderRadius.circular(
                    AppRadius.md + 2,
                  ),
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
              const SizedBox(
                height: AppSpacing.xl,
              ),
              SizedBox(
                height: responsive.buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal:
                          AppSpacing.xl,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        AppRadius.md + 2,
                      ),
                    ),
                  ),
                  icon: const Icon(
                    Icons.refresh,
                    size: 18,
                  ),
                  label: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}