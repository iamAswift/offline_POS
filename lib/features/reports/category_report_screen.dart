// lib/features/reports/category_report_screen.dart

import 'package:flutter/material.dart';

import '../../core/theme/styles.dart';
import '../../database/app_database.dart';
import '../../database/daos/sales_dao.dart';
import '../../shared/pdf_report.dart';

class CategoryReportScreen extends StatefulWidget {
  const CategoryReportScreen({super.key});

  @override
  State<CategoryReportScreen> createState() =>
      _CategoryReportScreenState();
}

class _CategoryReportScreenState
    extends State<CategoryReportScreen> {
  late final SalesDao salesDao;

  String _selectedFilter = "Month";
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();

    final db = getDatabase();
    salesDao = SalesDao(db);
  }

  @override
  Widget build(BuildContext context) {
    final range = _getRange();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadCategories(range),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const _CategoryLoadingState();
          }

          if (snapshot.hasError) {
            return _CategoryErrorState(
              error: snapshot.error.toString(),
              onRetry: () {
                setState(() {});
              },
            );
          }

          final categories = snapshot.data ?? [];

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              setState(() {});
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact =
                    constraints.maxWidth < 650;

                final totalSales = categories.fold<double>(
                  0,
                  (sum, category) =>
                      sum + _toDouble(category["totalSales"]),
                );

                final totalProfit = categories.fold<double>(
                  0,
                  (sum, category) =>
                      sum + _toDouble(category["profit"]),
                );

                final itemsSold = categories.fold<int>(
                  0,
                  (sum, category) =>
                      sum + _toInt(category["itemsSold"]),
                );

                final stockValue = categories.fold<double>(
                  0,
                  (sum, category) =>
                      sum + _toDouble(category["stockValue"]),
                );

                return SingleChildScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        isCompact ? 16 : 24,
                    vertical: 24,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 1200,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          _buildPageHeader(range),
                          const SizedBox(height: 24),

                          _buildOverview(
                            totalSales: totalSales,
                            totalProfit: totalProfit,
                            itemsSold: itemsSold,
                            stockValue: stockValue,
                            isCompact: isCompact,
                          ),

                          const SizedBox(height: 30),

                          _buildSectionHeader(
                            categoryCount:
                                categories.length,
                          ),

                          const SizedBox(height: 14),

                          if (categories.isEmpty)
                            const _CategoryEmptyState()
                          else
                            _buildCategoryList(
                              categories,
                              isCompact,
                            ),

                          const SizedBox(height: 30),

                          _buildExportSection(
                            categories: categories,
                            totalSales: totalSales,
                            totalProfit: totalProfit,
                            itemsSold: itemsSold,
                            stockValue: stockValue,
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
        },
      ),
    );
  }

  // ============================================================
  // DATA
  // ============================================================

  Future<List<Map<String, dynamic>>> _loadCategories(
    DateTimeRange range,
  ) async {
    final result = await salesDao.getCategorySummary(
      range.start,
      range.end,
    );

    return List<Map<String, dynamic>>.from(
      result.map(
        (item) => Map<String, dynamic>.from(item),
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
              color: AppColors.inventory
                  .withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.category_outlined,
              color: AppColors.inventory,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            "Category Report",
            style: AppTextStyles.title,
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _buildFilterDropdown(),
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
  // PAGE HEADER
  // ============================================================

  Widget _buildPageHeader(DateTimeRange range) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Category performance",
          style: AppTextStyles.heading,
        ),
        const SizedBox(height: 6),
        const Text(
          "Analyze sales, profit and inventory performance by category.",
          style: AppTextStyles.bodySecondary,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 14,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              _formatDateRange(range),
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

  Widget _buildOverview({
    required double totalSales,
    required double totalProfit,
    required int itemsSold,
    required double stockValue,
    required bool isCompact,
  }) {
    final cards = [
      _OverviewCardData(
        title: "Total Sales",
        value: _formatCurrency(totalSales),
        icon: Icons.payments_outlined,
        color: AppColors.primary,
        backgroundColor: AppColors.primaryLight,
      ),
      _OverviewCardData(
        title: "Total Profit",
        value: _formatCurrency(totalProfit),
        icon: Icons.trending_up,
        color: AppColors.success,
        backgroundColor: AppColors.successLight,
      ),
      _OverviewCardData(
        title: "Items Sold",
        value: _formatNumber(itemsSold),
        icon: Icons.shopping_cart_outlined,
        color: AppColors.info,
        backgroundColor: AppColors.infoLight,
      ),
      _OverviewCardData(
        title: "Stock Value",
        value: _formatCurrency(stockValue),
        icon: Icons.inventory_2_outlined,
        color: AppColors.inventory,
        backgroundColor:
            AppColors.inventory.withValues(alpha: 0.10),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int columns;

        if (constraints.maxWidth >= 950) {
          columns = 4;
        } else if (constraints.maxWidth >= 600) {
          columns = 2;
        } else {
          columns = 1;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio:
                columns == 1 ? 3.1 : 2.05,
          ),
          itemBuilder: (context, index) {
            return _buildOverviewCard(cards[index]);
          },
        );
      },
    );
  }

  Widget _buildOverviewCard(
    _OverviewCardData data,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
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
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: data.backgroundColor,
              borderRadius:
                  BorderRadius.circular(11),
            ),
            child: Icon(
              data.icon,
              color: data.color,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style:
                      AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 4),
                Text(
                  data.value,
                  style: AppTextStyles.price,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader({
    required int categoryCount,
  }) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                "Performance by category",
                style: AppTextStyles.title,
              ),
              SizedBox(height: 3),
              Text(
                "Compare sales, profit and inventory.",
                style: AppTextStyles.small,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius:
                BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Text(
            "$categoryCount categories",
            style: AppTextStyles.small.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CATEGORY LIST
  // ============================================================

  Widget _buildCategoryList(
    List<Map<String, dynamic>> categories,
    bool isCompact,
  ) {
    return Column(
      children: categories.map((category) {
        return Padding(
          padding:
              const EdgeInsets.only(bottom: 12),
          child: _buildCategoryCard(
            category,
            isCompact,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryCard(
    Map<String, dynamic> category,
    bool isCompact,
  ) {
    final categoryName =
        category["categoryName"]?.toString() ??
            "Unknown Category";

    final sales =
        _toDouble(category["totalSales"]);
    final items =
        _toInt(category["itemsSold"]);
    final profit =
        _toDouble(category["profit"]);
    final stockValue =
        _toDouble(category["stockValue"]);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 7,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          childrenPadding:
              const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),
          collapsedShape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.inventory
                  .withValues(alpha: 0.10),
              borderRadius:
                  BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.category_outlined,
              color: AppColors.inventory,
              size: 22,
            ),
          ),
          title: Text(
            categoryName,
            style: AppTextStyles.title.copyWith(
              fontSize: 15,
            ),
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding:
                const EdgeInsets.only(top: 4),
            child: Text(
              "${_formatCurrency(sales)} sales",
              style:
                  AppTextStyles.bodySecondary,
            ),
          ),
          children: [
            _buildCategoryDetails(
              sales: sales,
              items: items,
              profit: profit,
              stockValue: stockValue,
              isCompact: isCompact,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDetails({
    required double sales,
    required int items,
    required double profit,
    required double stockValue,
    required bool isCompact,
  }) {
    final metrics = [
      _CategoryMetric(
        label: "Sales",
        value: _formatCurrency(sales),
        icon: Icons.payments_outlined,
        color: AppColors.primary,
        backgroundColor:
            AppColors.primaryLight,
      ),
      _CategoryMetric(
        label: "Items Sold",
        value: _formatNumber(items),
        icon:
            Icons.shopping_cart_outlined,
        color: AppColors.info,
        backgroundColor:
            AppColors.infoLight,
      ),
      _CategoryMetric(
        label: "Profit",
        value: _formatCurrency(profit),
        icon: Icons.trending_up,
        color: AppColors.success,
        backgroundColor:
            AppColors.successLight,
      ),
      _CategoryMetric(
        label: "Stock Value",
        value: _formatCurrency(stockValue),
        icon: Icons.inventory_2_outlined,
        color: AppColors.inventory,
        backgroundColor:
            AppColors.inventory
                .withValues(alpha: 0.10),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth >= 700
                ? 4
                : constraints.maxWidth >= 450
                    ? 2
                    : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio:
                columns == 1 ? 4.0 : 2.4,
          ),
          itemBuilder: (context, index) {
            final metric = metrics[index];

            return Container(
              padding:
                  const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: metric.backgroundColor,
                borderRadius:
                    BorderRadius.circular(10),
                border: Border.all(
                  color: metric.color
                      .withValues(alpha: 0.12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    metric.icon,
                    color: metric.color,
                    size: 19,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          metric.label,
                          style:
                              AppTextStyles.small,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          metric.value,
                          style:
                              AppTextStyles.body.copyWith(
                            fontWeight:
                                FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // EXPORT
  // ============================================================

  Widget _buildExportSection({
    required List<Map<String, dynamic>>
        categories,
    required double totalSales,
    required double totalProfit,
    required int itemsSold,
    required double stockValue,
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
        borderRadius:
            BorderRadius.circular(16),
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
          final compact =
              constraints.maxWidth < 650;

          if (compact) {
            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _buildExportContent(),
                const SizedBox(height: 16),
                _buildExportButton(
                  categories: categories,
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
                categories: categories,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildExportContent() {
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
                "Export category report",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Generate a PDF containing category sales, items, profit and stock value.",
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

  Widget _buildExportButton({
    required List<Map<String, dynamic>>
        categories,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 13,
        ),
        shape: RoundedRectangleBorder(
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
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
      ),
      onPressed: () async {
        try {
          final range = _getRange();

          final file =
              await PdfReport.generateReport(
            title: "Category Report",
            sections: [
              {
                "title":
                    "Category Performance",
                "headers": [
                  "Category",
                  "Sales",
                  "Items Sold",
                  "Profit",
                  "Stock Value",
                ],
                "rows": categories.map(
                  (category) {
                    return [
                      category["categoryName"]
                              ?.toString() ??
                          "Unknown",
                      _formatCurrency(
                        _toDouble(
                          category[
                              "totalSales"],
                        ),
                      ),
                      _formatNumber(
                        _toInt(
                          category[
                              "itemsSold"],
                        ),
                      ),
                      _formatCurrency(
                        _toDouble(
                          category["profit"],
                        ),
                      ),
                      _formatCurrency(
                        _toDouble(
                          category[
                              "stockValue"],
                        ),
                      ),
                    ];
                  },
                ).toList(),
              },
              {
                "title": "Report Period",
                "headers": [
                  "Filter",
                  "Start",
                  "End",
                ],
                "rows": [
                  [
                    _filterLabel(),
                    _formatDate(
                      range.start,
                    ),
                    _formatDate(
                      range.end,
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
                "Unable to generate PDF: $e",
                style:
                    const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
              ),
            ),
          );
        }
      },
    );
  }

  // ============================================================
  // FILTER
  // ============================================================

  Widget _buildFilterDropdown() {
    return Container(
      height: 42,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius:
            BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedFilter,
          borderRadius:
              BorderRadius.circular(10),
          dropdownColor:
              AppColors.surface,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
            size: 20,
          ),
          style:
              AppTextStyles.bodySecondary.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          padding:
              const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          items: const [
            DropdownMenuItem(
              value: "Day",
              child: Text("Today"),
            ),
            DropdownMenuItem(
              value: "Week",
              child: Text("This Week"),
            ),
            DropdownMenuItem(
              value: "Month",
              child: Text("This Month"),
            ),
            DropdownMenuItem(
              value: "Year",
              child: Text("This Year"),
            ),
            DropdownMenuItem(
              value: "Custom",
              child: Text("Custom"),
            ),
          ],
          onChanged: (value) async {
            if (value == null) return;

            if (value == "Custom") {
              final now =
                  DateTime.now();

              final picked =
                  await showDateRangePicker(
                context: context,
                firstDate:
                    DateTime(2020),
                lastDate: now,
                initialDateRange:
                    _selectedDateRange ??
                        DateTimeRange(
                          start: DateTime(
                            now.year,
                            now.month,
                            now.day,
                          ).subtract(
                            const Duration(
                              days: 7,
                            ),
                          ),
                          end: DateTime(
                            now.year,
                            now.month,
                            now.day,
                          ),
                        ),
                builder:
                    (context, child) {
                  return Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(
                      colorScheme:
                          Theme.of(
                        context,
                      )
                              .colorScheme
                              .copyWith(
                            primary:
                                AppColors.primary,
                            surface:
                                AppColors.surface,
                          ),
                    ),
                    child: child!,
                  );
                },
              );

              if (!mounted) return;

              if (picked != null) {
                setState(() {
                  _selectedDateRange =
                      DateTimeRange(
                    start: DateTime(
                      picked.start.year,
                      picked.start.month,
                      picked.start.day,
                    ),
                    end: DateTime(
                      picked.end.year,
                      picked.end.month,
                      picked.end.day,
                    ).add(
                      const Duration(
                        days: 1,
                      ),
                    ),
                  );

                  _selectedFilter =
                      "Custom";
                });
              }

              return;
            }

            setState(() {
              _selectedFilter = value;
            });
          },
        ),
      ),
    );
  }

  // ============================================================
  // DATE RANGE
  // ============================================================

  DateTimeRange _getRange() {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    switch (_selectedFilter) {
      case "Day":
        return DateTimeRange(
          start: today,
          end: today.add(
            const Duration(days: 1),
          ),
        );

      case "Week":
        final start = today.subtract(
          Duration(days: now.weekday - 1),
        );

        return DateTimeRange(
          start: start,
          end: today.add(
            const Duration(days: 1),
          ),
        );

      case "Month":
        return DateTimeRange(
          start: DateTime(
            now.year,
            now.month,
            1,
          ),
          end: DateTime(
            now.year,
            now.month + 1,
            1,
          ),
        );

      case "Year":
        return DateTimeRange(
          start: DateTime(
            now.year,
            1,
            1,
          ),
          end: DateTime(
            now.year + 1,
            1,
            1,
          ),
        );

      case "Custom":
        return _selectedDateRange ??
            DateTimeRange(
              start: today.subtract(
                const Duration(days: 7),
              ),
              end: today.add(
                const Duration(days: 1),
              ),
            );

      default:
        return DateTimeRange(
          start: today,
          end: today.add(
            const Duration(days: 1),
          ),
        );
    }
  }

  String _filterLabel() {
    switch (_selectedFilter) {
      case "Day":
        return "Today";
      case "Week":
        return "This Week";
      case "Month":
        return "This Month";
      case "Year":
        return "This Year";
      case "Custom":
        return "Custom";
      default:
        return _selectedFilter;
    }
  }

  // ============================================================
  // FORMATTING
  // ============================================================

  String _formatCurrency(double value) {
    return "₦${_formatNumber(value.round())}";
  }

  String _formatNumber(num value) {
    final string = value
        .toInt()
        .toString();

    final buffer = StringBuffer();

    for (int i = 0;
        i < string.length;
        i++) {
      if (i > 0 &&
          (string.length - i) % 3 == 0) {
        buffer.write(",");
      }

      buffer.write(string[i]);
    }

    return buffer.toString();
  }

  String _formatDateRange(
    DateTimeRange range,
  ) {
    final start =
        _formatDate(range.start);

    if (_selectedFilter == "Day") {
      return start;
    }

    final endDate =
        range.end.subtract(
      const Duration(days: 1),
    );

    return "$start – ${_formatDate(endDate)}";
  }

  String _formatDate(DateTime date) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];

    return "${months[date.month - 1]} "
        "${date.day}, "
        "${date.year}";
  }

  double _toDouble(dynamic value) {
    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? "",
        ) ??
        0;
  }

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? "",
        ) ??
        0;
  }
}

// ============================================================
// MODELS
// ============================================================

class _OverviewCardData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const _OverviewCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });
}

class _CategoryMetric {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const _CategoryMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });
}

// ============================================================
// LOADING STATE
// ============================================================

class _CategoryLoadingState
    extends StatelessWidget {
  const _CategoryLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppColors.primary,
            ),
            SizedBox(height: 16),
            Text(
              "Loading category report...",
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
// EMPTY STATE
// ============================================================

class _CategoryEmptyState
    extends StatelessWidget {
  const _CategoryEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.category_outlined,
            size: 52,
            color: AppColors.textMuted,
          ),
          SizedBox(height: 14),
          Text(
            "No category data",
            style: AppTextStyles.title,
          ),
          SizedBox(height: 6),
          Text(
            "There are no category sales for the selected period.",
            style:
                AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ERROR STATE
// ============================================================

class _CategoryErrorState
    extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _CategoryErrorState({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding:
            const EdgeInsets.all(32),
        child: Container(
          constraints:
              const BoxConstraints(
            maxWidth: 600,
          ),
          padding:
              const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border,
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
                      AppColors.dangerLight,
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
              const SizedBox(height: 16),
              const Text(
                "Unable to load category report",
                style:
                    AppTextStyles.title,
                textAlign:
                    TextAlign.center,
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(14),
                decoration:
                    BoxDecoration(
                  color:
                      AppColors.surfaceSoft,
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
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
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
                icon: const Icon(
                  Icons.refresh,
                  size: 18,
                ),
                label: const Text(
                  "Try Again",
                  style: TextStyle(
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