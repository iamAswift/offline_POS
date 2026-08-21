// lib/features/reports/items_sold_report_screen.dart

import 'package:flutter/material.dart';

import '../../core/theme/styles.dart';
import '../../database/app_database.dart';
import '../../database/daos/sales_dao.dart';
import '../../shared/pdf_report.dart';

class ItemsSoldReportScreen extends StatefulWidget {
  const ItemsSoldReportScreen({super.key});

  @override
  State<ItemsSoldReportScreen> createState() =>
      _ItemsSoldReportScreenState();
}

class _ItemsSoldReportScreenState
    extends State<ItemsSoldReportScreen> {
  late final SalesDao salesDao;

  int _itemsSold = 0;

  bool _isLoading = true;

  String? _error;

  // ============================================================
  // DATE FILTER
  // ============================================================

  _ItemsSoldPeriod _selectedPeriod =
      _ItemsSoldPeriod.allTime;

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

      final value = await salesDao.getItemsSold(
        range.start,
        range.end,
      );

      if (!mounted) return;

      setState(() {
        _itemsSold = value;
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
      case _ItemsSoldPeriod.today:
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

      case _ItemsSoldPeriod.yesterday:
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

      case _ItemsSoldPeriod.thisWeek:
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

      case _ItemsSoldPeriod.thisMonth:
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

      case _ItemsSoldPeriod.thisYear:
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

      case _ItemsSoldPeriod.allTime:
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

      case _ItemsSoldPeriod.custom:
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
              color: AppColors.products.withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              color: AppColors.products,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          const Text(
            "Items Sold Report",
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
      return const _ItemsSoldLoadingState();
    }

    if (_error != null) {
      return _ItemsSoldErrorState(
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

                    _buildItemsSoldCard(),

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
          "Sales volume performance",
          style: AppTextStyles.heading,
        ),

        SizedBox(height: 6),

        Text(
          "View the total number of items sold during the selected period.",
          style:
              AppTextStyles.bodySecondary,
        ),

        SizedBox(height: 10),

        Row(
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 14,
              color: AppColors.textMuted,
            ),

            SizedBox(width: 6),

            Text(
              "Units sold",
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
                    _ItemsSoldPeriod.custom) ...[
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
                child:
                    _buildPeriodLabel(),
              ),

              const SizedBox(width: 20),

              _buildPeriodDropdown(),

              if (_selectedPeriod ==
                  _ItemsSoldPeriod.custom) ...[
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
          "Sales period",
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
          _ItemsSoldPeriod>(
        value: _selectedPeriod,
        decoration: InputDecoration(
          labelText: "Period",
          filled: true,
          fillColor:
              AppColors.surfaceSoft,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(10),
            borderSide:
                const BorderSide(
              color: AppColors.border,
            ),
          ),
          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(10),
            borderSide:
                const BorderSide(
              color: AppColors.border,
            ),
          ),
        ),
        items: const [
          DropdownMenuItem(
            value:
                _ItemsSoldPeriod.allTime,
            child: Text(
              "All Time",
            ),
          ),

          DropdownMenuItem(
            value:
                _ItemsSoldPeriod.today,
            child: Text(
              "Today",
            ),
          ),

          DropdownMenuItem(
            value:
                _ItemsSoldPeriod.yesterday,
            child: Text(
              "Yesterday",
            ),
          ),

          DropdownMenuItem(
            value:
                _ItemsSoldPeriod.thisWeek,
            child: Text(
              "This Week",
            ),
          ),

          DropdownMenuItem(
            value:
                _ItemsSoldPeriod.thisMonth,
            child: Text(
              "This Month",
            ),
          ),

          DropdownMenuItem(
            value:
                _ItemsSoldPeriod.thisYear,
            child: Text(
              "This Year",
            ),
          ),

          DropdownMenuItem(
            value:
                _ItemsSoldPeriod.custom,
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
              _ItemsSoldPeriod.custom) {
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
      width:
          fullWidth ? double.infinity : 220,
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
              _ItemsSoldPeriod.allTime;
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
  // ITEMS SOLD CARD
  // ============================================================

  Widget _buildItemsSoldCard() {
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
                _buildItemsSoldIcon(),

                const SizedBox(
                  height: 16,
                ),

                _buildItemsSoldContent(),
              ],
            );
          }

          return Row(
            children: [
              _buildItemsSoldIcon(),

              const SizedBox(
                width: 16,
              ),

              Expanded(
                child:
                    _buildItemsSoldContent(),
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

  Widget _buildItemsSoldIcon() {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color:
            AppColors.products.withValues(
          alpha: 0.10,
        ),
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.shopping_cart_outlined,
        color: AppColors.products,
        size: 28,
      ),
    );
  }

  Widget _buildItemsSoldContent() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          "Items Sold",
          style:
              AppTextStyles.bodySecondary,
        ),

        const SizedBox(height: 6),

        Text(
          _formatNumber(_itemsSold),
          style:
              AppTextStyles.price.copyWith(
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
              AppColors.success.withValues(
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
            "Sales tracked",
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
          "Sales details",
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
                    Icons.shopping_cart_outlined,
                title:
                    "Items sold",
                value:
                    _formatNumber(
                  _itemsSold,
                ),
                color:
                    AppColors.products,
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
            style:
                AppTextStyles
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
                "Export items sold",
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
                "Generate a PDF containing the selected sales volume period.",
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
            "Items Sold Report",
        sections: [
          {
            "title":
                "Items Sold Summary",
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
                "Items Sold",
                _formatNumber(
                  _itemsSold,
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
      case _ItemsSoldPeriod.allTime:
        return "All Time";

      case _ItemsSoldPeriod.today:
        return "Today";

      case _ItemsSoldPeriod.yesterday:
        return "Yesterday";

      case _ItemsSoldPeriod.thisWeek:
        return "This Week";

      case _ItemsSoldPeriod.thisMonth:
        return "This Month";

      case _ItemsSoldPeriod.thisYear:
        return "This Year";

      case _ItemsSoldPeriod.custom:
        return "Custom Range";
    }
  }

  String _periodDescription() {
    switch (_selectedPeriod) {
      case _ItemsSoldPeriod.allTime:
        return "All recorded items sold";

      case _ItemsSoldPeriod.today:
        return "Items sold today";

      case _ItemsSoldPeriod.yesterday:
        return "Items sold yesterday";

      case _ItemsSoldPeriod.thisWeek:
        return "Items sold this week";

      case _ItemsSoldPeriod.thisMonth:
        return "Items sold this month";

      case _ItemsSoldPeriod.thisYear:
        return "Items sold this year";

      case _ItemsSoldPeriod.custom:
        return "Items sold for the selected date range";
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
        _ItemsSoldPeriod.allTime) {
      return "All recorded sales";
    }

    return "${_formatDate(range.start)}"
        " – "
        "${_formatDate(
          range.end.subtract(
            const Duration(days: 1),
          ),
        )}";
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  String _formatNumber(num value) {
    final string = value.toInt().toString();

    final buffer = StringBuffer();

    for (
      int i = 0;
      i < string.length;
      i++
    ) {
      if (
          i > 0 &&
          (string.length - i) % 3 == 0) {
        buffer.write(",");
      }

      buffer.write(string[i]);
    }

    return buffer.toString();
  }
}

// ================================================================
// ITEMS SOLD PERIOD
// ================================================================

enum _ItemsSoldPeriod {
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

class _ItemsSoldLoadingState
    extends StatelessWidget {
  const _ItemsSoldLoadingState();

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
              "Loading items sold...",
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

class _ItemsSoldErrorState
    extends StatelessWidget {
  final String error;

  final VoidCallback onRetry;

  const _ItemsSoldErrorState({
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
                      BorderRadius.circular(
                    14,
                  ),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color:
                      AppColors.danger,
                  size: 30,
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              const Text(
                "Unable to load items sold",
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
                    ElevatedButton.styleFrom(
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

