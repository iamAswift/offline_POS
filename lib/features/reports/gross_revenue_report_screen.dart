// lib/features/reports/gross_revenue_report_screen.dart

import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/styles.dart';
import '../../database/app_database.dart';
import '../../database/daos/sales_dao.dart';
import '../../shared/pdf_report.dart';

class GrossRevenueReportScreen extends StatefulWidget {
  const GrossRevenueReportScreen({super.key});

  @override
  State<GrossRevenueReportScreen> createState() =>
      _GrossRevenueReportScreenState();
}

class _GrossRevenueReportScreenState
    extends State<GrossRevenueReportScreen> {
  late final SalesDao salesDao;

  double _grossRevenue = 0.0;

  bool _isLoading = true;

  String? _error;

  // ============================================================
  // DATE FILTER
  // ============================================================

  _RevenuePeriod _selectedPeriod = _RevenuePeriod.allTime;

  DateTime? _customStartDate;

  DateTime? _customEndDate;

  // ============================================================
  // INIT
  // ============================================================

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
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final range = _getDateRange();

      final value = await salesDao.getGrossRevenue(
        range.start,
        range.end,
      );

      if (!mounted) return;

      setState(() {
        _grossRevenue = _toDouble(value);
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
  // DATE RANGE
  // ============================================================

  _DateRange _getDateRange() {
    final now = DateTime.now();

    switch (_selectedPeriod) {
      case _RevenuePeriod.today:
        final start = DateTime(
          now.year,
          now.month,
          now.day,
        );

        final end = start.add(
          const Duration(days: 1),
        );

        return _DateRange(
          start: start,
          end: end,
        );

      case _RevenuePeriod.yesterday:
        final today = DateTime(
          now.year,
          now.month,
          now.day,
        );

        final start = today.subtract(
          const Duration(days: 1),
        );

        return _DateRange(
          start: start,
          end: today,
        );

      case _RevenuePeriod.thisWeek:
        final today = DateTime(
          now.year,
          now.month,
          now.day,
        );

        final daysFromMonday =
            today.weekday - DateTime.monday;

        final start = today.subtract(
          Duration(days: daysFromMonday),
        );

        final end = today.add(
          const Duration(days: 1),
        );

        return _DateRange(
          start: start,
          end: end,
        );

      case _RevenuePeriod.thisMonth:
        final start = DateTime(
          now.year,
          now.month,
          1,
        );

        final end = DateTime(
          now.year,
          now.month + 1,
          1,
        );

        return _DateRange(
          start: start,
          end: end,
        );

      case _RevenuePeriod.thisYear:
        final start = DateTime(
          now.year,
          1,
          1,
        );

        final end = DateTime(
          now.year + 1,
          1,
          1,
        );

        return _DateRange(
          start: start,
          end: end,
        );

      case _RevenuePeriod.allTime:
        // Temporary compatibility with the existing DAO signature.
        //
        // The preferred architecture is for SalesDao.getGrossRevenue()
        // to support nullable boundaries for a true unbounded query.
        final start = DateTime(
          2000,
          1,
          1,
        );

        final end = DateTime(
          now.year,
          now.month,
          now.day,
        ).add(
          const Duration(days: 1),
        );

        return _DateRange(
          start: start,
          end: end,
        );

      case _RevenuePeriod.custom:
        final start = _customStartDate;

        final end = _customEndDate;

        if (start == null || end == null) {
          final fallbackStart = DateTime(
            now.year,
            now.month,
            now.day,
          );

          return _DateRange(
            start: fallbackStart,
            end: fallbackStart.add(
              const Duration(days: 1),
            ),
          );
        }

        final normalizedStart = DateTime(
          start.year,
          start.month,
          start.day,
        );

        final normalizedEnd = DateTime(
          end.year,
          end.month,
          end.day,
        ).add(
          const Duration(days: 1),
        );

        return _DateRange(
          start: normalizedStart,
          end: normalizedEnd,
        );
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
      titleSpacing: responsive.horizontalPadding,
      title: Row(
        children: [
          Container(
            width: AppSizes.iconButton,
            height: AppSizes.iconButton,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(
                AppRadius.lg,
              ),
            ),
            child: const Icon(
              Icons.payments_outlined,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(
            width: AppSpacing.md,
          ),
          const Text(
            'Gross Revenue Report',
            style: AppTextStyles.title,
          ),
        ],
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(
            right: responsive.horizontalPadding,
          ),
          child: IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading
                ? null
                : _loadReport,
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(
          height: 1,
          thickness: 1,
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
      return const _GrossRevenueLoadingState();
    }

    if (_error != null) {
      return _GrossRevenueErrorState(
        error: _error!,
        onRetry: _loadReport,
      );
    }

    final responsive = context.responsive;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadReport,
      child: SingleChildScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(),
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
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _buildPageHeader(),

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                _buildPeriodSelector(),

                const SizedBox(
                  height: AppSpacing.xxl,
                ),

                _buildRevenueCard(),

                const SizedBox(
                  height: AppSpacing.xxl,
                ),

                _buildInformationSection(),

                const SizedBox(
                  height: AppSpacing.xxxl,
                ),

                _buildExportSection(),

                const SizedBox(
                  height: AppSpacing.xl,
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
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Revenue performance',
          style: AppTextStyles.heading,
        ),

        SizedBox(
          height: AppSpacing.xs,
        ),

        const Text(
          'View the total gross revenue generated from sales.',
          style: AppTextStyles.bodySecondary,
        ),

        SizedBox(
          height: AppSpacing.sm,
        ),

        Row(
          children: [
            const Icon(
              Icons.trending_up_outlined,
              size: 14,
              color: AppColors.textMuted,
            ),
            SizedBox(
              width: AppSpacing.xs,
            ),
            const Text(
              'Sales revenue',
              style: AppTextStyles.small,
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // PERIOD SELECTOR
  // ============================================================

  Widget _buildPeriodSelector() {
    final responsive = context.responsive;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        AppSpacing.lg,
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
      child: responsive.isCompact
          ? _buildCompactPeriodSelector()
          : _buildWidePeriodSelector(),
    );
  }

  Widget _buildCompactPeriodSelector() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _buildPeriodLabel(),

        const SizedBox(
          height: AppSpacing.md,
        ),

        _buildPeriodDropdown(
          fullWidth: true,
        ),

        if (_selectedPeriod ==
            _RevenuePeriod.custom) ...[
          const SizedBox(
            height: AppSpacing.md,
          ),
          _buildCustomDateButton(
            fullWidth: true,
          ),
        ],
      ],
    );
  }

  Widget _buildWidePeriodSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildPeriodLabel(),
        ),

        const SizedBox(
          width: AppSpacing.lg,
        ),

        _buildPeriodDropdown(),

        if (_selectedPeriod ==
            _RevenuePeriod.custom) ...[
          const SizedBox(
            width: AppSpacing.md,
          ),
          _buildCustomDateButton(),
        ],
      ],
    );
  }

  Widget _buildPeriodLabel() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Revenue period',
          style: AppTextStyles.title,
        ),

        SizedBox(
          height: AppSpacing.xs,
        ),

        Text(
          _periodDescription(),
          style: AppTextStyles.bodySecondary,
        ),
      ],
    );
  }

  Widget _buildPeriodDropdown({
    bool fullWidth = false,
  }) {
    return SizedBox(
      width: fullWidth
          ? double.infinity
          : AppSizes.maxFormWidth / 2,
      child: DropdownButtonFormField<
          _RevenuePeriod>(
        initialValue: _selectedPeriod,
        decoration: InputDecoration(
          labelText: 'Period',
          filled: true,
          fillColor: AppColors.surfaceSoft,
          contentPadding:
              EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              AppRadius.lg,
            ),
            borderSide:
                const BorderSide(
              color: AppColors.border,
            ),
          ),
          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              AppRadius.lg,
            ),
            borderSide:
                const BorderSide(
              color: AppColors.border,
            ),
          ),
          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              AppRadius.lg,
            ),
            borderSide:
                const BorderSide(
              color: AppColors.primary,
            ),
          ),
        ),
        items: const [
          DropdownMenuItem(
            value: _RevenuePeriod.allTime,
            child: Text('All Time'),
          ),
          DropdownMenuItem(
            value: _RevenuePeriod.today,
            child: Text('Today'),
          ),
          DropdownMenuItem(
            value: _RevenuePeriod.yesterday,
            child: Text('Yesterday'),
          ),
          DropdownMenuItem(
            value: _RevenuePeriod.thisWeek,
            child: Text('This Week'),
          ),
          DropdownMenuItem(
            value: _RevenuePeriod.thisMonth,
            child: Text('This Month'),
          ),
          DropdownMenuItem(
            value: _RevenuePeriod.thisYear,
            child: Text('This Year'),
          ),
          DropdownMenuItem(
            value: _RevenuePeriod.custom,
            child: Text('Custom Range'),
          ),
        ],
        onChanged: (value) {
          if (value == null) return;

          setState(() {
            _selectedPeriod = value;
          });

          if (value ==
              _RevenuePeriod.custom) {
            _selectCustomDateRange();
          } else {
            _loadReport();
          }
        },
      ),
    );
  }

  // ============================================================
  // CUSTOM DATE
  // ============================================================

  Widget _buildCustomDateButton({
    bool fullWidth = false,
  }) {
    final responsive = context.responsive;

    return SizedBox(
      width: fullWidth
          ? double.infinity
          : AppSizes.maxFormWidth / 2,
      height: responsive.buttonHeight,
      child: OutlinedButton.icon(
        onPressed: _selectCustomDateRange,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          side: const BorderSide(
            color: AppColors.border,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              AppRadius.lg,
            ),
          ),
        ),
        icon: const Icon(
          Icons.calendar_month_outlined,
          size: 18,
        ),
        label: Text(
          _customRangeLabel(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Future<void> _selectCustomDateRange() async {
    final now = DateTime.now();

    final initialStart =
        _customStartDate ??
            DateTime(
              now.year,
              now.month,
              now.day,
            );

    final initialEnd =
        _customEndDate ??
            initialStart;

    final picked =
        await showDateRangePicker(
      context: context,
      firstDate: DateTime(
        2000,
        1,
        1,
      ),
      lastDate: DateTime(
        now.year,
        now.month,
        now.day,
      ),
      initialDateRange: DateTimeRange(
        start: initialStart,
        end: initialEnd,
      ),
      builder: (
        context,
        child,
      ) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme:
                Theme.of(context)
                    .colorScheme
                    .copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) {
      if (_customStartDate == null ||
          _customEndDate == null) {
        setState(() {
          _selectedPeriod =
              _RevenuePeriod.allTime;
        });

        _loadReport();
      }

      return;
    }

    setState(() {
      _customStartDate = picked.start;
      _customEndDate = picked.end;
    });

    await _loadReport();
  }

  // ============================================================
  // REVENUE CARD
  // ============================================================

  Widget _buildRevenueCard() {
    final responsive = context.responsive;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        AppSpacing.xl,
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
      child: responsive.isCompact
          ? Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _buildRevenueIcon(),

                const SizedBox(
                  height: AppSpacing.lg,
                ),

                _buildRevenueContent(),
              ],
            )
          : Row(
              children: [
                _buildRevenueIcon(),

                const SizedBox(
                  width: AppSpacing.lg,
                ),

                Expanded(
                  child:
                      _buildRevenueContent(),
                ),

                const SizedBox(
                  width: AppSpacing.xl,
                ),

                _buildStatusBadge(),
              ],
            ),
    );
  }

  Widget _buildRevenueIcon() {
    return Container(
      width: AppSizes.iconButton +
          AppSpacing.md,
      height: AppSizes.iconButton +
          AppSpacing.md,
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(
          alpha: 0.10,
        ),
        borderRadius: BorderRadius.circular(
          AppRadius.xl,
        ),
      ),
      child: const Icon(
        Icons.payments_outlined,
        color: AppColors.accent,
      ),
    );
  }

  Widget _buildRevenueContent() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Gross Revenue',
          style: AppTextStyles.bodySecondary,
        ),

        const SizedBox(
          height: AppSpacing.xs,
        ),

        Text(
          _formatCurrency(_grossRevenue),
          style: AppTextStyles.price.copyWith(
            fontSize: AppTextStyles.price.fontSize,
            color: AppColors.textPrimary,
          ),
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(
          height: AppSpacing.xs,
        ),

        Text(
          _periodDescription(),
          style: AppTextStyles.small,
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 15,
            color: AppColors.success,
          ),

          SizedBox(
            width: AppSpacing.xs,
          ),

          const Text(
            'Revenue tracked',
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
  // INFORMATION
  // ============================================================

  Widget _buildInformationSection() {
    final range = _getDateRange();

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Revenue details',
          style: AppTextStyles.title,
        ),

        const SizedBox(
          height: AppSpacing.md,
        ),

        Container(
          width: double.infinity,
          padding: EdgeInsets.all(
            AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.circular(
              AppRadius.xl,
            ),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            children: [
              _informationRow(
                icon: Icons.payments_outlined,
                title: 'Gross revenue',
                value:
                    _formatCurrency(
                  _grossRevenue,
                ),
                color: AppColors.accent,
              ),

              _buildDivider(),

              _informationRow(
                icon:
                    Icons.calendar_today_outlined,
                title: 'Period',
                value: _periodLabel(),
                color: AppColors.info,
              ),

              _buildDivider(),

              _informationRow(
                icon:
                    Icons.date_range_outlined,
                title: 'Date range',
                value:
                    _formatDateRange(
                  range,
                ),
                color: AppColors.inventory,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.md,
      ),
      child: const Divider(
        height: 1,
        color: AppColors.divider,
      ),
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
          width: AppSizes.iconButton -
              AppSpacing.xs,
          height: AppSizes.iconButton -
              AppSpacing.xs,
          decoration: BoxDecoration(
            color: color.withValues(
              alpha: 0.10,
            ),
            borderRadius:
                BorderRadius.circular(
              AppRadius.md,
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 19,
          ),
        ),

        const SizedBox(
          width: AppSpacing.md,
        ),

        Expanded(
          child: Text(
            title,
            style: AppTextStyles.bodySecondary,
          ),
        ),

        const SizedBox(
          width: AppSpacing.md,
        ),

        Flexible(
          child: Text(
            value,
            style: AppTextStyles.bodySecondary
                .copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EXPORT
  // ============================================================

  Widget _buildExportSection() {
    final responsive = context.responsive;

    return Container(
      padding: EdgeInsets.all(
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
      child: responsive.isCompact
          ? Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _exportContent(),

                const SizedBox(
                  height: AppSpacing.lg,
                ),

                _exportButton(),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: _exportContent(),
                ),

                const SizedBox(
                  width: AppSpacing.xl,
                ),

                _exportButton(),
              ],
            ),
    );
  }

  Widget _exportContent() {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.picture_as_pdf_outlined,
          color: Colors.white,
          size: 30,
        ),

        SizedBox(
          width: AppSpacing.md,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Export gross revenue',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(
                height: AppSpacing.xs,
              ),

              const Text(
                'Generate a PDF containing the selected revenue period.',
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

  Widget _exportButton() {
    final responsive = context.responsive;

    return SizedBox(
      height: responsive.buttonHeight,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              AppRadius.lg,
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
        onPressed: _exportPdf,
      ),
    );
  }

  // ============================================================
  // PDF
  // ============================================================

  Future<void> _exportPdf() async {
    try {
      final file =
          await PdfReport.generateReport(
        title: 'Gross Revenue Report',
        sections: [
          {
            'title': 'Gross Revenue Summary',
            'headers': [
              'Metric',
              'Value',
            ],
            'rows': [
              [
                'Period',
                _periodLabel(),
              ],
              [
                'Date Range',
                _formatDateRange(
                  _getDateRange(),
                ),
              ],
              [
                'Gross Revenue',
                _formatCurrency(
                  _grossRevenue,
                ),
              ],
            ],
          },
        ],
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          behavior:
              SnackBarBehavior.floating,
          backgroundColor:
              AppColors.success,
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

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          behavior:
              SnackBarBehavior.floating,
          backgroundColor:
              AppColors.danger,
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
  // HELPERS
  // ============================================================

  String _periodLabel() {
    switch (_selectedPeriod) {
      case _RevenuePeriod.allTime:
        return 'All Time';

      case _RevenuePeriod.today:
        return 'Today';

      case _RevenuePeriod.yesterday:
        return 'Yesterday';

      case _RevenuePeriod.thisWeek:
        return 'This Week';

      case _RevenuePeriod.thisMonth:
        return 'This Month';

      case _RevenuePeriod.thisYear:
        return 'This Year';

      case _RevenuePeriod.custom:
        return 'Custom Range';
    }
  }

  String _periodDescription() {
    switch (_selectedPeriod) {
      case _RevenuePeriod.allTime:
        return 'Revenue from all recorded sales';

      case _RevenuePeriod.today:
        return 'Revenue generated today';

      case _RevenuePeriod.yesterday:
        return 'Revenue generated yesterday';

      case _RevenuePeriod.thisWeek:
        return 'Revenue generated this week';

      case _RevenuePeriod.thisMonth:
        return 'Revenue generated this month';

      case _RevenuePeriod.thisYear:
        return 'Revenue generated this year';

      case _RevenuePeriod.custom:
        return 'Revenue for the selected date range';
    }
  }

  String _customRangeLabel() {
    if (_customStartDate == null ||
        _customEndDate == null) {
      return 'Select dates';
    }

    return '${_formatDate(_customStartDate!)}'
        ' – '
        '${_formatDate(_customEndDate!)}';
  }

  String _formatDateRange(
    _DateRange range,
  ) {
    if (_selectedPeriod ==
        _RevenuePeriod.allTime) {
      return 'All recorded sales';
    }

    return '${_formatDate(range.start)}'
        ' – '
        '${_formatDate(
      range.end.subtract(
        const Duration(days: 1),
      ),
    )}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatCurrency(double value) {
    return '₦${_formatNumber(value.round())}';
  }

  String _formatNumber(num value) {
    final number = value.toInt();

    final string = number.toString();

    final buffer = StringBuffer();

    for (
      int i = 0;
      i < string.length;
      i++
    ) {
      if (
          i > 0 &&
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
        0.0;
  }
}

// ================================================================
// REVENUE PERIOD
// ================================================================

enum _RevenuePeriod {
  allTime,
  today,
  yesterday,
  thisWeek,
  thisMonth,
  thisYear,
  custom,
}

// ================================================================
// DATE RANGE MODEL
// ================================================================

class _DateRange {
  final DateTime start;

  final DateTime end;

  const _DateRange({
    required this.start,
    required this.end,
  });
}

// ================================================================
// LOADING
// ================================================================

class _GrossRevenueLoadingState
    extends StatelessWidget {
  const _GrossRevenueLoadingState();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(
          AppSpacing.huge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: AppColors.primary,
            ),

            SizedBox(
              height: AppSpacing.lg,
            ),

            const Text(
              'Loading gross revenue...',
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// ERROR
// ================================================================

class _GrossRevenueErrorState
    extends StatelessWidget {
  final String error;

  final VoidCallback onRetry;

  const _GrossRevenueErrorState({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(
          AppSpacing.xxxl,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: AppSizes.maxFormWidth +
                AppSpacing.xxxl * 4,
          ),
          padding: EdgeInsets.all(
            AppSpacing.xxxl,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.circular(
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
                width: AppSizes.iconButton +
                    AppSpacing.md,
                height: AppSizes.iconButton +
                    AppSpacing.md,
                decoration: BoxDecoration(
                  color: AppColors.dangerLight,
                  borderRadius:
                      BorderRadius.circular(
                    AppRadius.xl,
                  ),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: AppColors.danger,
                  size: 30,
                ),
              ),

              SizedBox(
                height: AppSpacing.lg,
              ),

              const Text(
                'Unable to load gross revenue',
                style: AppTextStyles.title,
                textAlign: TextAlign.center,
              ),

              SizedBox(
                height: AppSpacing.sm,
              ),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(
                  AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius:
                      BorderRadius.circular(
                    AppRadius.lg,
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

              SizedBox(
                height: AppSpacing.xl,
              ),

              SizedBox(
                height: context.responsive.buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.primary,
                    foregroundColor:
                        Colors.white,
                    elevation: 0,
                    padding:
                        EdgeInsets.symmetric(
                      horizontal:
                          AppSpacing.xl,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        AppRadius.lg,
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