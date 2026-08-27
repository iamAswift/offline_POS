// lib/features/dashboard/dashboard_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:supermarket_inventory/features/products/products_screen.dart';
import 'package:supermarket_inventory/features/reports/gross_revenue_report_screen.dart';
import 'package:supermarket_inventory/features/reports/items_sold_report_screen.dart';
import 'package:supermarket_inventory/features/reports/low_stock_report_screen.dart';
import 'package:supermarket_inventory/features/reports/out_of_stock_report_screen.dart';
import 'package:supermarket_inventory/features/reports/profit_report_screen.dart';
import 'package:supermarket_inventory/features/reports/sales_reports_screen.dart';
import 'package:supermarket_inventory/features/reports/stock_value_report_screen.dart';
import 'package:supermarket_inventory/features/staff/staff_purchase_screen.dart';

import '../../core/business/business_identity.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/styles.dart';

import '../../database/app_database.dart';
import '../../database/daos/product_dao.dart';
import '../../database/daos/sales_dao.dart';
import '../../database/daos/settings_dao.dart';

import '../reports/widgets/sales_trend_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
  });

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {
  // ============================================================
  // BUSINESS IDENTITY
  // ============================================================

  String _businessName =
      BusinessIdentity.defaultBusinessName;

  String? _businessLogo;

  // ============================================================
  // DATE FILTER
  // ============================================================

  String _selectedFilter = 'Day';

  DateTimeRange? _selectedDateRange;

  // ============================================================
  // DATABASE
  // ============================================================

  final db = getDatabase();

  late final SalesDao salesDao;

  late final ProductDao productDao;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    salesDao = SalesDao(db);
    productDao = ProductDao(db);

    _loadBusinessIdentity();
  }

  // ============================================================
  // BUSINESS IDENTITY
  // ============================================================

  Future<void> _loadBusinessIdentity() async {
    try {
      final settingsDao = SettingsDao(db);

      final businessName =
          await BusinessIdentity.getBusinessName(
        settingsDao,
      );

      final businessLogo =
          await BusinessIdentity.getBusinessLogo(
        settingsDao,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _businessName = businessName;
        _businessLogo = businessLogo;
      });
    } catch (_) {
      // Keep the default business identity
      // if settings cannot be loaded.
    }
  }

  // ============================================================
  // DATE RANGE
  // ============================================================

  DateTimeRange _getRange() {
    final now = DateTime.now();

    switch (_selectedFilter) {
      case 'Day':
        return DateTimeRange(
          start: DateTime(
            now.year,
            now.month,
            now.day,
          ),
          end: now,
        );

      case 'Week':
        final weekStart = now.subtract(
          Duration(
            days: now.weekday - 1,
          ),
        );

        return DateTimeRange(
          start: DateTime(
            weekStart.year,
            weekStart.month,
            weekStart.day,
          ),
          end: now,
        );

      case 'Month':
        return DateTimeRange(
          start: DateTime(
            now.year,
            now.month,
            1,
          ),
          end: now,
        );

      case 'Custom':
        return _selectedDateRange ??
            DateTimeRange(
              start: DateTime(
                now.year,
                now.month,
                now.day,
              ),
              end: now,
            );

      default:
        return DateTimeRange(
          start: DateTime(
            now.year,
            now.month,
            now.day,
          ),
          end: now,
        );
    }
  }

  // ============================================================
  // FILTER LABEL
  // ============================================================

  String _filterLabel() {
    if (_selectedFilter != 'Custom' ||
        _selectedDateRange == null) {
      return _selectedFilter;
    }

    final range = _selectedDateRange!;

    return '${_formatDate(range.start)} - '
        '${_formatDate(range.end)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildDashboardHeader(context),

          Expanded(
            child: _buildDashboardContent(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DASHBOARD HEADER
  //
  // Navigation is intentionally NOT handled here.
  // MainScaffold owns the application navigation/sidebar.
  // ============================================================

  Widget _buildDashboardHeader(
    BuildContext context,
  ) {
    final responsive = context.responsive;

    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(
        horizontal:
            responsive.horizontalPadding,
        vertical: responsive.isCompact
            ? 14
            : 18,
      ),
      child: Row(
        children: [
          // ------------------------------------------------------
          // BUSINESS LOGO
          // ------------------------------------------------------

          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  AppColors.primary.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(
                AppRadius.lg,
              ),
            ),
            child: _buildBusinessLogo(),
          ),

          const SizedBox(
            width: AppSpacing.md,
          ),

          // ------------------------------------------------------
          // BUSINESS NAME
          // ------------------------------------------------------

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _businessName,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      AppTextStyles.title.copyWith(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                if (!responsive.isCompact) ...[
                  const SizedBox(height: 2),

                  Text(
                    'Business Overview',
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        AppTextStyles.small.copyWith(
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(
            width: AppSpacing.md,
          ),

          // ------------------------------------------------------
          // DATE FILTER
          // ------------------------------------------------------

          _buildFilterButton(context),
        ],
      ),
    );
  }

  // ============================================================
  // BUSINESS LOGO
  // ============================================================

  Widget _buildBusinessLogo() {
    final logoPath = _businessLogo;

    if (logoPath == null ||
        logoPath.isEmpty) {
      return const Icon(
        Icons.dashboard_outlined,
        color: AppColors.primary,
        size: 21,
      );
    }

    final file = File(logoPath);

    if (!file.existsSync()) {
      return const Icon(
        Icons.dashboard_outlined,
        color: AppColors.primary,
        size: 21,
      );
    }

    if (logoPath
        .toLowerCase()
        .endsWith('.svg')) {
      return ClipRRect(
        borderRadius:
            BorderRadius.circular(
          AppRadius.md,
        ),
        child: SvgPicture.file(
          file,
          width: 40,
          height: 40,
          fit: BoxFit.contain,
          placeholderBuilder:
              (context) {
            return const Icon(
              Icons.dashboard_outlined,
              color: AppColors.primary,
              size: 21,
            );
          },
        ),
      );
    }

    return ClipRRect(
      borderRadius:
          BorderRadius.circular(
        AppRadius.md,
      ),
      child: Image.file(
        file,
        width: 40,
        height: 40,
        fit: BoxFit.contain,
        errorBuilder:
            (context, error, stackTrace) {
          return const Icon(
            Icons.dashboard_outlined,
            color: AppColors.primary,
            size: 21,
          );
        },
      ),
    );
  }

  // ============================================================
  // FILTER BUTTON
  // ============================================================

  Widget _buildFilterButton(
    BuildContext context,
  ) {
    return PopupMenuButton<String>(
      tooltip: 'Date filter',

      onSelected: (value) async {
        // --------------------------------------------------------
        // CUSTOM RANGE
        // --------------------------------------------------------

        if (value == 'Custom') {
          final picked =
              await showDateRangePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            initialDateRange:
                _selectedDateRange,
          );

          if (!mounted) {
            return;
          }

          if (picked != null) {
            setState(() {
              _selectedFilter = 'Custom';
              _selectedDateRange = picked;
            });
          }

          return;
        }

        // --------------------------------------------------------
        // STANDARD FILTER
        // --------------------------------------------------------

        setState(() {
          _selectedFilter = value;

          if (value != 'Custom') {
            _selectedDateRange = null;
          }
        });
      },

      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'Day',
          child: Text('Today'),
        ),
        PopupMenuItem(
          value: 'Week',
          child: Text('This Week'),
        ),
        PopupMenuItem(
          value: 'Month',
          child: Text('This Month'),
        ),
        PopupMenuItem(
          value: 'Custom',
          child: Text('Custom Range'),
        ),
      ],

      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius:
              BorderRadius.circular(
            AppRadius.md,
          ),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color:
                  AppColors.textSecondary,
            ),

            const SizedBox(
              width: AppSpacing.sm,
            ),

            Text(
              _filterLabel(),
              style:
                  AppTextStyles.small.copyWith(
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(width: 5),

            const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color:
                  AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DASHBOARD CONTENT
  // ============================================================

  Widget _buildDashboardContent() {
    final range = _getRange();

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        // --------------------------------------------------------
        // TOTAL SALES
        // --------------------------------------------------------

        salesDao.getTotalSales(
          range.start,
          range.end,
        ),

        // --------------------------------------------------------
        // ITEMS SOLD
        // --------------------------------------------------------

        salesDao.getItemsSold(
          range.start,
          range.end,
        ),

        // --------------------------------------------------------
        // PROFIT
        // --------------------------------------------------------

        salesDao.getProfit(
          range.start,
          range.end,
        ),

        // --------------------------------------------------------
        // SALES TREND
        // --------------------------------------------------------

        salesDao.getSalesTrend(
          range.start,
          range.end,
        ),

        // --------------------------------------------------------
        // PRODUCTS
        // --------------------------------------------------------

        productDao.getAllProducts(),

        // --------------------------------------------------------
        // LOW STOCK
        // --------------------------------------------------------

        productDao.getLowStockProducts(),

        // --------------------------------------------------------
        // OUT OF STOCK
        // --------------------------------------------------------

        productDao.getOutOfStockProducts(),

        // --------------------------------------------------------
        // GROSS REVENUE
        // --------------------------------------------------------

        salesDao.getGrossRevenue(
          range.start,
          range.end,
        ),

        // --------------------------------------------------------
        // STOCK VALUE
        // --------------------------------------------------------

        salesDao.getTotalStockValue(),
      ]),

      builder: (context, snapshot) {
        // --------------------------------------------------------
        // LOADING
        // --------------------------------------------------------

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child:
                CircularProgressIndicator(),
          );
        }

        // --------------------------------------------------------
        // ERROR
        // --------------------------------------------------------

        if (snapshot.hasError) {
          return Center(
            child: _errorState(
              'Unable to load dashboard',
              '${snapshot.error}',
            ),
          );
        }

        // --------------------------------------------------------
        // NO DATA
        // --------------------------------------------------------

        if (!snapshot.hasData ||
            snapshot.data == null) {
          return const Center(
            child:
                CircularProgressIndicator(),
          );
        }

        final data = snapshot.data!;

        // --------------------------------------------------------
        // DATA CONVERSION
        // --------------------------------------------------------

        final totalSales =
            _toDouble(data[0]);

        final itemsSold =
            _toInt(data[1]);

        final profit =
            _toDouble(data[2]);

        final salesTrend =
            data[3]
                as List<Map<String, dynamic>>;

        final products =
            data[4] as List<Product>;

        final lowStock =
            data[5] as List<Product>;

        final outOfStock =
            data[6] as List<Product>;

        final grossRevenue =
            _toDouble(data[7]);

        final stockValue =
            _toDouble(data[8]);

        // --------------------------------------------------------
        // DASHBOARD
        // --------------------------------------------------------

        return _buildResponsiveDashboard(
          context,
          totalSales: totalSales,
          itemsSold: itemsSold,
          profit: profit,
          salesTrend: salesTrend,
          products: products,
          lowStock: lowStock,
          outOfStock: outOfStock,
          grossRevenue: grossRevenue,
          stockValue: stockValue,
        );
      },
    );
  }

  // ============================================================
  // RESPONSIVE DASHBOARD
  // ============================================================

  Widget _buildResponsiveDashboard(
    BuildContext context, {
    required double totalSales,
    required int itemsSold,
    required double profit,
    required List<Map<String, dynamic>>
        salesTrend,
    required List<Product> products,
    required List<Product> lowStock,
    required List<Product> outOfStock,
    required double grossRevenue,
    required double stockValue,
  }) {
    final responsive =
        context.responsive;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal:
            responsive.horizontalPadding,
        vertical:
            responsive.verticalPadding,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth:
                responsive.contentMaxWidth,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ==================================================
              // PAGE HEADER
              // ==================================================

              _buildPageHeader(
                totalProducts:
                    products.length,
              ),

              const SizedBox(
                height: AppSpacing.lg,
              ),

              // ==================================================
              // SUMMARY CARDS
              // ==================================================

              _buildSummaryGrid(
                context: context,
                totalSales: totalSales,
                products: products,
                lowStock: lowStock,
                outOfStock: outOfStock,
                profit: profit,
                stockValue: stockValue,
                itemsSold: itemsSold,
                grossRevenue: grossRevenue,
              ),

              const SizedBox(
                height: AppSpacing.xxl,
              ),

              // ==================================================
              // SALES TREND
              // ==================================================

              _buildSalesTrendSection(
                salesTrend: salesTrend,
              ),

              const SizedBox(
                height: AppSpacing.xxl,
              ),

              // ==================================================
              // QUICK INSIGHTS
              // ==================================================

              _buildQuickInsights(
                context,
                products.length,
                lowStock.length,
                outOfStock.length,
                profit,
              ),

              const SizedBox(
                height: AppSpacing.xxl,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PAGE HEADER
  // ============================================================

  Widget _buildPageHeader({
    required int totalProducts,
  }) {
    final responsive =
        context.responsive;

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color:
                AppColors.primary.withValues(
              alpha: 0.10,
            ),
            borderRadius:
                BorderRadius.circular(
              AppRadius.lg,
            ),
          ),
          child: const Icon(
            Icons.dashboard_customize_outlined,
            color: AppColors.primary,
            size: 23,
          ),
        ),

        const SizedBox(
          width: 13,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Business Overview',
                style:
                    AppTextStyles.dashboardTitle
                        .copyWith(
                  fontSize:
                      responsive.isCompact
                          ? 19
                          : 22,
                ),
              ),

              const SizedBox(
                height: 3,
              ),

              const Text(
                'Monitor sales, inventory and business performance.',
                style:
                    AppTextStyles.dashboardSubtitle,
              ),
            ],
          ),
        ),

        if (!responsive.isCompact)
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 7,
            ),
            decoration:
                BoxDecoration(
              color: AppColors.surface,
              borderRadius:
                  BorderRadius.circular(
                AppRadius.md,
              ),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: Row(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  size: 15,
                  color: AppColors.primary,
                ),

                const SizedBox(
                  width: 6,
                ),

                Text(
                  '$totalProducts products',
                  style:
                      AppTextStyles.small
                          .copyWith(
                    color:
                        AppColors.textPrimary,
                    fontWeight:
                        FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ============================================================
  // SUMMARY GRID
  // ============================================================

  Widget _buildSummaryGrid({
    required BuildContext context,
    required double totalSales,
    required List<Product> products,
    required List<Product> lowStock,
    required List<Product> outOfStock,
    required double profit,
    required double stockValue,
    required int itemsSold,
    required double grossRevenue,
  }) {
    final responsive =
        context.responsive;

    final columns =
        responsive.gridColumns;

    final spacing =
        AppSpacing.md;

    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final availableWidth =
            constraints.maxWidth;

        final cardWidth = columns == 1
            ? availableWidth
            : (availableWidth -
                    (spacing *
                        (columns - 1))) /
                columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            // ====================================================
            // ATTENDANCE
            // ====================================================

            _dashboardCard(
              context: context,
              width: cardWidth,
              title: 'Attendance',
              value: 'Manage',
              subtitle:
                  'Clock staff in or out',
              icon:
                  Icons.access_time_outlined,
              color: AppColors.info,
              onTap: () {
                context.push(
                  '/attendance',
                );
              },
            ),

            // ====================================================
            // TOTAL SALES
            // ====================================================

            _dashboardCard(
              context: context,
              width: cardWidth,
              title: 'Total Sales',
              value:
                  _formatCurrency(
                totalSales,
              ),
              subtitle:
                  'Sales for ${_selectedFilter.toLowerCase()}',
              icon:
                  Icons.point_of_sale_outlined,
              color: AppColors.sales,
              destination:
                  const SalesReportScreen(),
            ),

            // ====================================================
            // PRODUCTS
            // ====================================================

            _dashboardCard(
              context: context,
              width: cardWidth,
              title: 'Products',
              value:
                  '${products.length}',
              subtitle:
                  'Products in inventory',
              icon:
                  Icons.inventory_2_outlined,
              color: AppColors.products,
              destination:
                  const ProductsScreen(),
            ),

            // ====================================================
            // LOW STOCK
            // ====================================================

            _dashboardCard(
              context: context,
              width: cardWidth,
              title: 'Low Stock',
              value:
                  '${lowStock.length}',
              subtitle:
                  'Items need attention',
              icon:
                  Icons.warning_amber_rounded,
              color: AppColors.warning,
              destination:
                  const LowStockReportScreen(),
            ),

            // ====================================================
            // OUT OF STOCK
            // ====================================================

            _dashboardCard(
              context: context,
              width: cardWidth,
              title: 'Out of Stock',
              value:
                  '${outOfStock.length}',
              subtitle:
                  'Items unavailable',
              icon:
                  Icons.remove_shopping_cart_outlined,
              color: AppColors.danger,
              destination:
                  const OutOfStockReportScreen(),
            ),

            // ====================================================
            // PROFIT
            // ====================================================

            _dashboardCard(
              context: context,
              width: cardWidth,
              title: 'Profit',
              value:
                  _formatCurrency(
                profit,
              ),
              subtitle:
                  'Estimated profit',
              icon:
                  Icons.trending_up,
              color: AppColors.profit,
              destination:
                  const ProfitReportScreen(),
            ),

            // ====================================================
            // STOCK VALUE
            // ====================================================

            _dashboardCard(
              context: context,
              width: cardWidth,
              title: 'Stock Value',
              value:
                  _formatCurrency(
                stockValue,
              ),
              subtitle:
                  'Current inventory value',
              icon:
                  Icons.inventory_outlined,
              color: AppColors.inventory,
              destination:
                  const StockValueReportScreen(),
            ),

            // ====================================================
            // ITEMS SOLD
            // ====================================================

            _dashboardCard(
              context: context,
              width: cardWidth,
              title: 'Items Sold',
              value:
                  '$itemsSold',
              subtitle:
                  'Units sold',
              icon:
                  Icons.shopping_cart_outlined,
              color: AppColors.info,
              destination:
                  const ItemsSoldReportScreen(),
            ),

            // ====================================================
            // GROSS REVENUE
            // ====================================================

            _dashboardCard(
              context: context,
              width: cardWidth,
              title: 'Gross Revenue',
              value:
                  _formatCurrency(
                grossRevenue,
              ),
              subtitle:
                  'Revenue generated',
              icon:
                  Icons.payments_outlined,
              color: AppColors.success,
              destination:
                  const GrossRevenueReportScreen(),
            ),

            // ====================================================
            // STAFF PURCHASES
            // ====================================================

            _dashboardCard(
              context: context,
              width: cardWidth,
              title: 'Staff Purchases',
              value: 'Manage',
              subtitle:
                  'Staff purchase accounts',
              icon:
                  Icons.people_alt_outlined,
              color: AppColors.pos,
              destination:
                  const StaffPurchaseScreen(),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // DASHBOARD CARD
  // ============================================================

  Widget _dashboardCard({
    required BuildContext context,
    required double width,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    Widget? destination,
    VoidCallback? onTap,
  }) {
    VoidCallback? handleTap;

    if (onTap != null) {
      handleTap = onTap;
    } else if (destination != null) {
      handleTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => destination,
          ),
        );
      };
    }

    return SizedBox(
      width: width,
      child: Material(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          AppRadius.lg,
        ),
        child: InkWell(
          borderRadius:
              BorderRadius.circular(
            AppRadius.lg,
          ),
          onTap: handleTap,
          mouseCursor:
              handleTap == null
                  ? SystemMouseCursors.basic
                  : SystemMouseCursors.click,
          child: Container(
            constraints:
                const BoxConstraints(
              minHeight: 88,
            ),
            padding:
                const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 12,
            ),
            decoration:
                BoxDecoration(
              borderRadius:
                  BorderRadius.circular(
                AppRadius.lg,
              ),
              border: Border.all(
                color: AppColors.border,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withValues(
                    alpha: 0.02,
                  ),
                  blurRadius: 8,
                  offset:
                      const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // ------------------------------------------------
                // ICON
                // ------------------------------------------------

                Container(
                  width: 40,
                  height: 40,
                  decoration:
                      BoxDecoration(
                    color:
                        color.withValues(
                      alpha: 0.09,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      AppRadius.md,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),

                const SizedBox(
                  width: 11,
                ),

                // ------------------------------------------------
                // CONTENT
                // ------------------------------------------------

                Expanded(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            AppTextStyles
                                .dashboardCardTitle
                                .copyWith(
                          fontSize: 11,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      const SizedBox(
                        height: 2,
                      ),

                      Text(
                        value,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            AppTextStyles
                                .dashboardCardValue
                                .copyWith(
                          fontSize: 15,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),

                      const SizedBox(
                        height: 1,
                      ),

                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            AppTextStyles
                                .dashboardCardSubtitle
                                .copyWith(
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  width: 5,
                ),

                // ------------------------------------------------
                // ARROW
                // ------------------------------------------------

                const Icon(
                  Icons
                      .arrow_forward_ios_rounded,
                  size: 12,
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
  // SALES TREND
  // ============================================================

  Widget _buildSalesTrendSection({
    required List<Map<String, dynamic>>
        salesTrend,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
        AppSpacing.lg,
      ),
      decoration:
          BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          AppRadius.lg,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha: 0.02,
            ),
            blurRadius: 8,
            offset:
                const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ------------------------------------------------------
          // HEADER
          // ------------------------------------------------------

          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration:
                    BoxDecoration(
                  color:
                      AppColors.primary
                          .withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    AppRadius.md,
                  ),
                ),
                child: const Icon(
                  Icons.show_chart_rounded,
                  color:
                      AppColors.primary,
                  size: 19,
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sales Trend',
                      style:
                          AppTextStyles
                              .dashboardSectionTitle,
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      'Sales performance over the selected period',
                      style:
                          AppTextStyles
                              .dashboardSectionSubtitle,
                    ),
                  ],
                ),
              ),

              // --------------------------------------------------
              // PERIOD
              // --------------------------------------------------

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      AppColors.surfaceSoft,
                  borderRadius:
                      BorderRadius.circular(
                    AppRadius.sm,
                  ),
                ),
                child: Text(
                  _filterLabel(),
                  style:
                      AppTextStyles.small
                          .copyWith(
                    fontSize: 9.5,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 18,
          ),

          // ------------------------------------------------------
          // CHART
          // ------------------------------------------------------

          SizedBox(
            height: 300,
            child: SalesTrendChart(
              salesTrend: salesTrend,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK INSIGHTS
  // ============================================================

  Widget _buildQuickInsights(
    BuildContext context,
    int totalProducts,
    int lowStock,
    int outOfStock,
    double profit,
  ) {
    final hasStockWarning =
        lowStock > 0 ||
        outOfStock > 0;

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
        AppSpacing.lg,
      ),
      decoration:
          BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          AppRadius.lg,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Inventory & Business Health',
            style:
                AppTextStyles
                    .dashboardSectionTitle,
          ),

          const SizedBox(
            height: 4,
          ),

          const Text(
            'Quick indicators from your current data.',
            style:
                AppTextStyles
                    .dashboardSectionSubtitle,
          ),

          const SizedBox(
            height: 15,
          ),

          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: [
              // --------------------------------------------------
              // PRODUCTS
              // --------------------------------------------------

              _healthIndicator(
                icon:
                    Icons.inventory_2_outlined,
                label:
                    '$totalProducts products',
                color:
                    AppColors.info,
              ),

              // --------------------------------------------------
              // LOW STOCK
              // --------------------------------------------------

              _healthIndicator(
                icon:
                    Icons.warning_amber_rounded,
                label:
                    '$lowStock low-stock',
                color: lowStock > 0
                    ? AppColors.warning
                    : AppColors.success,
              ),

              // --------------------------------------------------
              // OUT OF STOCK
              // --------------------------------------------------

              _healthIndicator(
                icon:
                    Icons
                        .remove_shopping_cart_outlined,
                label:
                    '$outOfStock out of stock',
                color: outOfStock > 0
                    ? AppColors.danger
                    : AppColors.success,
              ),

              // --------------------------------------------------
              // PROFIT
              // --------------------------------------------------

              _healthIndicator(
                icon: profit >= 0
                    ? Icons.trending_up
                    : Icons.trending_down,
                label: profit >= 0
                    ? 'Profit positive'
                    : 'Profit negative',
                color: profit >= 0
                    ? AppColors.success
                    : AppColors.danger,
              ),

              // --------------------------------------------------
              // HEALTHY INVENTORY
              // --------------------------------------------------

              if (!hasStockWarning)
                _healthIndicator(
                  icon:
                      Icons.check_circle_outline,
                  label:
                      'Inventory healthy',
                  color:
                      AppColors.success,
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEALTH INDICATOR
  // ============================================================

  Widget _healthIndicator({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration:
          BoxDecoration(
        color:
            color.withValues(
          alpha: 0.07,
        ),
        borderRadius:
            BorderRadius.circular(
          AppRadius.md,
        ),
        border: Border.all(
          color:
              color.withValues(
            alpha: 0.15,
          ),
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: color,
          ),

          const SizedBox(
            width: 6,
          ),

          Text(
            label,
            style:
                AppTextStyles.small.copyWith(
              fontSize: 10.5,
              fontWeight:
                  FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _errorState(
    String title,
    String message,
  ) {
    return Padding(
      padding:
          const EdgeInsets.all(
        AppSpacing.xxl,
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
                  AppColors.danger
                      .withValues(
                alpha: 0.08,
              ),
              borderRadius:
                  BorderRadius.circular(
                AppRadius.lg,
              ),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 28,
              color: AppColors.danger,
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          Text(
            title,
            textAlign:
                TextAlign.center,
            style:
                AppTextStyles.title.copyWith(
              fontSize: 18,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 7,
          ),

          Text(
            message,
            textAlign:
                TextAlign.center,
            style:
                AppTextStyles.bodySecondary,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0.0;
  }

  int _toInt(dynamic value) {
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

  // ============================================================
  // CURRENCY
  // ============================================================

  String _formatCurrency(
    double value,
  ) {
    final formatted = value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(
            r'(\d)(?=(\d{3})+(?!\d))',
          ),
          (match) =>
              '${match.group(1)},',
        );

    return '₦$formatted';
  }
}