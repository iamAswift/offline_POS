
// lib/features/reports/reports_dashboard.dart

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';


import '../../core/theme/styles.dart';
import '../../database/app_database.dart';
import '../../database/daos/product_dao.dart';
import '../../database/daos/sales_dao.dart';
import '../../shared/pdf_report.dart';

import 'category_report_screen.dart';
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

import '../../database/business_settings.dart';
import '../../database/daos/settings_dao.dart';
import '../../database/daos/attendance_dao.dart';


import 'daily_report_service.dart';

class ReportsDashboard extends StatefulWidget {
  final SettingsDao settingsDao;

  const ReportsDashboard({
    super.key,
    required this.settingsDao,
  });

  @override
  State<ReportsDashboard> createState() =>
      _ReportsDashboardState();
}

class _ReportsDashboardState
    extends State<ReportsDashboard> {
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
        // --------------------------------------------------------
        // DEFAULT PERIOD
        // --------------------------------------------------------

        _selectedFilter = const [
          'Day',
          'Week',
          'Month',
          'Year',
        ].contains(defaultPeriod)
            ? defaultPeriod
            : 'Day';

        // --------------------------------------------------------
        // VISIBILITY SETTINGS
        // --------------------------------------------------------

        _showProfit =
            _parseBool(showProfit, true);

        _showStockValue =
            _parseBool(showStockValue, true);

        _showCharts =
            _parseBool(showCharts, true);

        _showSalesTrend =
            _parseBool(showSalesTrend, true);

        _showPaymentBreakdown =
            _parseBool(
          showPaymentBreakdown,
          true,
        );

        _showCategoryPerformance =
            _parseBool(
          showCategoryPerformance,
          true,
        );

        _showExport =
            _parseBool(showExport, true);

        _settingsLoading = false;
      });
    } catch (e) {
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

  bool _parseBool(
    String? value,
    bool defaultValue,
  ) {
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
          child: CircularProgressIndicator(),
        ),
      );
    }

    final range = _getRange();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          // ======================================================
          // SELECTED-PERIOD SALES
          // ======================================================

          salesDao.getTotalSales(
            range.start,
            range.end,
          ),

          // ======================================================
          // SELECTED-PERIOD ITEMS SOLD
          // ======================================================

          salesDao.getItemsSold(
            range.start,
            range.end,
          ),

          // ======================================================
          // SELECTED-PERIOD PROFIT
          // ======================================================

          salesDao.getProfit(
            range.start,
            range.end,
          ),

          // ======================================================
          // SELECTED-PERIOD PAYMENT BREAKDOWN
          // ======================================================

          salesDao.getPaymentBreakdown(
            range.start,
            range.end,
          ),

          // ======================================================
          // SELECTED-PERIOD CATEGORY SUMMARY
          // ======================================================

          salesDao.getCategorySummary(
            range.start,
            range.end,
          ),

          // ======================================================
          // SELECTED-PERIOD SALES TREND
          // ======================================================

          salesDao.getSalesTrend(
            range.start,
            range.end,
          ),

          // ======================================================
          // CURRENT INVENTORY VALUE
          //
          // Intentionally NOT date filtered.
          // ======================================================

          salesDao.getTotalStockValue(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
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

          if (!snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const _ReportsEmptyState();
          }

          final data = snapshot.data!;

          // ======================================================
          // NORMALIZE DAO RESULTS
          // ======================================================

          final totalSales =
              _toDouble(data[0]);

          final itemsSold =
              _toInt(data[1]);

          final profit =
              _toDouble(data[2]);

          final paymentBreakdown =
              _toDoubleMap(data[3]);

          final categorySummary =
              _toMapList(data[4]);

          final salesTrend =
              _toMapList(data[5]);

          final stockValue =
              _toDouble(data[6]);

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              setState(() {});
            },
            child: LayoutBuilder(
              builder: (
                context,
                constraints,
              ) {
                final contentWidth =
                    constraints.maxWidth;

                return SingleChildScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        _pageHorizontalPadding(
                      contentWidth,
                    ),
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
                          // ==================================================
                          // PAGE HEADER
                          // ==================================================

                          _buildPageHeader(range),

                          const SizedBox(height: 26),

                          // ==================================================
                          // OVERVIEW
                          // ==================================================

                          _buildOverviewSection(
                            totalSales: totalSales,
                            itemsSold: itemsSold,
                            profit: profit,
                            stockValue: stockValue,
                          ),

                          // ==================================================
                          // ANALYTICS
                          //
                          // Entire section controlled by
                          // reportShowCharts.
                          // ==================================================

                          if (_showCharts) ...[
                            const SizedBox(height: 32),

                            _buildAnalyticsHeader(),

                            const SizedBox(height: 14),

                            _buildChartsSection(
                              salesTrend:
                                  salesTrend,
                              paymentBreakdown:
                                  paymentBreakdown,
                              categorySummary:
                                  categorySummary,
                              availableWidth:
                                  contentWidth,
                            ),
                          ],

                          // ==================================================
                          // REPORTS
                          // ==================================================

                          const SizedBox(height: 34),

                          _buildReportsHeader(),

                          const SizedBox(height: 14),

                          _buildReportsGrid(
                            totalSales:
                                totalSales,
                            profit:
                                profit,
                            stockValue:
                                stockValue,
                            categoryCount:
                                categorySummary.length,
                          ),

                          // ==================================================
                          // EXPORT
                          //
                          // Controlled by reportShowExport.
                          // ==================================================

                          if (_showExport) ...[
                            const SizedBox(height: 34),

                            _buildExportSection(
                              totalSales:
                                  totalSales,
                              itemsSold:
                                  itemsSold,
                              profit:
                                  profit,
                              paymentBreakdown:
                                  paymentBreakdown,
                              categorySummary:
                                  categorySummary,
                              salesTrend:
                                  salesTrend,
                            ),
                          ],

                          // Import section (for owners)
                          const SizedBox(height: 34),
                          _buildImportSection(),

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
  // RESPONSIVE
  // ============================================================

  double _pageHorizontalPadding(
    double width,
  ) {
    if (width < 420) {
      return 14;
    }

    if (width < 700) {
      return 16;
    }

    if (width < 1000) {
      return 22;
    }

    if (width < 1400) {
      return 28;
    }

    return 32;
  }

  bool _isPhone(double width) {
    return width < 600;
  }

  bool _isTabletLandscape(double width) {
    return width >= 900 && width < 1200;
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      foregroundColor:
          AppColors.textPrimary,
      elevation: 0,
      surfaceTintColor:
          Colors.transparent,
      automaticallyImplyLeading: true,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  AppColors.primaryLight,
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.analytics_outlined,
              color:
                  AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          const Flexible(
            child: Text(
              'Reports & Analytics',
              style:
                  AppTextStyles.title,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding:
              const EdgeInsets.only(
            right: 12,
          ),
          child:
              _buildFilterDropdown(),
        ),
      ],
      bottom: PreferredSize(
        preferredSize:
            const Size.fromHeight(1),
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

  Widget _buildPageHeader(
    DateTimeRange range,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Business overview',
          style: AppTextStyles.heading,
        ),
        const SizedBox(height: 6),
        const Text(
          'Monitor sales, profit, inventory and business performance.',
          style:
              AppTextStyles.bodySecondary,
        ),
        const SizedBox(height: 10),
        Wrap(
          crossAxisAlignment:
              WrapCrossAlignment.center,
          spacing: 6,
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 14,
              color:
                  AppColors.textMuted,
            ),
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

  Widget _buildOverviewSection({
    required double totalSales,
    required int itemsSold,
    required double profit,
    required double stockValue,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: AppTextStyles.title,
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final cards = [
              // --------------------------------------------------
              // TOTAL SALES
              // --------------------------------------------------

              _metricCard(
                title: 'Total Sales',
                value:
                    _formatCurrency(
                  totalSales,
                ),
                icon:
                    Icons.payments_outlined,
                color:
                    AppColors.primary,
                backgroundColor:
                    AppColors.primaryLight,
              ),

              // --------------------------------------------------
              // ITEMS SOLD
              // --------------------------------------------------

              _metricCard(
                title: 'Items Sold',
                value:
                    _formatNumber(
                  itemsSold,
                ),
                icon:
                    Icons.shopping_cart_outlined,
                color:
                    AppColors.info,
                backgroundColor:
                    AppColors.infoLight,
              ),

              // --------------------------------------------------
              // PROFIT
              //
              // Controlled by reportShowProfit.
              // --------------------------------------------------

              if (_showProfit)
                _metricCard(
                  title: 'Profit',
                  value:
                      _formatCurrency(
                    profit,
                  ),
                  icon:
                      Icons.trending_up,
                  color:
                      AppColors.success,
                  backgroundColor:
                      AppColors.successLight,
                ),

              // --------------------------------------------------
              // STOCK VALUE
              //
              // Controlled by reportShowStockValue.
              // --------------------------------------------------

              if (_showStockValue)
                _metricCard(
                  title: 'Stock Value',
                  value:
                      _formatCurrency(
                    stockValue,
                  ),
                  icon:
                      Icons.inventory_2_outlined,
                  color:
                      AppColors.inventory,
                  backgroundColor:
                      AppColors.infoLight,
                ),
            ];

            if (constraints.maxWidth <
                600) {
              return Column(
                children: [
                  for (
                    int i = 0;
                    i < cards.length;
                    i++
                  ) ...[
                    cards[i],
                    if (i <
                        cards.length - 1)
                      const SizedBox(
                        height: 12,
                      ),
                  ],
                ],
              );
            }

            final columns =
                constraints.maxWidth <
                        900
                    ? 2
                    : 4;

            return GridView.builder(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              itemCount:
                  cards.length,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                    columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 94,
              ),
              itemBuilder:
                  (
                context,
                index,
              ) {
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
      constraints:
          const BoxConstraints(
        minHeight: 94,
      ),
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color:
                Color(0x08000000),
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
            decoration:
                BoxDecoration(
              color:
                  backgroundColor,
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
            child: Icon(
              icon,
              color: color,
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
                  title,
                  style:
                      AppTextStyles
                          .bodySecondary,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style:
                      AppTextStyles.price,
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
  // ANALYTICS HEADER
  // ============================================================

  Widget _buildAnalyticsHeader() {
    return Wrap(
      crossAxisAlignment:
          WrapCrossAlignment.center,
      alignment:
          WrapAlignment.spaceBetween,
      runSpacing: 8,
      children: [
        const Text(
          'Sales analytics',
          style: AppTextStyles.title,
        ),
        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration:
              BoxDecoration(
            color:
                AppColors.surfaceSoft,
            borderRadius:
                BorderRadius.circular(
              8,
            ),
            border: Border.all(
              color:
                  AppColors.border,
            ),
          ),
          child: const Row(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Icon(
                Icons.insights_outlined,
                size: 15,
                color:
                    AppColors.textSecondary,
              ),
              SizedBox(width: 6),
              Text(
                'Performance',
                style:
                    AppTextStyles.small,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CHARTS
  // ============================================================

  Widget _buildChartsSection({
    required List<Map<String, dynamic>>
        salesTrend,
    required Map<String, double>
        paymentBreakdown,
    required List<Map<String, dynamic>>
        categorySummary,
    required double availableWidth,
  }) {
    final isPhone =
        _isPhone(availableWidth);

    final isTabletLandscape =
        _isTabletLandscape(
      availableWidth,
    );

    // ==========================================================
    // BUILD ONLY ENABLED CHARTS
    // ==========================================================

    final charts = <Widget>[];

    // ----------------------------------------------------------
    // SALES TREND
    // ----------------------------------------------------------

    if (_showSalesTrend) {
      charts.add(
        _chartCard(
          title: 'Sales trend',
          subtitle:
              'Sales performance over the selected period',
          icon: Icons.show_chart,
          iconColor:
              AppColors.primary,
          child:
              SalesTrendChart(
            salesTrend:
                salesTrend,
          ),
          height:
              isPhone ? 300 : 330,
        ),
      );
    }

    // ----------------------------------------------------------
    // PAYMENT BREAKDOWN
    // ----------------------------------------------------------

    if (_showPaymentBreakdown) {
      charts.add(
        _chartCard(
          title:
              'Payment breakdown',
          subtitle:
              'How customers paid',
          icon: Icons
              .account_balance_wallet_outlined,
          iconColor:
              AppColors.success,
          child:
              PaymentBreakdownChart(
            paymentBreakdown:
                paymentBreakdown,
          ),
          height:
              isPhone ? 300 : 310,
        ),
      );
    }

    // ----------------------------------------------------------
    // CATEGORY PERFORMANCE
    // ----------------------------------------------------------

    if (_showCategoryPerformance) {
      charts.add(
        _chartCard(
          title:
              'Category performance',
          subtitle:
              'Sales by category',
          icon:
              Icons.category_outlined,
          iconColor:
              AppColors.accent,
          child:
              CategoryPerformanceChart(
            categorySummary:
                categorySummary,
          ),
          height:
              isPhone ? 300 : 310,
        ),
      );
    }

    // ==========================================================
    // NO INDIVIDUAL CHARTS ENABLED
    //
    // The whole analytics section can remain enabled, but if all
    // three charts are disabled, there is nothing to display.
    // ==========================================================

    if (charts.isEmpty) {
      return const SizedBox.shrink();
    }

    // ==========================================================
    // PHONE / NARROW TABLET
    //
    // One chart per row.
    // ==========================================================

    if (!isTabletLandscape &&
        availableWidth < 1200) {
      return Column(
        children: [
          for (
            int i = 0;
            i < charts.length;
            i++
          ) ...[
            charts[i],
            if (i <
                charts.length - 1)
              const SizedBox(height: 16),
          ],
        ],
      );
    }

    // ==========================================================
    // TABLET LANDSCAPE / DESKTOP
    //
    // Sales Trend stays full width.
    // Payment + Category share the second row when present.
    //
    // If Sales Trend is disabled, the remaining charts occupy
    // the available row correctly.
    // ==========================================================

    final salesTrendChart =
        _showSalesTrend
            ? charts.firstWhere(
                (chart) =>
                    chart is Widget,
              )
            : null;

    final lowerCharts =
        <Widget>[];

    if (_showPaymentBreakdown) {
      lowerCharts.add(
        _chartCard(
          title:
              'Payment breakdown',
          subtitle:
              'How customers paid',
          icon: Icons
              .account_balance_wallet_outlined,
          iconColor:
              AppColors.success,
          child:
              PaymentBreakdownChart(
            paymentBreakdown:
                paymentBreakdown,
          ),
          height:
              isPhone ? 300 : 310,
        ),
      );
    }

    if (_showCategoryPerformance) {
      lowerCharts.add(
        _chartCard(
          title:
              'Category performance',
          subtitle:
              'Sales by category',
          icon:
              Icons.category_outlined,
          iconColor:
              AppColors.accent,
          child:
              CategoryPerformanceChart(
            categorySummary:
                categorySummary,
          ),
          height:
              isPhone ? 300 : 310,
        ),
      );
    }

    return Column(
      children: [
        if (_showSalesTrend) ...[
          charts.first,
          if (lowerCharts.isNotEmpty)
            const SizedBox(height: 16),
        ],

        if (lowerCharts.length == 1)
          lowerCharts.first,

        if (lowerCharts.length == 2)
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                child:
                    lowerCharts[0],
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child:
                    lowerCharts[1],
              ),
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
      padding:
          const EdgeInsets.all(16),
      decoration:
          BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color:
                Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration:
                    BoxDecoration(
                  color:
                      iconColor.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    9,
                  ),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 19,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style:
                          AppTextStyles
                              .title
                              .copyWith(
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      subtitle,
                      style:
                          AppTextStyles
                              .small,
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          Expanded(
            child: ClipRect(
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REPORTS HEADER
  // ============================================================

  Widget _buildReportsHeader() {
    return const Wrap(
      crossAxisAlignment:
          WrapCrossAlignment.center,
      alignment:
          WrapAlignment.spaceBetween,
      runSpacing: 6,
      children: [
        Text(
          'Reports',
          style: AppTextStyles.title,
        ),
        Text(
          'Detailed business reports',
          style: AppTextStyles.small,
        ),
      ],
    );
  }

  // ============================================================
  // REPORTS GRID
  // ============================================================

  Widget _buildReportsGrid({
    required double totalSales,
    required double profit,
    required double stockValue,
    required int categoryCount,
  }) {
    final cards = [
      // ========================================================
      // SALES
      // ========================================================

      _ReportCardData(
        title: 'Sales Report',
        subtitle:
            _formatCurrency(
          totalSales,
        ),
        description:
            'Review sales transactions',
        icon:
            Icons.receipt_long_outlined,
        color:
            AppColors.sales,
        screen:
            const SalesReportScreen(),
      ),

      // ========================================================
      // GROSS REVENUE
      // ========================================================

      const _ReportCardData(
        title: 'Gross Revenue',
        subtitle: 'Revenue report',
        description:
            'Review total revenue',
        icon:
            Icons.account_balance_outlined,
        color:
            AppColors.primary,
        screen:
            GrossRevenueReportScreen(),
      ),

      // ========================================================
      // ITEMS SOLD
      // ========================================================

      const _ReportCardData(
        title: 'Items Sold',
        subtitle: 'Quantity report',
        description:
            'Review products sold',
        icon:
            Icons.shopping_cart_outlined,
        color:
            AppColors.info,
        screen:
            ItemsSoldReportScreen(),
      ),

      // ========================================================
      // PROFIT
      //
      // Controlled by reportShowProfit.
      // ========================================================

      if (_showProfit)
        _ReportCardData(
          title: 'Profit Report',
          subtitle:
              _formatCurrency(
            profit,
          ),
          description:
              'Profitability for selected period',
          icon:
              Icons.trending_up,
          color:
              AppColors.profit,
          screen:
              const ProfitReportScreen(),
        ),

      // ========================================================
      // CATEGORY
      // ========================================================

      _ReportCardData(
        title: 'Category Report',
        subtitle:
            '$categoryCount categories',
        description:
            'Analyze category performance',
        icon:
            Icons.category_outlined,
        color:
            AppColors.products,
        screen:
            const CategoryReportScreen(),
      ),

      // ========================================================
      // STOCK VALUE
      //
      // Controlled by reportShowStockValue.
      // ========================================================

      if (_showStockValue)
        _ReportCardData(
          title: 'Stock Value',
          subtitle:
              _formatCurrency(
            stockValue,
          ),
          description:
              'Current inventory value',
          icon:
              Icons.inventory_2_outlined,
          color:
              AppColors.inventory,
          screen:
              const StockValueReportScreen(),
        ),

      // ========================================================
      // LOW STOCK
      // ========================================================

      const _ReportCardData(
        title: 'Low Stock',
        subtitle:
            'Inventory alert',
        description:
            'Items below stock level',
        icon:
            Icons.warning_amber_rounded,
        color:
            AppColors.warning,
        screen:
            LowStockReportScreen(),
      ),

      // ========================================================
      // OUT OF STOCK
      // ========================================================

      const _ReportCardData(
        title: 'Out of Stock',
        subtitle:
            'Critical inventory',
        description:
            'Items requiring restock',
        icon:
            Icons.remove_shopping_cart_outlined,
        color:
            AppColors.danger,
        screen:
            OutOfStockReportScreen(),
      ),

      // ========================================================
      // RECONCILIATION
      // ========================================================

      _ReportCardData(
        title: 'Reconciliation',
        subtitle:
            'Daily stock check',
        description:
            'Compare expected vs actual',
        icon:
            Icons.fact_check_outlined,
        color:
            AppColors.primary,
        screen:
            ReconciliationScreen(
          productDao:
              productDao,
          date:
              DateTime.now(),
        ),
      ),

      // ========================================================
      // SALARY
      // ========================================================

      const _ReportCardData(
        title: 'Salary Report',
        subtitle:
            'Staff payroll',
        description:
            'Salaries and outstanding debts',
        icon:
            Icons.badge_outlined,
        color:
            AppColors.products,
        screen:
            SalaryReportScreen(),
      ),

      // ========================================================
      // EXPIRY
      // ========================================================

      const _ReportCardData(
        title: 'Expiry Report',
        subtitle:
            'Expiry monitoring',
        description:
            'Products nearing expiry',
        icon:
            Icons.schedule_outlined,
        color:
            AppColors.danger,
        screen:
            ExpiryReportScreen(),
      ),
    ];

    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final width =
            constraints.maxWidth;

        int columns;

        if (width < 500) {
          columns = 1;
        } else if (width < 800) {
          columns = 2;
        } else if (width < 1100) {
          columns = 3;
        } else {
          columns = 4;
        }

        final cardHeight =
            columns == 1
                ? 86.0
                : columns == 2
                    ? 112.0
                    : 118.0;

        return GridView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          itemCount:
              cards.length,
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
                columns,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent:
                cardHeight,
          ),
          itemBuilder:
              (
            context,
            index,
          ) {
            return _buildReportCard(
              cards[index],
            );
          },
        );
      },
    );
  }

  Widget _buildReportCard(
    _ReportCardData data,
  ) {
    return Material(
      color:
          Colors.transparent,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  data.screen,
            ),
          );
        },
        child: Ink(
          decoration:
              BoxDecoration(
            color:
                AppColors.surface,
            borderRadius:
                BorderRadius.circular(
              14,
            ),
            border: Border.all(
              color:
                  AppColors.border,
            ),
            boxShadow: const [
              BoxShadow(
                color:
                    Color(0x05000000),
                blurRadius: 7,
                offset:
                    Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding:
                const EdgeInsets.all(
              14,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration:
                      BoxDecoration(
                    color:
                        data.color
                            .withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      11,
                    ),
                  ),
                  child: Icon(
                    data.icon,
                    color:
                        data.color,
                    size: 22,
                  ),
                ),
                const SizedBox(
                  width: 11,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Text(
                        data.title,
                        style:
                            AppTextStyles
                                .title
                                .copyWith(
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        data.subtitle,
                        style:
                            AppTextStyles
                                .bodySecondary
                                .copyWith(
                          color:
                              data.color,
                          fontWeight:
                              FontWeight
                                  .w600,
                        ),
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        data.description,
                        style:
                            AppTextStyles
                                .small,
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 4,
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 19,
                  color:
                      AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EXPORT
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
      padding: const EdgeInsets.all(20),
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
          final compact = constraints.maxWidth < 650;

          final buttons = _exportButtons(
            totalSales: totalSales,
            itemsSold: itemsSold,
            profit: profit,
            paymentBreakdown: paymentBreakdown,
            categorySummary: categorySummary,
            salesTrend: salesTrend,
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _exportContent(),
                const SizedBox(height: 16),
                buttons,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _exportContent()),
              const SizedBox(width: 20),
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
  }) {
    return Row(
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
          ),
          icon: const Icon(Icons.picture_as_pdf_outlined),
          label: const Text('Export Dashboard PDF'),
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
              if (!mounted) return;
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
          },
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
          ),
          icon: const Icon(Icons.data_object_outlined),
          label: const Text('Export Daily JSON'),
          onPressed: () async {
            try {
              final service = DailyReportService(
                salesDao: salesDao,
                productDao: productDao,
                attendanceDao: AttendanceDao(db),
                settingsDao: widget.settingsDao,
              );
              final file = await service.exportDailyReport();
              if (!mounted) return;
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
              if (!mounted) return;
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
        ),
      ],
    );
  }

  Widget _exportContent() {
    return const Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.picture_as_pdf_outlined,
          color:
              Colors.white,
          size: 30,
        ),
        SizedBox(
          width: 14,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Text(
                'Export your dashboard',
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
              SizedBox(
                height: 5,
              ),
              Text(
                'Generate a PDF containing your sales, profit, payment and category analytics.',
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


  //import

  Map<String, dynamic>? _importedReport;

Widget _buildImportSection() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
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
        final compact = constraints.maxWidth < 650;

        final content = _importContent();
        final button = _importButton();

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              content,
              const SizedBox(height: 16),
              button,
              const SizedBox(height: 20),
              if (_importedReport != null) 
                ElevatedButton.icon(
                  icon: const Icon(Icons.visibility, size: 19),
                  label: const Text(
                    'View Imported Report',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  onPressed: (){
                    _showImportedOverviewPopup(_importedReport!);
                  },
                )
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: content),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                button,
                const SizedBox(height: 20),
                if (_importedReport != null) 
                  ElevatedButton.icon(
                    icon: const Icon(Icons.visibility, size: 19),
                    label: const Text(
                      'View Imported Report',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: (){
                      _showImportedOverviewPopup(_importedReport!);
                    },
                  )
              ],
            ),
          ],
        );
      },
    ),
  );
}

Widget _importContent() {
  return const Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(
        Icons.file_open,
        color: Colors.white,
        size: 30,
      ),
      SizedBox(width: 14),
      Expanded(
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: const Icon(Icons.file_open, size: 19),
      label: const Text(
        'Select Report File',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
      ),
      onPressed: () async {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['json'],
        );
        if (result != null && result.files.single.path != null) {
          final file = File(result.files.single.path!);
          final content = await file.readAsString();
          final report = jsonDecode(content);
          if (!mounted) return;
          setState(() {
            _showImportedOverviewPopup(report);
          });
        }
      },
    );
  }

  void _showImportedOverviewPopup(Map<String, dynamic> report) {
    final metrics = report['metrics'] as Map<String, dynamic>;
    final business = report['business'] as Map<String, dynamic>;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x18000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with close icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${business['name']} — Daily Snapshot",
                      style: AppTextStyles.heading,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Text(
                  report['date'],
                  style: AppTextStyles.small,
                ),
                const SizedBox(height: 16),

                // Metrics grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 3,
                  children: [
                    _metricCard(
                      title: 'Total Sales',
                      value: '₦${metrics['sales_total']}',
                      icon: Icons.payments_outlined,
                      color: AppColors.primary,
                      backgroundColor: AppColors.primaryLight,
                    ),
                    _metricCard(
                      title: 'Items Sold',
                      value: metrics['items_sold'].toString(),
                      icon: Icons.shopping_cart_outlined,
                      color: AppColors.info,
                      backgroundColor: AppColors.infoLight,
                    ),
                    _metricCard(
                      title: 'Profit',
                      value: '₦${metrics['profit']}',
                      icon: Icons.trending_up,
                      color: AppColors.success,
                      backgroundColor: AppColors.successLight,
                    ),
                    _metricCard(
                      title: 'Attendance Count',
                      value: metrics['attendance_count'].toString(),
                      icon: Icons.people_alt_outlined,
                      color: AppColors.accent,
                      backgroundColor: AppColors.accentLight,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  // ============================================================
  // FILTER
  // ============================================================

  Widget _buildFilterDropdown() {
    return SizedBox(
      width: 132,
      height: 42,
      child: Container(
        padding:
            const EdgeInsets
                .symmetric(
          horizontal: 4,
        ),
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
            DropdownButtonHideUnderline(
          child:
              DropdownButton<String>(
            value:
                _selectedFilter,
            isExpanded:
                true,
            borderRadius:
                BorderRadius.circular(
              10,
            ),
            dropdownColor:
                AppColors.surface,
            icon: const Icon(
              Icons
                  .keyboard_arrow_down_rounded,
              color:
                  AppColors.textSecondary,
              size: 20,
            ),
            style:
                AppTextStyles
                    .bodySecondary
                    .copyWith(
              color:
                  AppColors.textPrimary,
              fontWeight:
                  FontWeight.w600,
            ),
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 8,
            ),
            selectedItemBuilder:
                (context) {
              return const [
                Align(
                  alignment:
                      Alignment.centerLeft,
                  child:
                      Text('Today'),
                ),
                Align(
                  alignment:
                      Alignment.centerLeft,
                  child:
                      Text('This Week'),
                ),
                Align(
                  alignment:
                      Alignment.centerLeft,
                  child:
                      Text('This Month'),
                ),
                Align(
                  alignment:
                      Alignment.centerLeft,
                  child:
                      Text('This Year'),
                ),
                Align(
                  alignment:
                      Alignment.centerLeft,
                  child:
                      Text('Custom'),
                ),
              ];
            },
            items: const [
              DropdownMenuItem<String>(
                value:
                    'Day',
                child: Text(
                  'Today',
                  overflow:
                      TextOverflow
                          .ellipsis,
                ),
              ),
              DropdownMenuItem<String>(
                value:
                    'Week',
                child: Text(
                  'This Week',
                  overflow:
                      TextOverflow
                          .ellipsis,
                ),
              ),
              DropdownMenuItem<String>(
                value:
                    'Month',
                child: Text(
                  'This Month',
                  overflow:
                      TextOverflow
                          .ellipsis,
                ),
              ),
              DropdownMenuItem<String>(
                value:
                    'Year',
                child: Text(
                  'This Year',
                  overflow:
                      TextOverflow
                          .ellipsis,
                ),
              ),
              DropdownMenuItem<String>(
                value:
                    'Custom',
                child: Text(
                  'Custom',
                  overflow:
                      TextOverflow
                          .ellipsis,
                ),
              ),
            ],
            onChanged:
                (String? value) async {
              if (value == null) {
                return;
              }

              if (value ==
                  'Custom') {
                final now =
                    DateTime.now();

                final picked =
                    await showDateRangePicker(
                  context:
                      context,
                  firstDate:
                      DateTime(2020),
                  lastDate:
                      now,
                  initialDateRange:
                      _selectedDateRange ??
                          DateTimeRange(
                            start:
                                now.subtract(
                              const Duration(
                                days: 7,
                              ),
                            ),
                            end:
                                now,
                          ),
                  builder:
                      (
                    context,
                    child,
                  ) {
                    return Theme(
                      data:
                          Theme.of(
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
                      child:
                          child!,
                    );
                  },
                );

                if (!mounted) {
                  return;
                }

                if (picked != null) {
                  setState(() {
                    _selectedDateRange =
                        picked;

                    _selectedFilter =
                        'Custom';
                  });
                }

                return;
              }

              setState(() {
                _selectedFilter =
                    value;
              });
            },
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DATE RANGE
  // ============================================================
  //
  // DAO convention:
  //
  // created_at >= start
  // created_at < end
  //
  // Therefore end is EXCLUSIVE.
  //
  // ============================================================

  DateTimeRange _getRange() {
    final now =
        DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    switch (_selectedFilter) {
      case 'Day':
        return DateTimeRange(
          start: today,
          end:
              today.add(
            const Duration(
              days: 1,
            ),
          ),
        );

      case 'Week':
        final start =
            today.subtract(
          Duration(
            days:
                today.weekday - 1,
          ),
        );

        return DateTimeRange(
          start: start,
          end:
              start.add(
            const Duration(
              days: 7,
            ),
          ),
        );

      case 'Month':
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

        return DateTimeRange(
          start: start,
          end: end,
        );

      case 'Year':
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

        return DateTimeRange(
          start: start,
          end: end,
        );

      case 'Custom':
        if (_selectedDateRange ==
            null) {
          final start =
              today.subtract(
            const Duration(
              days: 7,
            ),
          );

          return DateTimeRange(
            start: start,
            end:
                today.add(
              const Duration(
                days: 1,
              ),
            ),
          );
        }

        final selected =
            _selectedDateRange!;

        final start = DateTime(
          selected.start.year,
          selected.start.month,
          selected.start.day,
        );

        final end = DateTime(
          selected.end.year,
          selected.end.month,
          selected.end.day,
        ).add(
          const Duration(
            days: 1,
          ),
        );

        return DateTimeRange(
          start: start,
          end: end,
        );

      default:
        return DateTimeRange(
          start: today,
          end:
              today.add(
            const Duration(
              days: 1,
            ),
          ),
        );
    }
  }

  String _formatDateRange(
    DateTimeRange range,
  ) {
    if (_selectedFilter ==
        'Day') {
      return _formatDate(
        range.start,
      );
    }

    final displayEnd =
        range.end.subtract(
      const Duration(
        days: 1,
      ),
    );

    return '${_formatDate(range.start)} – ${_formatDate(displayEnd)}';
  }

  String _formatDate(
    DateTime date,
  ) {
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

  String _formatCurrency(
    double value,
  ) {
    return '₦${_formatNumber(value.round())}';
  }

  String _formatNumber(
    num value,
  ) {
    final number =
        value.toInt();

    final string =
        number.toString();

    final buffer =
        StringBuffer();

    for (
      int i = 0;
      i < string.length;
      i++
    ) {
      if (i > 0 &&
          (string.length - i) %
                  3 ==
              0) {
        buffer.write(',');
      }

      buffer.write(
        string[i],
      );
    }

    return buffer.toString();
  }

  // ============================================================
  // DAO RESULT NORMALIZATION
  // ============================================================

  double _toDouble(
    dynamic value,
  ) {
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

  int _toInt(
    dynamic value,
  ) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  Map<String, double>
      _toDoubleMap(
    dynamic value,
  ) {
    if (value is! Map) {
      return {};
    }

    return value.map(
      (key, value) {
        return MapEntry(
          key.toString(),
          _toDouble(value),
        );
      },
    );
  }

  List<Map<String, dynamic>>
      _toMapList(
    dynamic value,
  ) {
    if (value is! List) {
      return [];
    }

    return value
        .whereType<Map>()
        .map(
          (item) =>
              Map<String, dynamic>.from(
            item,
          ),
        )
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

class _ReportsLoadingState
    extends StatelessWidget {
  const _ReportsLoadingState();

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
            SizedBox(
              height: 16,
            ),
            Text(
              'Loading reports...',
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

// ============================================================
// EMPTY
// ============================================================

class _ReportsEmptyState
    extends StatelessWidget {
  const _ReportsEmptyState();

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
            Icon(
              Icons
                  .analytics_outlined,
              size: 56,
              color:
                  AppColors.textMuted,
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              'No report data available',
              style:
                  AppTextStyles.title,
            ),
            SizedBox(
              height: 6,
            ),
            Text(
              'There is currently no data to display.',
              style:
                  AppTextStyles
                      .bodySecondary,
              textAlign:
                  TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ERROR
// ============================================================

class _ReportsErrorState
    extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ReportsErrorState({
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
            const EdgeInsets.all(
          32,
        ),
        child: Container(
          constraints:
              const BoxConstraints(
            maxWidth: 600,
          ),
          padding:
              const EdgeInsets.all(
            28,
          ),
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
                child:
                    const Icon(
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
                'Unable to load reports',
                style:
                    AppTextStyles.title,
                textAlign:
                    TextAlign.center,
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                width:
                    double.infinity,
                padding:
                    const EdgeInsets
                        .all(
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
                      AppTextStyles
                          .small,
                  textAlign:
                      TextAlign.left,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton
                  .icon(
                onPressed:
                    onRetry,
                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      AppColors
                          .primary,
                  foregroundColor:
                      Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal:
                        20,
                    vertical:
                        13,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
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
                  'Try Again',
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
