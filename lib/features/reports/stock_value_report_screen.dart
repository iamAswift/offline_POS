// lib/features/reports/stock_value_report_screen.dart

import 'package:flutter/material.dart';

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

class _StockValueReportScreenState extends State<StockValueReportScreen> {
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
              color: AppColors.inventory.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.inventory,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Stock Value Report',
            style: AppTextStyles.title,
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
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

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadReport,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1000;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 32 : 16,
              vertical: 24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1400,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPageHeader(),

                    const SizedBox(height: 24),

                    _buildOverviewSection(
                      totalStockValue: _totalStockValue,
                    ),

                    const SizedBox(height: 28),

                    _buildInformationSection(
                      totalStockValue: _totalStockValue,
                    ),

                    const SizedBox(height: 32),

                    _buildExportSection(
                      totalStockValue: _totalStockValue,
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // PAGE HEADER
  // ============================================================

  Widget _buildPageHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Inventory valuation',
          style: AppTextStyles.heading,
        ),
        SizedBox(height: 6),
        Text(
          'View the current value of all inventory in your business.',
          style: AppTextStyles.bodySecondary,
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 14,
              color: AppColors.textMuted,
            ),
            SizedBox(width: 6),
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
        const SizedBox(height: 14),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStockValueIcon(),
                const SizedBox(height: 16),
                _buildStockValueContent(totalStockValue),
                const SizedBox(height: 16),
                _buildStatusBadge(),
              ],
            );
          }

          return Row(
            children: [
              _buildStockValueIcon(),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStockValueContent(totalStockValue),
              ),
              const SizedBox(width: 20),
              _buildStatusBadge(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStockValueIcon() {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.inventory.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.inventory_2_outlined,
        color: AppColors.inventory,
        size: 28,
      ),
    );
  }

  Widget _buildStockValueContent(double totalStockValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Total Stock Value',
          style: AppTextStyles.bodySecondary,
        ),
        const SizedBox(height: 6),
        Text(
          _formatCurrency(totalStockValue),
          style: AppTextStyles.price.copyWith(
            fontSize: 28,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 5),
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
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.20),
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
          SizedBox(width: 6),
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
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            children: [
              _informationRow(
                icon: Icons.inventory_2_outlined,
                title: 'Current stock value',
                value: _formatCurrency(totalStockValue),
                color: AppColors.inventory,
              ),
              const Divider(
                height: 24,
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
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            color: color,
            size: 19,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.bodySecondary,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.bodySecondary.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
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
          final compact = constraints.maxWidth < 650;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _exportContent(),
                const SizedBox(height: 16),
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
              const SizedBox(width: 20),
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
                'Export stock valuation',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 5),
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
        'Export PDF',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
      ),
      onPressed: () => _exportPdf(
        totalStockValue: totalStockValue,
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
                _formatCurrency(totalStockValue),
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
      if (i > 0 && (string.length - i) % 3 == 0) {
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

class _StockValueLoadingState extends StatelessWidget {
  const _StockValueLoadingState();

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
              'Loading stock valuation...',
              style: AppTextStyles.bodySecondary,
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

class _StockValueErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _StockValueErrorState({
    required this.error,
    required this.onRetry,
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
                'Unable to load stock value',
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
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
                    fontWeight: FontWeight.w600,
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