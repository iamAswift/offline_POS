// lib/core/router/app_router.dart

import 'package:go_router/go_router.dart';
import 'package:supermarket_inventory/database/app_database.dart';
import 'package:supermarket_inventory/features/attendance/attendance_screen.dart';
import 'package:supermarket_inventory/features/stocks/receive_stock_screen.dart';
import 'package:supermarket_inventory/features/stocks/stock_adjustment_screen.dart';

import '../../features/users/login_screen.dart';
import '../../features/users/user_profile_screen.dart';
import '../../features/users/initial_setup_screen.dart';
import '../../features/users/create_user_screen.dart';

import '../../features/dashboard/dashboard_screen.dart';
import '../../features/products/products_screen.dart';
import '../../features/suppliers/suppliers_screen.dart';
import '../../features/sales/sales_screen.dart';
import '../../features/reports/reports_dashboard.dart';
import '../../features/users/user_list_screen.dart';
import '../../features/inventory/inventory_dashboard_screen.dart';
import '../../features/category/category_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/staff/staff_purchase_screen.dart';
import '../../features/staff/staff_debt_management_screen.dart';



import 'package:supermarket_inventory/database/daos/staff_debt_payment_dao.dart';

import 'package:supermarket_inventory/database/daos/settings_dao.dart';
import 'package:supermarket_inventory/database/daos/staff_purchase_dao.dart';

import '../navigation/main_scaffold.dart';
import '../session.dart';

GoRouter appRouter({
  required bool needsInitialSetup,
}) {
  return GoRouter(
    // ------------------------------------------------------------
    // FIRST-START ROUTING
    //
    // If there are no users in the database:
    //     → /initial-setup
    //
    // If an owner already exists:
    //     → /
    // ------------------------------------------------------------

    initialLocation:
        needsInitialSetup ? '/initial-setup' : '/',

    routes: [
      // ----------------------------------------------------------
      // LOGIN
      // ----------------------------------------------------------

      GoRoute(
        path: '/',
        builder: (context, state) => const LoginScreen(),
      ),

      // ----------------------------------------------------------
      // FIRST OWNER SETUP
      // ----------------------------------------------------------

      GoRoute(
        path: '/initial-setup',
        builder: (context, state) =>
            const InitialSetupScreen(),
      ),

      // ----------------------------------------------------------
      // MAIN APPLICATION SHELL
      // ----------------------------------------------------------

      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(
            child: child,
          );
        },

        routes: [
          // ------------------------------------------------------
          // DASHBOARD
          // ------------------------------------------------------

          GoRoute(
            path: '/dashboard',
            builder: (context, state) =>
                const DashboardScreen(),
          ),

          // ------------------------------------------------------
          // PRODUCTS
          // ------------------------------------------------------

          GoRoute(
            path: '/products',
            builder: (context, state) =>
                const ProductsScreen(),
          ),

          // ------------------------------------------------------
          // SUPPLIERS
          // ------------------------------------------------------

          GoRoute(
            path: '/suppliers',
            builder: (context, state) =>
                const SuppliersScreen(),
          ),

          // ------------------------------------------------------
          // RECEIVE STOCK
          // ------------------------------------------------------

          GoRoute(
            path: '/receive-stock',
            builder: (context, state) =>
                const ReceiveStockScreen(),
          ),

          GoRoute(
            path: '/stock-adjustment',
            builder: (context, state) =>
                const StockAdjustmentScreen(),
          ),

          // ------------------------------------------------------
          // SALES
          // ------------------------------------------------------

          GoRoute(
            path: '/sales',
            builder: (context, state) =>
                const SalesScreen(),
          ),

          // ------------------------------------------------------
          // REPORTS
          // ------------------------------------------------------

          GoRoute(
            path: '/reports',
            builder: (context, state) =>
                ReportsDashboard(
              settingsDao: SettingsDao(getDatabase()),
            ),
          ),

          // ------------------------------------------------------
          // INVENTORY DASHBOARD
          // ------------------------------------------------------

          GoRoute(
            path: '/inventory-dashboard',
            builder: (context, state) =>
                InventoryDashboardScreen(
              productDao: getProductDao(),
            ),
          ),

          // ------------------------------------------------------
          // SETTINGS
          // ------------------------------------------------------

          GoRoute(
            path: '/settings',
            builder: (context, state) =>
                SettingsScreen(
              settingsDao:
                  SettingsDao(getDatabase()),
            ),
          ),

          // ------------------------------------------------------
          // USERS
          // ------------------------------------------------------

          GoRoute(
            path: '/users',
            builder: (context, state) =>
                const UserListScreen(),
          ),

          // ------------------------------------------------------
          // CATEGORIES
          // ------------------------------------------------------

          GoRoute(
            path: '/categories',
            builder: (context, state) =>
                const CategoryScreen(),
          ),

          // ------------------------------------------------------
          // USER PROFILE
          // ------------------------------------------------------

          GoRoute(
            path: '/userProfile',
            builder: (context, state) {
              final userId = state.extra as int;

              return UserProfileScreen(
                userId: userId,
              );
            },
          ),

          // ------------------------------------------------------
          // CREATE USER
          // ------------------------------------------------------
          GoRoute(
            path: '/users/create',
            builder: (context, state) =>
                const CreateUserScreen(),
          ),
          GoRoute(
            path: '/attendance',
            builder: (context, state) =>
                const AttendanceScreen(),
          ),

          GoRoute(
            path: '/staff-purchase',
            builder: (context, state) =>
                const StaffPurchaseScreen(),
          ),
          GoRoute(
            path: '/staff-purchase',
            builder: (context, state) =>
                const StaffPurchaseScreen(),
          ),

          GoRoute(
            path: '/staff-debt-management',
            builder: (context, state) {
              final currentUserId = Session.currentUserId;

              if (currentUserId == null) {
                return const LoginScreen();
              }

              return StaffDebtManagementScreen(
                debtPaymentDao:
                    StaffDebtPaymentDao(getDatabase()),
                staffPurchaseDao:
                    StaffPurchaseDao(getDatabase()),
                recordedBy: currentUserId,
              );
            },
          ),
        ],
      ),
    ],
  );
}

