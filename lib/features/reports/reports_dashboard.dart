// lib/features/reports/reports_dashboard.dart

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/theme/styles.dart';
import '../../database/app_database.dart';
import '../../database/business_settings.dart';
import '../../database/daos/attendance_dao.dart';
import '../../database/daos/product_dao.dart';
import '../../database/daos/sales_dao.dart';
import '../../database/daos/settings_dao.dart';
import '../../shared/pdf_report.dart';

import 'category_report_screen.dart';
import 'daily_report_service.dart';
import 'expiry_report_screen.dart';
import 'gross_revenue_report_screen.dart';
import 'items_sold_report_screen.dart';
import 'low_stock_report_screen.dart';
import 'out_of_stock_report_screen.dart';
import 'profit_report_screen.dart';
import 'reconciliation_screen.dart';
import 'salary_report_screen.dart';
import 'sales_reports_screen.dart';
import 'stock_value_report_screen.dart';

import 'widgets/category_performance_chart.dart';
import 'widgets/payment_breakdown_chart.dart';
import 'widgets/sales_trend_chart.dart';

class ReportsDashboard extends StatefulWidget {
  final SettingsDao settingsDao;

  const ReportsDashboard({super.key, required this.settingsDao});

  @override
  State<ReportsDashboard> createState() => _ReportsDashboardState();
}

class _ReportsDashboardState extends State<ReportsDashboard> {
  final db = getDatabase();

  late final SalesDao salesDao;
  late final ProductDao productDao;

  // ============================================================
  // REPORT SETTINGS
  // ============================================================

  bool _showProfit = true;
  bool _showStockValue = true;

  bool _showCharts = true;
  bool _showSalesTrend = true;
  bool _showPaymentBreakdown = true;
  bool _showCategoryPerformance = true;

  bool _showExport = true;

  bool _settingsLoading = true;

  // ============================================================
  // FILTER
  // ============================================================

  String _selectedFilter = 'Day';

  DateTimeRange? _selectedDateRange;

  // ============================================================
  // IMPORT
  // ============================================================

  Map<String, dynamic>? _importedReport;

  bool _importingReport = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    salesDao = SalesDao(db);
    productDao = ProductDao(db);

    _loadReportSettings();
  }

  // ============================================================
  // LOAD REPORT SETTINGS
  // ============================================================

  Future<void> _loadReportSettings() async {
    try {
      final defaultPeriod =
          await widget.settingsDao.getSetting(
            BusinessSettings.reportDefaultPeriod,
          ) ??
          'Day';

      final showProfit =
          await widget.settingsDao.getSetting(
            BusinessSettings.reportShowProfit,
          ) ??
          'true';

      final showStockValue =
          await widget.settingsDao.getSetting(
            BusinessSettings.reportShowStockValue,
          ) ??
          'true';

      final showCharts =
          await widget.settingsDao.getSetting(
            BusinessSettings.reportShowCharts,
          ) ??
          'true';

      final showSalesTrend =
          await widget.settingsDao.getSetting(
            BusinessSettings.reportShowSalesTrend,
          ) ??
          'true';

      final showPaymentBreakdown =
          await widget.settingsDao.getSetting(
            BusinessSettings.reportShowPaymentBreakdown,
          ) ??
          'true';

      final showCategoryPerformance =
          await widget.settingsDao.getSetting(
            BusinessSettings.reportShowCategoryPerformance,
          ) ??
          'true';

      final showExport =
          await widget.settingsDao.getSetting(
            BusinessSettings.reportShowExport,
          ) ??
          'true';

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedFilter =
            const [
              'Day',
              'Week',
              'Month',
              'Year',
              'Custom',
            ].contains(defaultPeriod)
            ? defaultPeriod
            : 'Day';

        _showProfit = _parseBool(showProfit, true);
        _showStockValue = _parseBool(showStockValue, true);
        _showCharts = _parseBool(showCharts, true);
        _showSalesTrend = _parseBool(showSalesTrend, true);
        _showPaymentBreakdown = _parseBool(showPaymentBreakdown, true);
        _showCategoryPerformance = _parseBool(showCategoryPerformance, true);
        _showExport = _parseBool(showExport, true);

        _settingsLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _settingsLoading = false;
      });
    }
  }

  // ============================================================
  // BOOLEAN PARSER
  // ============================================================

  bool _parseBool(String? value, bool defaultValue) {
    if (value == null) {
      return defaultValue;
    }

    return value.trim().toLowerCase() == 'true';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (_settingsLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final range = _getRange();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          salesDao.getTotalSales(range.start, range.end),
          salesDao.getItemsSold(range.start, range.end),
          salesDao.getProfit(range.start, range.end),
          salesDao.getPaymentBreakdown(range.start, range.end),
          salesDao.getCategorySummary(range.start, range.end),
          salesDao.getSalesTrend(range.start, range.end),
          salesDao.getTotalStockValue(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _ReportsLoadingState();
          }

          if (snapshot.hasError) {
            return _ReportsErrorState(
              error: snapshot.error.toString(),
              onRetry: () {
                setState(() {});
              },
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const _ReportsEmptyState();
          }

          final data = snapshot.data!;

          final totalSales = _toDouble(data[0]);
          final itemsSold = _toInt(data[1]);
          final profit = _toDouble(data[2]);

          final paymentBreakdown = _toDoubleMap(data[3]);

          final categorySummary = _toMapList(data[4]);

          final salesTrend = _toMapList(data[5]);

          final stockValue = _toDouble(data[6]);

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            onRefresh: () async {
              setState(() {});
              await Future<void>.delayed(const Duration(milliseconds: 250));
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                final contentWidth = constraints.maxWidth;

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    _pageHorizontalPadding(contentWidth),
                    20,
                    _pageHorizontalPadding(contentWidth),
                    32,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1400),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPageHeader(range, contentWidth),

                          const SizedBox(height: 24),

                          _buildOverviewSection(
                            totalSales: totalSales,
                            itemsSold: itemsSold,
                            profit: profit,
                            stockValue: stockValue,
                            availableWidth: contentWidth,
                          ),

                          if (_showCharts) ...[
                            const SizedBox(height: 30),

                            _buildSectionHeader(
                              title: 'Sales analytics',
                              subtitle:
                                  'Performance overview for the selected period',
                              icon: Icons.insights_outlined,
                            ),

                            const SizedBox(height: 14),

                            _buildChartsSection(
                              salesTrend: salesTrend,
                              paymentBreakdown: paymentBreakdown,
                              categorySummary: categorySummary,
                              availableWidth: contentWidth,
                            ),
                          ],

                          const SizedBox(height: 32),

                          _buildSectionHeader(
                            title: 'Reports',
                            subtitle: 'Detailed business reports',
                            icon: Icons.description_outlined,
                          ),

                          const SizedBox(height: 14),

                          _buildReportsGrid(
                            totalSales: totalSales,
                            profit: profit,
                            stockValue: stockValue,
                            categoryCount: categorySummary.length,
                          ),

                          if (_showExport) ...[
                            const SizedBox(height: 32),

                            _buildExportSection(
                              totalSales: totalSales,
                              itemsSold: itemsSold,
                              profit: profit,
                              paymentBreakdown: paymentBreakdown,
                              categorySummary: categorySummary,
                              salesTrend: salesTrend,
                            ),
                          ],

                          const SizedBox(height: 24),

                          _buildImportSection(),

                          const SizedBox(height: 4),
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
  // RESPONSIVE HELPERS
  // ============================================================

  double _pageHorizontalPadding(double width) {
    if (width < 380) {
      return 12;
    }

    if (width < 600) {
      return 16;
    }

    if (width < 900) {
      return 20;
    }

    if (width < 1200) {
      return 24;
    }

    return 28;
  }

  bool _isPhone(double width) {
    return width < 600;
  }

  bool _isTablet(double width) {
    return width >= 600 && width < 1100;
  }

  bool _isDesktop(double width) {
    return width >= 1100;
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: true,
      toolbarHeight: 64,
      titleSpacing: 14,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.analytics_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          const Flexible(
            child: Text(
              'Reports & Analytics',
              style: AppTextStyles.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: _buildFilterDropdown(),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.divider),
      ),
    );
  }

  // ============================================================
  // FILTER DROPDOWN
  // ============================================================

  Widget _buildFilterDropdown() {
    return SizedBox(
      width: 128,
      height: 40,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedFilter,
            isExpanded: true,
            borderRadius: BorderRadius.circular(10),
            dropdownColor: AppColors.surface,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
            style: AppTextStyles.bodySecondary.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 7),
            selectedItemBuilder: (context) {
              return const [
                Align(alignment: Alignment.centerLeft, child: Text('Today')),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('This Week'),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('This Month'),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('This Year'),
                ),
                Align(alignment: Alignment.centerLeft, child: Text('Custom')),
              ];
            },
            items: const [
              DropdownMenuItem<String>(
                value: 'Day',
                child: Text('Today', overflow: TextOverflow.ellipsis),
              ),
              DropdownMenuItem<String>(
                value: 'Week',
                child: Text('This Week', overflow: TextOverflow.ellipsis),
              ),
              DropdownMenuItem<String>(
                value: 'Month',
                child: Text('This Month', overflow: TextOverflow.ellipsis),
              ),
              DropdownMenuItem<String>(
                value: 'Year',
                child: Text('This Year', overflow: TextOverflow.ellipsis),
              ),
              DropdownMenuItem<String>(
                value: 'Custom',
                child: Text('Custom', overflow: TextOverflow.ellipsis),
              ),
            ],
            onChanged: (String? value) async {
              if (value == null) {
                return;
              }

              if (value == 'Custom') {
                await _selectCustomDateRange();
                return;
              }

              if (!mounted) {
                return;
              }

              setState(() {
                _selectedFilter = value;
              });
            },
          ),
        ),
      ),
    );
  }

  Future<void> _selectCustomDateRange() async {
    final now = DateTime.now();

    final initialRange =
        _selectedDateRange ??
        DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: initialRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted) {
      return;
    }

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _selectedFilter = 'Custom';
      });
    }
  }

  // ============================================================
  // PAGE HEADER
  // ============================================================

  Widget _buildPageHeader(DateTimeRange range, double width) {
    final phone = _isPhone(width);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(phone ? 16 : 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business overview',
            style: phone ? AppTextStyles.title : AppTextStyles.heading,
          ),
          const SizedBox(height: 6),
          const Text(
            'Monitor sales, profit, inventory and business performance.',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 12),
          Container(
            constraints: const BoxConstraints(maxWidth: 520),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    _formatDateRange(range),
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
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
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.title),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.small,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // OVERVIEW
  // ============================================================

  Widget _buildOverviewSection({
    required double totalSales,
    required int itemsSold,
    required double profit,
    required double stockValue,
    required double availableWidth,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Overview', style: AppTextStyles.title),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = <Widget>[
              _metricCard(
                title: 'Total Sales',
                value: _formatCurrency(totalSales),
                icon: Icons.payments_outlined,
                color: AppColors.primary,
                backgroundColor: AppColors.primaryLight,
              ),
              _metricCard(
                title: 'Items Sold',
                value: _formatNumber(itemsSold),
                icon: Icons.shopping_cart_outlined,
                color: AppColors.info,
                backgroundColor: AppColors.infoLight,
              ),
              if (_showProfit)
                _metricCard(
                  title: 'Profit',
                  value: _formatCurrency(profit),
                  icon: Icons.trending_up,
                  color: AppColors.success,
                  backgroundColor: AppColors.successLight,
                ),
              if (_showStockValue)
                _metricCard(
                  title: 'Stock Value',
                  value: _formatCurrency(stockValue),
                  icon: Icons.inventory_2_outlined,
                  color: AppColors.inventory,
                  backgroundColor: AppColors.infoLight,
                ),
            ];

            if (cards.isEmpty) {
              return const SizedBox.shrink();
            }

            final width = constraints.maxWidth;

            if (width < 560) {
              return Column(
                children: [
                  for (int i = 0; i < cards.length; i++) ...[
                    cards[i],
                    if (i < cards.length - 1) const SizedBox(height: 10),
                  ],
                ],
              );
            }

            final columns = width < 900
                ? 2
                : cards.length >= 4
                ? 4
                : cards.length;

            final spacing = width < 900 ? 10.0 : 14.0;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cards.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                mainAxisExtent: width < 900 ? 100 : 104,
              ),
              itemBuilder: (context, index) {
                return cards[index];
              },
            );
          },
        ),
      ],
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodySecondary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.price,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CHARTS
  // ============================================================

  Widget _buildChartsSection({
    required List<Map<String, dynamic>> salesTrend,
    required Map<String, double> paymentBreakdown,
    required List<Map<String, dynamic>> categorySummary,
    required double availableWidth,
  }) {
    final phone = _isPhone(availableWidth);

    final tablet = _isTablet(availableWidth);

    final salesChart = _showSalesTrend
        ? _chartCard(
            title: 'Sales trend',
            subtitle: 'Sales performance over the selected period',
            icon: Icons.show_chart,
            iconColor: AppColors.primary,
            child: SalesTrendChart(salesTrend: salesTrend),
            height: phone
                ? 285
                : tablet
                ? 310
                : 330,
          )
        : null;

    final paymentChart = _showPaymentBreakdown
        ? _chartCard(
            title: 'Payment breakdown',
            subtitle: 'How customers paid',
            icon: Icons.account_balance_wallet_outlined,
            iconColor: AppColors.success,
            child: PaymentBreakdownChart(paymentBreakdown: paymentBreakdown),
            height: phone
                ? 285
                : tablet
                ? 300
                : 310,
          )
        : null;

    final categoryChart = _showCategoryPerformance
        ? _chartCard(
            title: 'Category performance',
            subtitle: 'Sales by category',
            icon: Icons.category_outlined,
            iconColor: AppColors.accent,
            child: CategoryPerformanceChart(categorySummary: categorySummary),
            height: phone
                ? 285
                : tablet
                ? 300
                : 310,
          )
        : null;

    final lowerCharts = <Widget>[
      if (paymentChart != null) paymentChart,
      if (categoryChart != null) categoryChart,
    ];

    if (salesChart == null && lowerCharts.isEmpty) {
      return const SizedBox.shrink();
    }

    if (availableWidth < 1050) {
      final allCharts = <Widget>[
        if (salesChart != null) salesChart,
        ...lowerCharts,
      ];

      return Column(
        children: [
          for (int i = 0; i < allCharts.length; i++) ...[
            allCharts[i],
            if (i < allCharts.length - 1) const SizedBox(height: 14),
          ],
        ],
      );
    }

    return Column(
      children: [
        if (salesChart != null) ...[
          salesChart,
          if (lowerCharts.isNotEmpty) const SizedBox(height: 14),
        ],
        if (lowerCharts.length == 1) lowerCharts.first,
        if (lowerCharts.length == 2)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: lowerCharts[0]),
              const SizedBox(width: 14),
              Expanded(child: lowerCharts[1]),
            ],
          ),
      ],
    );
  }

  Widget _chartCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Widget child,
    required double height,
  }) {
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: iconColor, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.title.copyWith(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.small,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(child: ClipRect(child: child)),
        ],
      ),
    );
  }

  // ============================================================
  // REPORTS
  // ============================================================

  Widget _buildReportsGrid({
    required double totalSales,
    required double profit,
    required double stockValue,
    required int categoryCount,
  }) {
    final cards = <_ReportCardData>[
      _ReportCardData(
        title: 'Sales Report',
        subtitle: _formatCurrency(totalSales),
        description: 'Review sales transactions',
        icon: Icons.receipt_long_outlined,
        color: AppColors.sales,
        screen: const SalesReportScreen(),
      ),
      const _ReportCardData(
        title: 'Gross Revenue',
        subtitle: 'Revenue report',
        description: 'Review total revenue',
        icon: Icons.account_balance_outlined,
        color: AppColors.primary,
        screen: GrossRevenueReportScreen(),
      ),
      const _ReportCardData(
        title: 'Items Sold',
        subtitle: 'Quantity report',
        description: 'Review products sold',
        icon: Icons.shopping_cart_outlined,
        color: AppColors.info,
        screen: ItemsSoldReportScreen(),
      ),
      if (_showProfit)
        _ReportCardData(
          title: 'Profit Report',
          subtitle: _formatCurrency(profit),
          description: 'Profitability for selected period',
          icon: Icons.trending_up,
          color: AppColors.profit,
          screen: const ProfitReportScreen(),
        ),
      _ReportCardData(
        title: 'Category Report',
        subtitle: '$categoryCount categories',
        description: 'Analyze category performance',
        icon: Icons.category_outlined,
        color: AppColors.products,
        screen: const CategoryReportScreen(),
      ),
      if (_showStockValue)
        _ReportCardData(
          title: 'Stock Value',
          subtitle: _formatCurrency(stockValue),
          description: 'Current inventory value',
          icon: Icons.inventory_2_outlined,
          color: AppColors.inventory,
          screen: const StockValueReportScreen(),
        ),
      const _ReportCardData(
        title: 'Low Stock',
        subtitle: 'Inventory alert',
        description: 'Items below stock level',
        icon: Icons.warning_amber_rounded,
        color: AppColors.warning,
        screen: LowStockReportScreen(),
      ),
      const _ReportCardData(
        title: 'Out of Stock',
        subtitle: 'Critical inventory',
        description: 'Items requiring restock',
        icon: Icons.remove_shopping_cart_outlined,
        color: AppColors.danger,
        screen: OutOfStockReportScreen(),
      ),
      _ReportCardData(
        title: 'Reconciliation',
        subtitle: 'Daily stock check',
        description: 'Compare expected vs actual',
        icon: Icons.fact_check_outlined,
        color: AppColors.primary,
        screen: ReconciliationScreen(
          productDao: productDao,
          date: DateTime.now(),
        ),
      ),
      const _ReportCardData(
        title: 'Salary Report',
        subtitle: 'Staff payroll',
        description: 'Salaries and outstanding debts',
        icon: Icons.badge_outlined,
        color: AppColors.products,
        screen: SalaryReportScreen(),
      ),
      const _ReportCardData(
        title: 'Expiry Report',
        subtitle: 'Expiry monitoring',
        description: 'Products nearing expiry',
        icon: Icons.schedule_outlined,
        color: AppColors.danger,
        screen: ExpiryReportScreen(),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final int columns;

        if (width < 520) {
          columns = 1;
        } else if (width < 820) {
          columns = 2;
        } else if (width < 1150) {
          columns = 3;
        } else {
          columns = 4;
        }

        final cardHeight = columns == 1
            ? 94.0
            : columns == 2
            ? 108.0
            : 116.0;

        final spacing = columns == 1 ? 10.0 : 13.0;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            mainAxisExtent: cardHeight,
          ),
          itemBuilder: (context, index) {
            return _buildReportCard(cards[index]);
          },
        );
      },
    );
  }

  Widget _buildReportCard(_ReportCardData data) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => data.screen),
          );
        },
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x05000000),
                blurRadius: 7,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: data.color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(data.icon, color: data.color, size: 21),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: AppTextStyles.title.copyWith(fontSize: 13.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        data.subtitle,
                        style: AppTextStyles.bodySecondary.copyWith(
                          color: data.color,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data.description,
                        style: AppTextStyles.small.copyWith(fontSize: 10.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EXPORT SECTION
  // ============================================================

  Widget _buildExportSection({
    required double totalSales,
    required int itemsSold,
    required double profit,
    required Map<String, double> paymentBreakdown,
    required List<Map<String, dynamic>> categorySummary,
    required List<Map<String, dynamic>> salesTrend,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
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
          final compact = constraints.maxWidth < 820;

          final buttons = _exportButtons(
            totalSales: totalSales,
            itemsSold: itemsSold,
            profit: profit,
            paymentBreakdown: paymentBreakdown,
            categorySummary: categorySummary,
            salesTrend: salesTrend,
            compact: compact,
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_exportContent(), const SizedBox(height: 16), buttons],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _exportContent()),
              const SizedBox(width: 22),
              buttons,
            ],
          );
        },
      ),
    );
  }

  Widget _exportButtons({
    required double totalSales,
    required int itemsSold,
    required double profit,
    required Map<String, double> paymentBreakdown,
    required List<Map<String, dynamic>> categorySummary,
    required List<Map<String, dynamic>> salesTrend,
    required bool compact,
  }) {
    final pdfButton = ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        minimumSize: const Size(0, 46),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: const Icon(Icons.picture_as_pdf_outlined, size: 19),
      label: const Text(
        'Export Dashboard PDF',
        style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
      ),
      onPressed: () async {
        try {
          final file = await PdfReport.generateDashboardReport(
            totalSales: totalSales,
            itemsSold: itemsSold,
            profit: profit,
            paymentBreakdown: paymentBreakdown,
            categorySummary: categorySummary,
            salesTrend: salesTrend,
          );

          if (!mounted) {
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.success,
              content: Text(
                'Dashboard PDF saved at ${file.path}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
              ),
            ),
          );
        } catch (e) {
          if (!mounted) {
            return;
          }

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
      },
    );

    final jsonButton = ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        minimumSize: const Size(0, 46),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: const Icon(Icons.data_object_outlined, size: 19),
      label: const Text(
        'Export Daily JSON',
        style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
      ),
      onPressed: () async {
        try {
          final service = DailyReportService(
            salesDao: salesDao,
            productDao: productDao,
            attendanceDao: AttendanceDao(db),
            settingsDao: widget.settingsDao,
          );

          final file = await service.exportDailyReport();

          if (!mounted) {
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.success,
              content: Text(
                'Daily JSON saved at ${file.path}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
              ),
            ),
          );
        } catch (e) {
          if (!mounted) {
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.danger,
              content: Text(
                'Unable to export JSON: $e',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
              ),
            ),
          );
        }
      },
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [pdfButton, const SizedBox(height: 9), jsonButton],
      );
    }

    return Wrap(
      spacing: 9,
      runSpacing: 9,
      alignment: WrapAlignment.end,
      children: [pdfButton, jsonButton],
    );
  }

  Widget _exportContent() {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.file_download_outlined, color: Colors.white, size: 29),
        SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Export your dashboard',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Generate a PDF containing your sales, profit, payment and category analytics.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white70,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // IMPORT SECTION
  // ============================================================

  Widget _buildImportSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accent, AppColors.accentDark],
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
          final compact = constraints.maxWidth < 820;

          final button = _importButton();

          final viewButton = _importedReport != null
              ? _buildViewImportedButton()
              : null;

          // ======================================================
          // COMPACT / NARROW LAYOUT
          // ======================================================

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _importContent(),
                const SizedBox(height: 16),
                button,
                if (viewButton != null) ...[
                  const SizedBox(height: 9),
                  viewButton,
                ],
              ],
            );
          }

          // ======================================================
          // DESKTOP / WIDE LAYOUT
          // ======================================================

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _importContent()),

              const SizedBox(width: 22),

              // Give the button area an explicit finite width.
              SizedBox(
                width: 190,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    button,
                    if (viewButton != null) ...[
                      const SizedBox(height: 9),
                      viewButton,
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _importContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(
            Icons.file_open_outlined,
            color: Colors.white,
            size: 23,
          ),
        ),
        const SizedBox(width: 13),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Import Daily Report',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Load a JSON snapshot exported by managers to view sales, profit, and attendance.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white70,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _importButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.accent,
        elevation: 0,
        minimumSize: const Size(0, 46),
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: _importingReport
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accent,
              ),
            )
          : const Icon(Icons.file_open_outlined, size: 19),
      label: Text(
        _importingReport ? 'Loading Report...' : 'Select Report File',
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
      ),
      onPressed: _importingReport ? null : _pickDailyReport,
    );
  }

  Widget _buildViewImportedButton() {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white, width: 1.2),
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: const Icon(Icons.visibility_outlined, size: 18),
      label: const Text(
        'View Imported Report',
        style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
      ),
      onPressed: _importedReport == null
          ? null
          : () {
              _showImportedOverviewPopup(_importedReport!);
            },
    );
  }

  // ============================================================
  // PICK / IMPORT REPORT
  // ============================================================

  Future<void> _pickDailyReport() async {
    try {
      setState(() {
        _importingReport = true;
      });

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) {
        if (mounted) {
          setState(() {
            _importingReport = false;
          });
        }
        return;
      }

      final file = File(result.files.single.path!);

      final content = await file.readAsString();

      final decoded = jsonDecode(content);

      if (decoded is! Map) {
        throw const FormatException(
          'The selected file does not contain a valid report object.',
        );
      }

      final report = Map<String, dynamic>.from(decoded);

      _validateImportedReport(report);

      if (!mounted) {
        return;
      }

      setState(() {
        _importedReport = report;
        _importingReport = false;
      });

      _showImportedOverviewPopup(report);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _importingReport = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
          content: Text(
            'Unable to import report: $e',
            style: const TextStyle(fontFamily: 'Poppins', color: Colors.white),
          ),
        ),
      );
    }
  }

  void _validateImportedReport(Map<String, dynamic> report) {
    if (!report.containsKey('metrics')) {
      throw const FormatException('The report is missing the metrics section.');
    }

    if (!report.containsKey('business')) {
      throw const FormatException(
        'The report is missing the business section.',
      );
    }

    if (report['metrics'] is! Map) {
      throw const FormatException('The report metrics section is invalid.');
    }

    if (report['business'] is! Map) {
      throw const FormatException('The report business section is invalid.');
    }
  }

  // ============================================================
  // IMPORTED REPORT POPUP
  // ============================================================

  void _showImportedOverviewPopup(Map<String, dynamic> report) {
    final rawMetrics = report['metrics'];

    final rawBusiness = report['business'];

    if (rawMetrics is! Map || rawBusiness is! Map) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
          content: Text('Invalid imported report format.'),
        ),
      );
      return;
    }

    final metrics = Map<String, dynamic>.from(rawMetrics);

    final business = Map<String, dynamic>.from(rawBusiness);

    final businessName = business['name']?.toString().trim().isNotEmpty == true
        ? business['name'].toString()
        : 'Business';

    final reportDate = report['date']?.toString().trim().isNotEmpty == true
        ? report['date'].toString()
        : 'Daily snapshot';

    showDialog(
      context: context,
      builder: (dialogContext) {
        final screenWidth = MediaQuery.of(dialogContext).size.width;

        final screenHeight = MediaQuery.of(dialogContext).size.height;

        final dialogPadding = screenWidth < 500 ? 14.0 : 20.0;

        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: screenWidth < 500 ? 10 : 16,
            vertical: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 760,
              maxHeight: screenHeight * 0.90,
            ),
            child: Container(
              padding: EdgeInsets.all(dialogPadding),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.accentLight,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(
                            Icons.description_outlined,
                            color: AppColors.accent,
                            size: 23,
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$businessName — Daily Snapshot',
                                style: AppTextStyles.heading.copyWith(
                                  fontSize: screenWidth < 500 ? 17 : 18,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(reportDate, style: AppTextStyles.small),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () => Navigator.of(dialogContext).pop(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Imported report snapshot. This does not modify your current database.',
                              style: AppTextStyles.small,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth < 500 ? 1 : 2;

                        return GridView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                mainAxisExtent: columns == 1 ? 92 : 98,
                              ),
                          children: [
                            _importedMetricCard(
                              title: 'Total Sales',
                              value: _formatImportedCurrency(
                                metrics['sales_total'],
                              ),
                              icon: Icons.payments_outlined,
                              color: AppColors.primary,
                              backgroundColor: AppColors.primaryLight,
                            ),
                            _importedMetricCard(
                              title: 'Items Sold',
                              value: _formatImportedNumber(
                                metrics['items_sold'],
                              ),
                              icon: Icons.shopping_cart_outlined,
                              color: AppColors.info,
                              backgroundColor: AppColors.infoLight,
                            ),
                            _importedMetricCard(
                              title: 'Profit',
                              value: _formatImportedCurrency(metrics['profit']),
                              icon: Icons.trending_up,
                              color: AppColors.success,
                              backgroundColor: AppColors.successLight,
                            ),
                            _importedMetricCard(
                              title: 'Attendance',
                              value: _formatImportedNumber(
                                metrics['attendance_count'],
                              ),
                              icon: Icons.people_alt_outlined,
                              color: AppColors.accent,
                              backgroundColor: AppColors.accentLight,
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size(0, 46),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _importedMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.small,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: AppTextStyles.price.copyWith(fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatImportedCurrency(dynamic value) {
    return _formatCurrency(_toDouble(value));
  }

  String _formatImportedNumber(dynamic value) {
    return _formatNumber(_toInt(value));
  }

  // ============================================================
  // DATE RANGE
  // ============================================================

  DateTimeRange _getRange() {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    switch (_selectedFilter) {
      case 'Day':
        return DateTimeRange(
          start: today,
          end: today.add(const Duration(days: 1)),
        );

      case 'Week':
        final start = today.subtract(Duration(days: today.weekday - 1));

        return DateTimeRange(
          start: start,
          end: start.add(const Duration(days: 7)),
        );

      case 'Month':
        final start = DateTime(now.year, now.month, 1);

        final end = DateTime(now.year, now.month + 1, 1);

        return DateTimeRange(start: start, end: end);

      case 'Year':
        final start = DateTime(now.year, 1, 1);

        final end = DateTime(now.year + 1, 1, 1);

        return DateTimeRange(start: start, end: end);

      case 'Custom':
        if (_selectedDateRange == null) {
          final start = today.subtract(const Duration(days: 7));

          return DateTimeRange(
            start: start,
            end: today.add(const Duration(days: 1)),
          );
        }

        final selected = _selectedDateRange!;

        final start = DateTime(
          selected.start.year,
          selected.start.month,
          selected.start.day,
        );

        final end = DateTime(
          selected.end.year,
          selected.end.month,
          selected.end.day,
        ).add(const Duration(days: 1));

        return DateTimeRange(start: start, end: end);

      default:
        return DateTimeRange(
          start: today,
          end: today.add(const Duration(days: 1)),
        );
    }
  }

  String _formatDateRange(DateTimeRange range) {
    if (_selectedFilter == 'Day') {
      return _formatDate(range.start);
    }

    final displayEnd = range.end.subtract(const Duration(days: 1));

    return '${_formatDate(range.start)} – ${_formatDate(displayEnd)}';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
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

  // ============================================================
  // DAO RESULT NORMALIZATION
  // ============================================================

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

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Map<String, double> _toDoubleMap(dynamic value) {
    if (value is! Map) {
      return {};
    }

    return value.map((key, value) {
      return MapEntry(key.toString(), _toDouble(value));
    });
  }

  List<Map<String, dynamic>> _toMapList(dynamic value) {
    if (value is! List) {
      return [];
    }

    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}

// ============================================================
// REPORT CARD MODEL
// ============================================================

class _ReportCardData {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final Widget screen;

  const _ReportCardData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.screen,
  });
}

// ============================================================
// LOADING
// ============================================================

class _ReportsLoadingState extends StatelessWidget {
  const _ReportsLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 15),
            Text('Loading reports...', style: AppTextStyles.bodySecondary),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY
// ============================================================

class _ReportsEmptyState extends StatelessWidget {
  const _ReportsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 460),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 52,
                color: AppColors.textMuted,
              ),
              SizedBox(height: 15),
              Text(
                'No report data available',
                style: AppTextStyles.title,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6),
              Text(
                'There is currently no data to display.',
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ERROR
// ============================================================

class _ReportsErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ReportsErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.dangerLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: AppColors.danger,
                  size: 29,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Unable to load reports',
                style: AppTextStyles.title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 180),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(error, style: AppTextStyles.small),
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(0, 46),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.refresh, size: 18),
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
