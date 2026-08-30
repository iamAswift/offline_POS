// lib/core/router/app_router.dart

import 'package:go_router/go_router.dart';

import 'package:supermarket_inventory/database/app_database.dart';

import 'package:supermarket_inventory/features/attendance/attendance_screen.dart';
import 'package:supermarket_inventory/features/stocks/receive_stock_screen.dart';
import 'package:supermarket_inventory/features/suppliers/stock_adjustment_screen.dart';

import '../../features/users/login_screen.dart';
import '../../features/users/user_profile_screen.dart';
import '../../features/users/initial_setup_screen.dart';
import '../../features/users/create_user_screen.dart';
import '../../features/users/user_list_screen.dart';

import '../../features/dashboard/dashboard_screen.dart';
import '../../features/products/products_screen.dart';
import '../../features/suppliers/suppliers_screen.dart';
import '../../features/sales/sales_screen.dart';

import '../../features/reports/reports_dashboard.dart';

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
    // ==========================================================
    // INITIAL LOCATION
    // ==========================================================

    initialLocation:
        needsInitialSetup
            ? '/initial-setup'
            : '/',

    routes: [
      // ==========================================================
      // LOGIN
      // ==========================================================

      GoRoute(
        path: '/',
        builder: (
          context,
          state,
        ) {
          return const LoginScreen();
        },
      ),

      // ==========================================================
      // INITIAL SETUP
      // ==========================================================

      GoRoute(
        path: '/initial-setup',
        builder: (
          context,
          state,
        ) {
          return const InitialSetupScreen();
        },
      ),

      // ==========================================================
      // MAIN APPLICATION SHELL
      //
      // MainScaffold owns the persistent sidebar.
      //
      // DashboardScreen MUST NOT create another sidebar.
      // ==========================================================

      ShellRoute(
        builder: (
          context,
          state,
          child,
        ) {
          return MainScaffold(
            child: child,
          );
        },
        routes: [
          // ======================================================
          // DASHBOARD
          // ======================================================

          GoRoute(
            path: '/dashboard',
            builder: (
              context,
              state,
            ) {
              return const DashboardScreen();
            },
          ),

          // ======================================================
          // PRODUCTS
          // ======================================================

          GoRoute(
            path: '/products',
            builder: (
              context,
              state,
            ) {
              return const ProductsScreen();
            },
          ),

          // ======================================================
          // CATEGORIES
          // ======================================================

          GoRoute(
            path: '/categories',
            builder: (
              context,
              state,
            ) {
              return const CategoryScreen();
            },
          ),

          // ======================================================
          // SUPPLIERS
          // ======================================================

          GoRoute(
            path: '/suppliers',
            builder: (
              context,
              state,
            ) {
              return const SuppliersScreen();
            },
          ),

          // ======================================================
          // SALES
          // ======================================================

          GoRoute(
            path: '/sales',
            builder: (
              context,
              state,
            ) {
              return const SalesScreen();
            },
          ),

          // ======================================================
          // REPORTS
          // ======================================================

          GoRoute(
            path: '/reports',
            builder: (
              context,
              state,
            ) {
              return ReportsDashboard(
                settingsDao:
                    SettingsDao(
                  getDatabase(),
                ),
              );
            },
          ),

          // ======================================================
          // SETTINGS
          // ======================================================

          GoRoute(
            path: '/settings',
            builder: (
              context,
              state,
            ) {
              return SettingsScreen(
                settingsDao:
                    SettingsDao(
                  getDatabase(),
                ),
              );
            },
          ),

          // ======================================================
          // USERS
          // ======================================================

          GoRoute(
            path: '/users',
            builder: (
              context,
              state,
            ) {
              return const UserListScreen();
            },
          ),

          // ======================================================
          // CREATE USER
          // ======================================================

          GoRoute(
            path: '/users/create',
            builder: (
              context,
              state,
            ) {
              return const CreateUserScreen();
            },
          ),

          // ======================================================
          // USER PROFILE
          // ======================================================

          GoRoute(
            path: '/userProfile',
            builder: (
              context,
              state,
            ) {
              final userId =
                  state.extra as int;

              return UserProfileScreen(
                userId: userId,
              );
            },
          ),

          // ======================================================
          // INVENTORY DASHBOARD
          // ======================================================

          GoRoute(
            path: '/inventory-dashboard',
            builder: (
              context,
              state,
            ) {
              return InventoryDashboardScreen(
                productDao:
                    getProductDao(),
              );
            },
          ),

          // ======================================================
          // RECEIVE STOCK
          // ======================================================

          GoRoute(
            path: '/receive-stock',
            builder: (
              context,
              state,
            ) {
              return const ReceiveStockScreen();
            },
          ),

          // ======================================================
          // STOCK ADJUSTMENT
          // ======================================================

          GoRoute(
            path: '/stock-adjustment',
            builder: (
              context,
              state,
            ) {
              return const StockAdjustmentScreen();
            },
          ),

          // ======================================================
          // ATTENDANCE
          // ======================================================

          GoRoute(
            path: '/attendance',
            builder: (
              context,
              state,
            ) {
              return const AttendanceScreen();
            },
          ),

          // ======================================================
          // STAFF PURCHASE
          // ======================================================

          GoRoute(
            path: '/staff-purchase',
            builder: (
              context,
              state,
            ) {
              return const StaffPurchaseScreen();
            },
          ),

          // ======================================================
          // STAFF DEBT MANAGEMENT
          // ======================================================

          GoRoute(
            path: '/staff-debt-management',
            builder: (
              context,
              state,
            ) {
              final currentUserId =
                  Session.currentUserId;

              if (currentUserId == null) {
                return const LoginScreen();
              }

              return StaffDebtManagementScreen(
                debtPaymentDao:
                    StaffDebtPaymentDao(
                  getDatabase(),
                ),
                staffPurchaseDao:
                    StaffPurchaseDao(
                  getDatabase(),
                ),
                recordedBy:
                    currentUserId,
              );
            },
          ),
        ],
      ),
    ],
  );
}