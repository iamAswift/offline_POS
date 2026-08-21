//lib/core/navigation/main_scaffold.dart

// ============================================================
// MAIN SCAFFOLD
// ============================================================
// Role-aware application navigation.
//
// Owner / Manager:
//   Dashboard
//   Products
//   Suppliers
//   Receive Stock
//
// Staff:
//   Dashboard
//   Sales
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/styles.dart';
import '../../database/app_database.dart';
import '../../core/session.dart';

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
    final userDao = getUserDao();

    final email = Session.currentUserEmail ?? "";

    if (email.isEmpty) {
      return "staff";
    }

    final user = await userDao.getUserByEmail(email);

    return user?.role.trim().toLowerCase() ?? "staff";
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateIndex(context);

    return FutureBuilder<String>(
      future: _getRole(),
      builder: (context, snapshot) {
        // --------------------------------------------------------
        // Loading
        // --------------------------------------------------------

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
          );
        }

        // --------------------------------------------------------
        // Error / fallback
        // --------------------------------------------------------

        final role = snapshot.data ?? "staff";

        final isPrivileged =
            role == "owner" || role == "manager";

        // --------------------------------------------------------
        // Navigation items
        // --------------------------------------------------------

        final items = _buildNavigationItems(
          isPrivileged: isPrivileged,
        );

        // --------------------------------------------------------
        // Safety check
        // --------------------------------------------------------

        final safeIndex =
            currentIndex >= 0 && currentIndex < items.length
                ? currentIndex
                : 0;

        return Scaffold(
          backgroundColor: AppColors.background,

          // ======================================================
          // PAGE CONTENT
          // ======================================================

          body: child,

          // ======================================================
          // BOTTOM NAVIGATION
          // ======================================================

          bottomNavigationBar: _ProfessionalBottomNavigation(
            items: items,
            currentIndex: safeIndex,
            onTap: (index) {
              _handleNavigation(
                context,
                index,
                isPrivileged,
              );
            },
          ),
        );
      },
    );
  }

  // ============================================================
  // NAVIGATION ITEMS
  // ============================================================

  List<_NavigationItem> _buildNavigationItems({
    required bool isPrivileged,
  }) {
    if (isPrivileged) {
      return const [
        _NavigationItem(
          label: "Dashboard",
          icon: Icons.dashboard_outlined,
          activeIcon: Icons.dashboard_rounded,
          route: "/dashboard",
        ),
        _NavigationItem(
          label: "Products",
          icon: Icons.inventory_2_outlined,
          activeIcon: Icons.inventory_2_rounded,
          route: "/products",
        ),
        _NavigationItem(
          label: "Suppliers",
          icon: Icons.local_shipping_outlined,
          activeIcon: Icons.local_shipping_rounded,
          route: "/suppliers",
        ),
        _NavigationItem(
          label: "Receive",
          icon: Icons.add_box_outlined,
          activeIcon: Icons.add_box_rounded,
          route: "/receive-stock",
        ),
      ];
    }

    return const [
      _NavigationItem(
        label: "Dashboard",
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard_rounded,
        route: "/dashboard",
      ),
      _NavigationItem(
        label: "Sales",
        icon: Icons.point_of_sale_outlined,
        activeIcon: Icons.point_of_sale_rounded,
        route: "/sales",
      ),
    ];
  }

  // ============================================================
  // NAVIGATION HANDLER
  // ============================================================

  void _handleNavigation(
    BuildContext context,
    int index,
    bool isPrivileged,
  ) {
    if (isPrivileged) {
      switch (index) {
        case 0:
          context.go("/dashboard");
          break;

        case 1:
          context.go("/products");
          break;

        case 2:
          context.go("/suppliers");
          break;

        case 3:
          context.go("/receive-stock");
          break;
      }

      return;
    }

    // ----------------------------------------------------------
    // Staff navigation
    // ----------------------------------------------------------

    switch (index) {
      case 0:
        context.go("/dashboard");
        break;

      case 1:
        context.go("/sales");
        break;
    }
  }

  // ============================================================
  // CURRENT TAB
  // ============================================================

  int _calculateIndex(BuildContext context) {
    final uri = GoRouter.of(context)
        .routerDelegate
        .currentConfiguration
        .uri;

    final path = uri.path;

    if (path.startsWith("/products")) {
      return 1;
    }

    if (path.startsWith("/suppliers")) {
      return 2;
    }

    if (path.startsWith("/receive-stock")) {
      return 3;
    }

    if (path.startsWith("/sales")) {
      return 1;
    }

    return 0;
  }
}

// ============================================================
// NAVIGATION ITEM MODEL
// ============================================================

class _NavigationItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const _NavigationItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}

// ============================================================
// PROFESSIONAL BOTTOM NAVIGATION
// ============================================================

class _ProfessionalBottomNavigation extends StatelessWidget {
  final List<_NavigationItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _ProfessionalBottomNavigation({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            12,
            8,
            12,
            8,
          ),
          child: Row(
            children: List.generate(
              items.length,
              (index) {
                final item = items[index];

                return Expanded(
                  child: _NavigationButton(
                    item: item,
                    selected: index == currentIndex,
                    onTap: () => onTap(index),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// NAVIGATION BUTTON
// ============================================================

class _NavigationButton extends StatelessWidget {
  final _NavigationItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavigationButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryLight
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: selected ? 42 : 36,
              height: selected ? 32 : 28,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                selected
                    ? item.activeIcon
                    : item.icon,
                size: selected ? 21 : 20,
                color: selected
                    ? Colors.white
                    : AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 11,
                fontWeight: selected
                    ? FontWeight.w600
                    : FontWeight.w500,
                color: selected
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}