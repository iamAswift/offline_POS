// lib/features/reports/gross_revenue_report_screen.dart

import 'package:flutter/material.dart';

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

        final end = today;

        return _DateRange(
          start: start,
          end: end,
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
        // Use a very old start and tomorrow as the end.
        //
        // This lets the existing SalesDao method remain
        // completely unchanged while effectively returning
        // all sales in the database.
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
              color: AppColors.accent.withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.payments_outlined,
              color: AppColors.accent,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            "Gross Revenue Report",
            style: AppTextStyles.title,
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: IconButton(
            tooltip: "Refresh",
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
      return const _GrossRevenueLoadingState();
    }

    if (_error != null) {
      return _GrossRevenueErrorState(
        error: _error!,
        onRetry: _loadReport,
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadReport,
      child: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final isDesktop =
              constraints.maxWidth >= 1000;

          return SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal:
                  isDesktop ? 32 : 16,
              vertical: 24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(
                  maxWidth: 1400,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _buildPageHeader(),

                    const SizedBox(height: 24),

                    _buildPeriodSelector(),

                    const SizedBox(height: 28),

                    _buildRevenueCard(),

                    const SizedBox(height: 28),

                    _buildInformationSection(),

                    const SizedBox(height: 32),

                    _buildExportSection(),

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
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          "Revenue performance",
          style: AppTextStyles.heading,
        ),
        SizedBox(height: 6),
        Text(
          "View the total gross revenue generated from sales.",
          style:
              AppTextStyles.bodySecondary,
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Icon(
              Icons.trending_up_outlined,
              size: 14,
              color: AppColors.textMuted,
            ),
            SizedBox(width: 6),
            Text(
              "Sales revenue",
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final compact =
              constraints.maxWidth < 700;

          if (compact) {
            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _buildPeriodLabel(),

                const SizedBox(height: 12),

                _buildPeriodDropdown(
                  fullWidth: true,
                ),

                if (_selectedPeriod ==
                    _RevenuePeriod.custom) ...[
                  const SizedBox(height: 12),
                  _buildCustomDateButton(
                    fullWidth: true,
                  ),
                ],
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: _buildPeriodLabel(),
              ),

              const SizedBox(width: 20),

              _buildPeriodDropdown(),

              if (_selectedPeriod ==
                  _RevenuePeriod.custom) ...[
                const SizedBox(width: 12),
                _buildCustomDateButton(),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildPeriodLabel() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          "Revenue period",
          style: AppTextStyles.title,
        ),
        const SizedBox(height: 4),
        Text(
          _periodDescription(),
          style:
              AppTextStyles.bodySecondary,
        ),
      ],
    );
  }

  Widget _buildPeriodDropdown({
    bool fullWidth = false,
  }) {
    return SizedBox(
      width: fullWidth ? double.infinity : 220,
      child: DropdownButtonFormField<
          _RevenuePeriod>(
        value: _selectedPeriod,
        decoration:
            InputDecoration(
          labelText: "Period",
          filled: true,
          fillColor:
              AppColors.surfaceSoft,
          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              10,
            ),
            borderSide:
                const BorderSide(
              color:
                  AppColors.border,
            ),
          ),
          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              10,
            ),
            borderSide:
                const BorderSide(
              color:
                  AppColors.border,
            ),
          ),
        ),
        items: const [
          DropdownMenuItem(
            value:
                _RevenuePeriod.allTime,
            child: Text(
              "All Time",
            ),
          ),
          DropdownMenuItem(
            value:
                _RevenuePeriod.today,
            child: Text(
              "Today",
            ),
          ),
          DropdownMenuItem(
            value:
                _RevenuePeriod.yesterday,
            child: Text(
              "Yesterday",
            ),
          ),
          DropdownMenuItem(
            value:
                _RevenuePeriod.thisWeek,
            child: Text(
              "This Week",
            ),
          ),
          DropdownMenuItem(
            value:
                _RevenuePeriod.thisMonth,
            child: Text(
              "This Month",
            ),
          ),
          DropdownMenuItem(
            value:
                _RevenuePeriod.thisYear,
            child: Text(
              "This Year",
            ),
          ),
          DropdownMenuItem(
            value:
                _RevenuePeriod.custom,
            child: Text(
              "Custom Range",
            ),
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
    return SizedBox(
      width: fullWidth ? double.infinity : 220,
      child: OutlinedButton.icon(
        onPressed:
            _selectCustomDateRange,
        style: OutlinedButton.styleFrom(
          foregroundColor:
              AppColors.primary,
          padding:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          side: const BorderSide(
            color: AppColors.border,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(10),
          ),
        ),
        icon: const Icon(
          Icons.calendar_month_outlined,
          size: 18,
        ),
        label: Text(
          _customRangeLabel(),
          overflow:
              TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Future<void>
      _selectCustomDateRange() async {
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
      initialDateRange:
          DateTimeRange(
        start: initialStart,
        end: initialEnd,
      ),
      builder: (
        context,
        child,
      ) {
        return Theme(
          data: Theme.of(context)
              .copyWith(
            colorScheme:
                Theme.of(context)
                    .colorScheme
                    .copyWith(
                      primary:
                          AppColors.primary,
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
      _customStartDate =
          picked.start;

      _customEndDate =
          picked.end;
    });

    await _loadReport();
  }

  // ============================================================
  // REVENUE CARD
  // ============================================================

  Widget _buildRevenueCard() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color:
                Color(0x08000000),
            blurRadius: 8,
            offset:
                Offset(0, 3),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final compact =
              constraints.maxWidth < 600;

          if (compact) {
            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _buildRevenueIcon(),

                const SizedBox(
                  height: 16,
                ),

                _buildRevenueContent(),
              ],
            );
          }

          return Row(
            children: [
              _buildRevenueIcon(),

              const SizedBox(
                width: 16,
              ),

              Expanded(
                child:
                    _buildRevenueContent(),
              ),

              const SizedBox(
                width: 20,
              ),

              _buildStatusBadge(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRevenueIcon() {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color:
            AppColors.accent.withValues(
          alpha: 0.10,
        ),
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.payments_outlined,
        color: AppColors.accent,
        size: 28,
      ),
    );
  }

  Widget _buildRevenueContent() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          "Gross Revenue",
          style:
              AppTextStyles.bodySecondary,
        ),

        const SizedBox(height: 6),

        Text(
          _formatCurrency(
            _grossRevenue,
          ),
          style:
              AppTextStyles.price
                  .copyWith(
            fontSize: 30,
            color:
                AppColors.textPrimary,
          ),
          overflow:
              TextOverflow.ellipsis,
        ),

        const SizedBox(height: 5),

        Text(
          _periodDescription(),
          style: AppTextStyles.small,
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color:
            AppColors.successLight,
        borderRadius:
            BorderRadius.circular(8),
        border: Border.all(
          color:
              AppColors.success
                  .withValues(
            alpha: 0.20,
          ),
        ),
      ),
      child: const Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 15,
            color:
                AppColors.success,
          ),
          SizedBox(width: 6),
          Text(
            "Revenue tracked",
            style: TextStyle(
              fontFamily:
                  'Poppins',
              fontSize: 11,
              fontWeight:
                  FontWeight.w600,
              color:
                  AppColors.success,
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
    final range =
        _getDateRange();

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          "Revenue details",
          style: AppTextStyles.title,
        ),

        const SizedBox(height: 14),

        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            children: [
              _informationRow(
                icon:
                    Icons.payments_outlined,
                title:
                    "Gross revenue",
                value:
                    _formatCurrency(
                  _grossRevenue,
                ),
                color:
                    AppColors.accent,
              ),

              const Divider(
                height: 24,
                color:
                    AppColors.divider,
              ),

              _informationRow(
                icon:
                    Icons.calendar_today_outlined,
                title:
                    "Period",
                value:
                    _periodLabel(),
                color:
                    AppColors.info,
              ),

              const Divider(
                height: 24,
                color:
                    AppColors.divider,
              ),

              _informationRow(
                icon:
                    Icons.date_range_outlined,
                title:
                    "Date range",
                value:
                    _formatDateRange(
                  range,
                ),
                color:
                    AppColors.inventory,
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
          decoration:
              BoxDecoration(
            color:
                color.withValues(
              alpha: 0.10,
            ),
            borderRadius:
                BorderRadius.circular(
              9,
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 19,
          ),
        ),

        const SizedBox(
          width: 12,
        ),

        Expanded(
          child: Text(
            title,
            style:
                AppTextStyles
                    .bodySecondary,
          ),
        ),

        const SizedBox(
          width: 12,
        ),

        Flexible(
          child: Text(
            value,
            style: AppTextStyles
                .bodySecondary
                .copyWith(
              color:
                  AppColors.textPrimary,
              fontWeight:
                  FontWeight.w600,
            ),
            textAlign:
                TextAlign.right,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EXPORT
  // ============================================================

  Widget _buildExportSection() {
    return Container(
      padding:
          const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color:
                Color(0x18000000),
            blurRadius: 10,
            offset:
                Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final compact =
              constraints.maxWidth < 650;

          if (compact) {
            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _exportContent(),

                const SizedBox(
                  height: 16,
                ),

                _exportButton(),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child:
                    _exportContent(),
              ),

              const SizedBox(
                width: 20,
              ),

              _exportButton(),
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

        SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                "Export gross revenue",
                style: TextStyle(
                  fontFamily:
                      'Poppins',
                  color:
                      Colors.white,
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              SizedBox(height: 5),

              Text(
                "Generate a PDF containing the selected revenue period.",
                style: TextStyle(
                  fontFamily:
                      'Poppins',
                  color:
                      Colors.white70,
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
    return ElevatedButton.icon(
      style:
          ElevatedButton.styleFrom(
        backgroundColor:
            Colors.white,
        foregroundColor:
            AppColors.primary,
        elevation: 0,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 13,
        ),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(10),
        ),
      ),
      icon: const Icon(
        Icons.download_outlined,
        size: 19,
      ),
      label: const Text(
        "Export PDF",
        style: TextStyle(
          fontFamily:
              'Poppins',
          fontWeight:
              FontWeight.w600,
        ),
      ),
      onPressed: _exportPdf,
    );
  }

  // ============================================================
  // PDF
  // ============================================================

  Future<void> _exportPdf() async {
    try {
      final file =
          await PdfReport.generateReport(
        title:
            "Gross Revenue Report",
        sections: [
          {
            "title":
                "Gross Revenue Summary",
            "headers": [
              "Metric",
              "Value",
            ],
            "rows": [
              [
                "Period",
                _periodLabel(),
              ],
              [
                "Date Range",
                _formatDateRange(
                  _getDateRange(),
                ),
              ],
              [
                "Gross Revenue",
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
            "PDF saved at ${file.path}",
            style:
                const TextStyle(
              fontFamily:
                  'Poppins',
              color:
                  Colors.white,
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
            "Unable to generate PDF: $e",
            style:
                const TextStyle(
              fontFamily:
                  'Poppins',
              color:
                  Colors.white,
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
        return "All Time";

      case _RevenuePeriod.today:
        return "Today";

      case _RevenuePeriod.yesterday:
        return "Yesterday";

      case _RevenuePeriod.thisWeek:
        return "This Week";

      case _RevenuePeriod.thisMonth:
        return "This Month";

      case _RevenuePeriod.thisYear:
        return "This Year";

      case _RevenuePeriod.custom:
        return "Custom Range";
    }
  }

  String _periodDescription() {
    switch (_selectedPeriod) {
      case _RevenuePeriod.allTime:
        return "Revenue from all recorded sales";

      case _RevenuePeriod.today:
        return "Revenue generated today";

      case _RevenuePeriod.yesterday:
        return "Revenue generated yesterday";

      case _RevenuePeriod.thisWeek:
        return "Revenue generated this week";

      case _RevenuePeriod.thisMonth:
        return "Revenue generated this month";

      case _RevenuePeriod.thisYear:
        return "Revenue generated this year";

      case _RevenuePeriod.custom:
        return "Revenue for the selected date range";
    }
  }

  String _customRangeLabel() {
    if (_customStartDate == null ||
        _customEndDate == null) {
      return "Select dates";
    }

    return "${_formatDate(_customStartDate!)}"
        " – "
        "${_formatDate(_customEndDate!)}";
  }

  String _formatDateRange(
    _DateRange range,
  ) {
    if (_selectedPeriod ==
        _RevenuePeriod.allTime) {
      return "All recorded sales";
    }

    return "${_formatDate(range.start)}"
        " – "
        "${_formatDate(range.end.subtract(const Duration(days: 1)))}";
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  String _formatCurrency(double value) {
    return "₦${_formatNumber(value.round())}";
  }

  String _formatNumber(num value) {
    final number = value.toInt();

    final string =
        number.toString();

    final buffer =
        StringBuffer();

    for (
      int i = 0;
      i < string.length;
      i++
    ) {
      if (
        i > 0 &&
        (string.length - i) % 3 == 0
      ) {
        buffer.write(",");
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
          value?.toString() ?? "",
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
    return const Center(
      child: Padding(
        padding:
            EdgeInsets.all(40),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color:
                  AppColors.primary,
            ),
            SizedBox(height: 16),
            Text(
              "Loading gross revenue...",
              style:
                  AppTextStyles
                      .bodySecondary,
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
      child:
          SingleChildScrollView(
        padding:
            const EdgeInsets.all(32),
        child: Container(
          constraints:
              const BoxConstraints(
            maxWidth: 600,
          ),
          padding:
              const EdgeInsets.all(28),
          decoration:
              BoxDecoration(
            color:
                AppColors.surface,
            borderRadius:
                BorderRadius.circular(
              16,
            ),
            border: Border.all(
              color:
                  AppColors.border,
            ),
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration:
                    BoxDecoration(
                  color:
                      AppColors
                          .dangerLight,
                  borderRadius:
                      BorderRadius
                          .circular(
                    14,
                  ),
                ),
                child: const Icon(
                  Icons
                      .error_outline,
                  color:
                      AppColors.danger,
                  size: 30,
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              const Text(
                "Unable to load gross revenue",
                style:
                    AppTextStyles.title,
                textAlign:
                    TextAlign.center,
              ),

              const SizedBox(
                height: 10,
              ),

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(
                  14,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      AppColors
                          .surfaceSoft,
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                  border: Border.all(
                    color:
                        AppColors.border,
                  ),
                ),
                child:
                    SelectableText(
                  error,
                  style:
                      AppTextStyles.small,
                  textAlign:
                      TextAlign.left,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              ElevatedButton.icon(
                onPressed:
                    onRetry,
                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      AppColors.primary,
                  foregroundColor:
                      Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 20,
                    vertical: 13,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),
                ),
                icon:
                    const Icon(
                  Icons.refresh,
                  size: 18,
                ),
                label:
                    const Text(
                  "Try Again",
                  style:
                      TextStyle(
                    fontFamily:
                        'Poppins',
                    fontWeight:
                        FontWeight.w600,
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