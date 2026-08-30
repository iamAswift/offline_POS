// lib/core/navigation/main_scaffold.dart

// ============================================================
// MAIN SCAFFOLD
// ============================================================
//
// Application-wide GoRouter shell.
//
// Primary navigation:
//
// 0 = POS
// 1 = Dashboard
// 2 = Products
// 3 = Categories
// 4 = Suppliers
// 5 = Reports
// 6 = Settings
// 7 = Users
//
// Secondary routes remain available through their own routes.
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/session.dart';
import '../../database/app_database.dart';
import '../theme/styles.dart';
import '../widgets/dashboard_sidebar.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({
    super.key,
    required this.child,
  });

  // ============================================================
  // ROLE
  // ============================================================

  Future<String> _getRole() async {
    final email =
        Session.currentUserEmail ?? '';

    if (email.isEmpty) {
      return 'staff';
    }

    try {
      final userDao = getUserDao();

      final user =
          await userDao.getUserByEmail(
        email,
      );

      return user?.role
              .trim()
              .toLowerCase() ??
          'staff';
    } catch (_) {
      return 'staff';
    }
  }

  // ============================================================
  // CENTRALIZED LOGOUT
  // ============================================================
  //
  // Every logout action from the application should eventually
  // come through this method.
  //
  // IMPORTANT:
  // This does NOT modify navigation indexes.
  // ============================================================

  Future<void> _logout(
    BuildContext context,
  ) async {
    try {
      // --------------------------------------------------------
      // Clear the persisted + in-memory session.
      // --------------------------------------------------------

      await Session.logout();

      // --------------------------------------------------------
      // Return to the login screen.
      //
      // IMPORTANT:
      // If your actual login route is not /login, change ONLY
      // this route.
      // --------------------------------------------------------

      if (!context.mounted) {
        return;
      }

      context.go('/');
    } catch (e) {
      debugPrint(
        'Logout failed: $e',
      );

      if (!context.mounted) {
        return;
      }

      // --------------------------------------------------------
      // Even if something unexpected happens, do not leave
      // the user sitting inside the authenticated area.
      // --------------------------------------------------------

      context.go('/login');
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getRole(),
      builder: (
        context,
        snapshot,
      ) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor:
                AppColors.background,
            body: Center(
              child:
                  CircularProgressIndicator(
                color:
                    AppColors.primary,
              ),
            ),
          );
        }

        final role =
            snapshot.data
                    ?.trim()
                    .toLowerCase() ??
                'staff';

        final isPrivileged =
            role == 'owner' ||
            role == 'manager' ||
            role == 'admin';

        final currentIndex =
            _calculateIndex(context);

        return Scaffold(
          backgroundColor:
              AppColors.background,
          body: Row(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [

              // ==================================================
              // SIDEBAR
              // ==================================================

              DashboardSidebar(
                selectedIndex:
                    currentIndex,

                isPrivileged:
                    isPrivileged,

                // ------------------------------------------------
                // PRIMARY NAVIGATION
                // ------------------------------------------------

                onDestinationSelected:
                    (index) {
                  _handleNavigation(
                    context,
                    index,
                    isPrivileged,
                  );
                },

                // ------------------------------------------------
                // CENTRALIZED LOGOUT
                //
                // DashboardSidebar does not perform the logout
                // itself. It simply calls this callback.
                //
                // The actual logout remains here in MainScaffold.
                // ------------------------------------------------

                onLogout: () {
                  _logout(context);
                },
              ),

              // ==================================================
              // PAGE CONTENT
              // ==================================================

              Expanded(
                child: child,
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // PRIMARY NAVIGATION
  // ============================================================

  void _handleNavigation(
    BuildContext context,
    int index,
    bool isPrivileged,
  ) {
    switch (index) {
      // --------------------------------------------------------
      // 0 — POS
      // --------------------------------------------------------

      case 0:
        context.go('/sales');
        break;

      // --------------------------------------------------------
      // 1 — DASHBOARD
      // --------------------------------------------------------

      case 1:
        context.go('/dashboard');
        break;

      // --------------------------------------------------------
      // 2 — PRODUCTS
      // --------------------------------------------------------

      case 2:
        if (isPrivileged) {
          context.go('/products');
        }
        break;

      // --------------------------------------------------------
      // 3 — CATEGORIES
      // --------------------------------------------------------

      case 3:
        if (isPrivileged) {
          context.go('/categories');
        }
        break;

      // --------------------------------------------------------
      // 4 — SUPPLIERS
      // --------------------------------------------------------

      case 4:
        if (isPrivileged) {
          context.go('/suppliers');
        }
        break;

      // --------------------------------------------------------
      // 5 — REPORTS
      // --------------------------------------------------------

      case 5:
        if (isPrivileged) {
          context.go('/reports');
        }
        break;

      // --------------------------------------------------------
      // 6 — SETTINGS
      // --------------------------------------------------------

      case 6:
        if (isPrivileged) {
          context.go('/settings');
        }
        break;

      // --------------------------------------------------------
      // 7 — USERS
      // --------------------------------------------------------

      case 7:
        if (isPrivileged) {
          context.go('/users');
        }
        break;
    }
  }

  // ============================================================
  // CURRENT PRIMARY NAVIGATION INDEX
  // ============================================================

  int _calculateIndex(
    BuildContext context,
  ) {
    final uri =
        GoRouter.of(context)
            .routerDelegate
            .currentConfiguration
            .uri;

    final path = uri.path;

    // ----------------------------------------------------------
    // 0 — POS / SALES
    // ----------------------------------------------------------

    if (path == '/sales' ||
        path.startsWith('/sales/')) {
      return 0;
    }

    // ----------------------------------------------------------
    // 1 — DASHBOARD
    // ----------------------------------------------------------

    if (path == '/dashboard' ||
        path.startsWith('/dashboard/')) {
      return 1;
    }

    // ----------------------------------------------------------
    // 2 — PRODUCTS
    // ----------------------------------------------------------

    if (path == '/products' ||
        path.startsWith('/products/')) {
      return 2;
    }

    // ----------------------------------------------------------
    // 3 — CATEGORIES
    // ----------------------------------------------------------

    if (path == '/categories' ||
        path.startsWith('/categories/')) {
      return 3;
    }

    // ----------------------------------------------------------
    // 4 — SUPPLIERS
    // ----------------------------------------------------------

    if (path == '/suppliers' ||
        path.startsWith('/suppliers/')) {
      return 4;
    }

    // ----------------------------------------------------------
    // 5 — REPORTS
    // ----------------------------------------------------------

    if (path == '/reports' ||
        path.startsWith('/reports/')) {
      return 5;
    }

    // ----------------------------------------------------------
    // 6 — SETTINGS
    // ----------------------------------------------------------

    if (path == '/settings' ||
        path.startsWith('/settings/')) {
      return 6;
    }

    // ----------------------------------------------------------
    // 7 — USERS
    // ----------------------------------------------------------

    if (path == '/users' ||
        path.startsWith('/users/')) {
      return 7;
    }

    // ----------------------------------------------------------
    // SECONDARY ROUTES
    //
    // Dashboard remains selected.
    // ----------------------------------------------------------

    return 1;
  }
}

