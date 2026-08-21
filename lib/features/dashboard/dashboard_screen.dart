// lib/features/dashboard/dashboard_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supermarket_inventory/features/reports/low_stock_report_screen.dart';
import 'package:supermarket_inventory/features/reports/out_of_stock_report_screen.dart';
import 'package:supermarket_inventory/features/users/login_screen.dart';

import '../../core/theme/styles.dart';
import '../../core/session.dart';

import '../../database/app_database.dart';
import '../../database/daos/sales_dao.dart';
import '../../database/daos/product_dao.dart';
import '../../database/daos/settings_dao.dart';

import '../reports/widgets/sales_trend_chart.dart';

import '../../features/reports/sales_reports_screen.dart';
import '../../features/reports/profit_report_screen.dart';
import '../../features/reports/stock_value_report_screen.dart';
import '../../features/reports/items_sold_report_screen.dart';
import '../../features/reports/gross_revenue_report_screen.dart';
import '../../features/products/products_screen.dart';

import '../../features/staff/staff_purchase_screen.dart';

import '../../core/business/business_identity.dart';

import 'package:flutter_svg/flutter_svg.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ============================================================
  // STATE
  // ============================================================

  int _selectedIndex = 0;

  String _businessName = BusinessIdentity.defaultBusinessName;

  String? _businessLogo;

  String _selectedFilter = 'Day';

  DateTimeRange? _selectedDateRange;

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

  void _logout(BuildContext context) async {

    //clear session data
    await Session.clearSession(); // uses core/session.dart to clear session data

    // navigate back to login screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
    
  }

  // ============================================================
  // BUSINESS IDENTITY
  // ============================================================

  Future<void> _loadBusinessIdentity() async {
    try {
      final settingsDao = SettingsDao(db);

      final businessName =
          await BusinessIdentity.getBusinessName(settingsDao);

      final businessLogo =
          await BusinessIdentity.getBusinessLogo(settingsDao);

      if (!mounted) return;

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
  // USER ROLE
  // ============================================================

  Future<String> _getRole() async {
    final userDao = getUserDao();

    final email = Session.currentUserEmail ?? '';

    final user = await userDao.getUserByEmail(email);

    return user?.role.trim().toLowerCase() ?? 'staff';
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
        final start =
            now.subtract(Duration(days: now.weekday - 1));

        return DateTimeRange(
          start: DateTime(
            start.year,
            start.month,
            start.day,
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
    return FutureBuilder<String>(
      future: _getRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: _errorState(
                'Unable to load dashboard',
                '${snapshot.error}',
              ),
            ),
          );
        }

        final role =
            snapshot.data?.trim().toLowerCase() ?? 'staff';

        final isPrivileged =
            role == 'owner' ||
            role == 'manager' ||
            role == 'admin';

        return Scaffold(
          backgroundColor: const Color(0xFFF7F8FA),

          appBar: _buildAppBar(
            context,
            isPrivileged,
          ),

          body: Row(
            children: [
              _buildNavigationRail(
                context,
                isPrivileged,
              ),

              Container(
                width: 1,
                color: Colors.grey.shade200,
              ),

              Expanded(
                child: _buildDashboardContent(),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    bool isPrivileged,
  ) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      titleSpacing: 24,

      title: Row(
        children: [
          // BUSINESS LOGO

          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color:
                  AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: _buildBusinessLogo(),
          ),

          const SizedBox(width: 12),

          // BUSINESS NAME

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _businessName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 2),

                const Text(
                  'Dashboard · Business overview',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      actions: [
        _buildFilterButton(context),

        const SizedBox(width: 12),

        Container(
          width: 1,
          height: 28,
          color: Colors.grey.shade200,
        ),

        const SizedBox(width: 12),

        Padding(
          padding:
              const EdgeInsets.only(right: 20),
          child: _buildUserBadge(),
        ),

        // logout button
        IconButton(
          tooltip: "Logout",
          icon: const Icon(Icons.logout, color: Colors.redAccent),
          onPressed: () => _logout(context),
        ),
      ],
    );
  }

  // ============================================================
  // BUSINESS LOGO
  // ============================================================

  Widget _buildBusinessLogo() {
    final logoPath = _businessLogo;

    // No logo configured.
    // Use dashboard icon as fallback.
    if (logoPath == null || logoPath.isEmpty) {
      return Icon(
        Icons.dashboard_outlined,
        color: AppColors.primary,
        size: 21,
      );
    }

    final file = File(logoPath);

    // Logo path exists but file no longer exists.
    if (!file.existsSync()) {
      return Icon(
        Icons.dashboard_outlined,
        color: AppColors.primary,
        size: 21,
      );
    }

    //SVG LOGO
    if (logoPath.toLowerCase().endsWith('.svg')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SvgPicture.file(
          file,
          width: 38,
          height: 38,
          fit: BoxFit.contain,
          placeholderBuilder: (context) {
            return Icon(
              Icons.dashboard_outlined,
              color: AppColors.primary,
              size: 21,
            );
          },
        ),
      );
    }

    //PNG/JPG LOGO
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        file,
        width: 38,
        height: 38,
        fit: BoxFit.contain,
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return Icon(
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
        if (value == 'Custom') {
          final picked =
              await showDateRangePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            initialDateRange:
                _selectedDateRange,
          );

          if (!mounted) return;

          if (picked != null) {
            setState(() {
              _selectedFilter = 'Custom';
              _selectedDateRange = picked;
            });
          }

          return;
        }

        setState(() {
          _selectedFilter = value;
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
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius:
              BorderRadius.circular(9),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: Colors.grey,
            ),

            const SizedBox(width: 8),

            Text(
              _filterLabel(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(width: 5),

            const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // USER BADGE
  // ============================================================

  Widget _buildUserBadge() {
    final loginId = Session.currentUserLoginId ?? 'User';

    final initial = loginId.isNotEmpty
        ? loginId.substring(0, 1).toUpperCase()
        : 'U';

    return Row(
      children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: AppColors.primary.withValues(alpha: 0.10),
          child: Text(
            initial,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 9),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 180),
          child: Text(
            loginId,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }


  // ============================================================
  // NAVIGATION RAIL
  // ============================================================

  Widget _buildNavigationRail(
    BuildContext context,
    bool isPrivileged,
  ) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final extended =
            MediaQuery.of(context).size.width >=
                1100;

        return NavigationRail(
          backgroundColor: Colors.white,

          selectedIndex:
              _selectedIndex,

          extended: extended,

          minWidth: 72,

          minExtendedWidth: 190,

          groupAlignment: -0.85,

          indicatorColor:
              AppColors.primary.withValues(
            alpha: 0.10,
          ),

          selectedIconTheme:
              IconThemeData(
            color: AppColors.primary,
          ),

          unselectedIconTheme:
              const IconThemeData(
            color: Colors.grey,
          ),

          selectedLabelTextStyle:
              TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),

          unselectedLabelTextStyle:
              const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),

          onDestinationSelected:
              (index) {
            setState(() {
              _selectedIndex = index;
            });

            _navigateTo(
              index,
              context,
              isPrivileged,
            );
          },

          destinations: [
            const NavigationRailDestination(
              icon: Icon(
                Icons.point_of_sale_outlined,
              ),
              selectedIcon: Icon(
                Icons.point_of_sale,
              ),
              label: Text('Sales'),
            ),

            if (isPrivileged)
              const NavigationRailDestination(
                icon: Icon(
                  Icons.inventory_2_outlined,
                ),
                selectedIcon: Icon(
                  Icons.inventory_2,
                ),
                label: Text('Products'),
              ),

            if (isPrivileged)
              const NavigationRailDestination(
                icon: Icon(
                  Icons.local_shipping_outlined,
                ),
                selectedIcon: Icon(
                  Icons.local_shipping,
                ),
                label: Text('Suppliers'),
              ),

            if (isPrivileged)
              const NavigationRailDestination(
                icon: Icon(
                  Icons.inventory_outlined,
                ),
                selectedIcon: Icon(
                  Icons.inventory,
                ),
                label: Text('Stocks'),
              ),

            if (isPrivileged)
              const NavigationRailDestination(
                icon: Icon(
                  Icons.bar_chart_outlined,
                ),
                selectedIcon: Icon(
                  Icons.bar_chart,
                ),
                label: Text('Reports'),
              ),

            if (isPrivileged)
              const NavigationRailDestination(
                icon: Icon(
                  Icons.settings_outlined,
                ),
                selectedIcon: Icon(
                  Icons.settings,
                ),
                label: Text('Settings'),
              ),

            if (isPrivileged)
              const NavigationRailDestination(
                icon: Icon(
                  Icons.category_outlined,
                ),
                selectedIcon: Icon(
                  Icons.category,
                ),
                label: Text('Categories'),
              ),

            if (isPrivileged)
              const NavigationRailDestination(
                icon: Icon(
                  Icons.people_outline,
                ),
                selectedIcon: Icon(
                  Icons.people,
                ),
                label: Text('Users'),
              ),
          ],
        );
      },
    );
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _navigateTo(
    int index,
    BuildContext context,
    bool isPrivileged,
  ) {
    switch (index) {
      case 0:
        context.push('/sales');
        break;

      case 1:
        if (isPrivileged) {
          context.push('/products');
        }
        break;

      case 2:
        if (isPrivileged) {
          context.push('/suppliers');
        }
        break;

      case 3:
        if (isPrivileged) {
          context.push('/receive-stock');
        }
        break;

      case 4:
        if (isPrivileged) {
          context.push('/reports');
        }
        break;

      case 5:
        if (isPrivileged) {
          context.push('/settings');
        }
        break;

      case 6:
        if (isPrivileged) {
          context.push('/categories');
        }
        break;

      case 7:
        if (isPrivileged) {
          context.push('/users');
        }
        break;
    }
  }

  // ============================================================
  // DASHBOARD CONTENT
  // ============================================================

  Widget _buildDashboardContent() {
    final range = _getRange();

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        salesDao.getTotalSales(
          range.start,
          range.end,
        ),

        salesDao.getItemsSold(
          range.start,
          range.end,
        ),

        salesDao.getProfit(
          range.start,
          range.end,
        ),

        salesDao.getSalesTrend(
          range.start,
          range.end,
        ),

        productDao.getAllProducts(),

        productDao.getLowStockProducts(),

        productDao.getOutOfStockProducts(),

        salesDao.getGrossRevenue(
          range.start,
          range.end,
        ),

        salesDao.getTotalStockValue(),
      ]),

      builder: (
        context,
        snapshot,
      ) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: _errorState(
              'Unable to load dashboard',
              '${snapshot.error}',
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final data = snapshot.data!;

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

        return LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final width =
                constraints.maxWidth;

            final horizontalPadding =
                width < 700
                    ? 16.0
                    : 24.0;

            return SingleChildScrollView(
              padding:
                  EdgeInsets.symmetric(
                horizontal:
                    horizontalPadding,
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
                      _buildPageHeader(
                        context,
                        totalProducts:
                            products.length,
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      _buildSummaryGrid(
                        context: context,
                        width: width,
                        totalSales:
                            totalSales,
                        products:
                            products,
                        lowStock:
                            lowStock,
                        outOfStock:
                            outOfStock,
                        profit:
                            profit,
                        stockValue:
                            stockValue,
                        itemsSold:
                            itemsSold,
                        grossRevenue:
                            grossRevenue,
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      _buildSalesTrendSection(
                        salesTrend:
                            salesTrend,
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      _buildAttendanceQuickAction(
                        context,
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      _buildQuickInsights(
                        context,
                        products.length,
                        lowStock.length,
                        outOfStock.length,
                        profit,
                      ),

                      const SizedBox(
                        height: 24,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // PAGE HEADER
  // ============================================================

  Widget _buildPageHeader(
    BuildContext context, {
    required int totalProducts,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color:
                AppColors.primary.withValues(
              alpha: 0.10,
            ),
            borderRadius:
                BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.dashboard_customize_outlined,
            color: AppColors.primary,
            size: 25,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Business Overview',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Monitor sales, inventory and '
                'business performance.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        if (MediaQuery.of(context)
                .size
                .width >=
            700)
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey.shade200,
              ),
            ),
            child: Row(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),

                const SizedBox(width: 7),

                Text(
                  '$totalProducts products',
                  style:
                      const TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ============================================================
  // ATTENDANCE QUICK ACTION
  // ============================================================

  Widget _buildAttendanceQuickAction(
    BuildContext context,
  ) {
    return Material(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(14),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(14),
        onTap: () {
          context.push('/attendance');
        },
        child: Container(
          width: double.infinity,
          padding:
              const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(14),
            border: Border.all(
              color: Colors.indigo
                  .withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.indigo
                      .withValues(alpha: 0.10),
                  borderRadius:
                      BorderRadius.circular(
                    11,
                  ),
                ),
                child: const Icon(
                  Icons.access_time_outlined,
                  color: Colors.indigo,
                  size: 23,
                ),
              ),

              const SizedBox(width: 13),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Staff Attendance',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Clock employees in or out',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY GRID
  // ============================================================

  Widget _buildSummaryGrid({
    required BuildContext context,
    required double width,
    required double totalSales,
    required List products,
    required List lowStock,
    required List outOfStock,
    required double profit,
    required double stockValue,
    required int itemsSold,
    required double grossRevenue,
  }) {
    int columns;

    if (width >= 1200) {
      columns = 4;
    } else if (width >= 850) {
      columns = 3;
    } else if (width >= 560) {
      columns = 2;
    } else {
      columns = 1;
    }

    const spacing = 14.0;

    final cardWidth = columns == 1
        ? width
        : (width -
                (spacing *
                    (columns - 1))) /
            columns;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: [
        _dashboardCard(
          width: cardWidth,
          title: 'Total Sales',
          value:
              _formatCurrency(totalSales),
          subtitle:
              'Sales for ${_selectedFilter.toLowerCase()}',
          icon:
              Icons.point_of_sale_outlined,
          color: AppColors.sales,
          destination:
              const SalesReportScreen(),
        ),

        _dashboardCard(
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

        _dashboardCard(
          width: cardWidth,
          title: 'Low Stock',
          value:
              '${lowStock.length}',
          subtitle:
              'Items need attention',
          icon:
              Icons.warning_amber_rounded,
          color: AppColors.lowstocks,
          destination:
              const LowStockReportScreen(),
        ),

        _dashboardCard(
          width: cardWidth,
          title: 'Out of Stock',
          value:
              '${outOfStock.length}',
          subtitle:
              'Items currently unavailable',
          icon:
              Icons.remove_shopping_cart_outlined,
          color: AppColors.outstocks,
          destination:
              const OutOfStockReportScreen(),
        ),

        _dashboardCard(
          width: cardWidth,
          title: 'Profit',
          value:
              _formatCurrency(profit),
          subtitle:
              'Estimated profit',
          icon:
              Icons.trending_up,
          color: AppColors.profit,
          destination:
              const ProfitReportScreen(),
        ),

        _dashboardCard(
          width: cardWidth,
          title: 'Stock Value',
          value:
              _formatCurrency(stockValue),
          subtitle:
              'Current inventory value',
          icon:
              Icons.inventory_outlined,
          color: AppColors.inventory,
          destination:
              const StockValueReportScreen(),
        ),

        _dashboardCard(
          width: cardWidth,
          title: 'Items Sold',
          value:
              '$itemsSold',
          subtitle:
              'Units sold',
          icon:
              Icons.shopping_cart_outlined,
          color: Colors.blue,
          destination:
              const ItemsSoldReportScreen(),
        ),

        _dashboardCard(
          width: cardWidth,
          title: 'Gross Revenue',
          value:
              _formatCurrency(
                grossRevenue,
              ),
          subtitle:
              'Total revenue generated',
          icon:
              Icons.payments_outlined,
          color: Colors.teal,
          destination:
              const GrossRevenueReportScreen(),
        ),

        _dashboardCard(
          width: cardWidth,
          title: 'Staff Purchases',
          value:
              _formatCurrency(
                grossRevenue,
              ),
          subtitle:
              'Manage staff Accounts',
          icon:
              Icons.payments_outlined,
          color: Colors.teal,
          destination:
              const StaffPurchaseScreen(),
        ),
      ],
    );
  }

  // ============================================================
  // DASHBOARD CARD
  // ============================================================

  Widget _dashboardCard({
    required double width,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget destination,
  }) {
    return SizedBox(
      width: width,
      child: Material(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        child: InkWell(
          borderRadius:
              BorderRadius.circular(14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    destination,
              ),
            );
          },
          child: Container(
            padding:
                const EdgeInsets.all(17),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(14),
              border: Border.all(
                color: Colors.grey.shade200,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withValues(alpha: 0.025),
                  blurRadius: 10,
                  offset:
                      const Offset(0, 3),
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
                    color: color.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      11,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 23,
                  ),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        value,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.w800,
                          color:
                              Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          fontSize: 10.5,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 6),

                Icon(
                  Icons
                      .arrow_forward_ios_rounded,
                  size: 14,
                  color:
                      Colors.grey.shade400,
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
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: 0.025),
            blurRadius: 10,
            offset:
                const Offset(0, 3),
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
                width: 38,
                height: 38,
                decoration:
                    BoxDecoration(
                  color: AppColors.primary
                      .withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    9,
                  ),
                ),
                child: Icon(
                  Icons.show_chart_rounded,
                  color:
                      AppColors.primary,
                  size: 20,
                ),
              ),

              const SizedBox(width: 11),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sales Trend',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Sales performance over the selected period',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      const Color(0xFFF7F8FA),
                  borderRadius:
                      BorderRadius.circular(
                    8,
                  ),
                ),
                child: Text(
                  _filterLabel(),
                  style:
                      const TextStyle(
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

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
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Inventory & Business Health',
            style: TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Quick indicators from your current data.',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 16),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _healthIndicator(
                icon:
                    Icons.inventory_2_outlined,
                label:
                    '$totalProducts products',
                color: Colors.blue,
              ),

              _healthIndicator(
                icon:
                    Icons.warning_amber_rounded,
                label:
                    '$lowStock low-stock',
                color: lowStock > 0
                    ? Colors.orange
                    : Colors.green,
              ),

              _healthIndicator(
                icon: Icons
                    .remove_shopping_cart_outlined,
                label:
                    '$outOfStock out of stock',
                color:
                    outOfStock > 0
                        ? Colors.red
                        : Colors.green,
              ),

              _healthIndicator(
                icon: profit >= 0
                    ? Icons.trending_up
                    : Icons.trending_down,
                label: profit >= 0
                    ? 'Profit positive'
                    : 'Profit negative',
                color: profit >= 0
                    ? Colors.green
                    : Colors.red,
              ),

              if (!hasStockWarning)
                _healthIndicator(
                  icon: Icons
                      .check_circle_outline,
                  label:
                      'Inventory healthy',
                  color: Colors.green,
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
        horizontal: 11,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.07,
        ),
        borderRadius:
            BorderRadius.circular(9),
        border: Border.all(
          color: color.withValues(
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
            size: 16,
            color: color,
          ),

          const SizedBox(width: 7),

          Text(
            label,
            style: TextStyle(
              fontSize: 11,
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
          const EdgeInsets.all(24),
      child: Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration:
                BoxDecoration(
              color: Colors.red
                  .withValues(
                alpha: 0.08,
              ),
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 28,
              color: Colors.redAccent,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            title,
            textAlign:
                TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            message,
            textAlign:
                TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
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