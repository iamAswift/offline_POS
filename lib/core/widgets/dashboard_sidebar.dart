// lib/core/widgets/dashboard_sidebar.dart

import 'package:flutter/material.dart';

import '../responsive/responsive.dart';
import '../theme/styles.dart';

class DashboardSidebar extends StatefulWidget {
  const DashboardSidebar({
    super.key,
    required this.selectedIndex,
    required this.isPrivileged,
    required this.onDestinationSelected,
    this.onLogout,
  });

  final int selectedIndex;
  final bool isPrivileged;
  final ValueChanged<int> onDestinationSelected;

  // ============================================================
  // LOGOUT CALLBACK
  // ============================================================

  final VoidCallback? onLogout;

  @override
  State<DashboardSidebar> createState() =>
      _DashboardSidebarState();
}

class _DashboardSidebarState
    extends State<DashboardSidebar> {
  // ============================================================
  // DESTINATIONS
  //
  // IMPORTANT:
  //
  // These indexes MUST remain synchronized with:
  //
  // MainScaffold._handleNavigation()
  // MainScaffold._calculateIndex()
  //
  // 0 = POS
  // 1 = Dashboard
  // 2 = Products
  // 3 = Categories
  // 4 = Suppliers
  // 5 = Reports
  // 6 = Settings
  // 7 = Users
  // ============================================================

  List<_SidebarDestination> get _destinations {
    return [
      // ----------------------------------------------------------
      // 0 — POS
      // ----------------------------------------------------------

      const _SidebarDestination(
        icon: Icons.point_of_sale_outlined,
        selectedIcon: Icons.point_of_sale,
        label: 'POS',
      ),

      // ----------------------------------------------------------
      // 1 — DASHBOARD
      // ----------------------------------------------------------

      const _SidebarDestination(
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard,
        label: 'Dashboard',
      ),

      // ----------------------------------------------------------
      // PRIVILEGED NAVIGATION
      // ----------------------------------------------------------

      if (widget.isPrivileged)
        const _SidebarDestination(
          icon: Icons.inventory_2_outlined,
          selectedIcon: Icons.inventory_2,
          label: 'Products',
        ),

      if (widget.isPrivileged)
        const _SidebarDestination(
          icon: Icons.category_outlined,
          selectedIcon: Icons.category,
          label: 'Categories',
        ),

      if (widget.isPrivileged)
        const _SidebarDestination(
          icon: Icons.local_shipping_outlined,
          selectedIcon: Icons.local_shipping,
          label: 'Suppliers',
        ),

      if (widget.isPrivileged)
        const _SidebarDestination(
          icon: Icons.bar_chart_outlined,
          selectedIcon: Icons.bar_chart,
          label: 'Reports',
        ),

      if (widget.isPrivileged)
        const _SidebarDestination(
          icon: Icons.settings_outlined,
          selectedIcon: Icons.settings,
          label: 'Settings',
        ),

      if (widget.isPrivileged)
        const _SidebarDestination(
          icon: Icons.people_outline,
          selectedIcon: Icons.people,
          label: 'Users',
        ),
    ];
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    final extended =
        responsive.isDesktop ||
        responsive.isLargeDesktop;

    final sidebarWidth =
        extended ? 190.0 : 72.0;

    return Material(
      color: AppColors.surface,
      child: Container(
        width: sidebarWidth,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            right: BorderSide(
              color: AppColors.border,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ==================================================
              // NAVIGATION
              // ==================================================

              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: AppSpacing.md,
                  ),
                  child: Column(
                    children: [
                      for (
                        int index = 0;
                        index <
                            _destinations.length;
                        index++
                      )
                        _buildDestination(
                          context,
                          index: index,
                          destination:
                              _destinations[index],
                          extended: extended,
                        ),
                    ],
                  ),
                ),
              ),

              // ==================================================
              // LOGOUT
              //
              // This is intentionally outside the navigation
              // list and does NOT have a navigation index.
              // ==================================================

              if (widget.onLogout != null)
                _buildLogout(
                  context,
                  extended: extended,
                ),

              const SizedBox(
                height: AppSpacing.sm,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================
  //
  // Logout is intentionally NOT part of _destinations.
  //
  // It therefore does not affect:
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
  // The actual logout operation remains centralized in
  // MainScaffold._logout().
  // ============================================================

  Widget _buildLogout(
    BuildContext context, {
    required bool extended,
  }) {
    // ==========================================================
    // EXTENDED SIDEBAR
    // ==========================================================

    if (extended) {
      return Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        child: Tooltip(
          message: 'Logout',
          waitDuration:
              const Duration(
            milliseconds: 180,
          ),
          showDuration:
              const Duration(
            seconds: 2,
          ),
          preferBelow: false,
          verticalOffset: 8,
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            borderRadius:
                BorderRadius.circular(
              AppRadius.sm,
            ),
            border: Border.all(
              color:
                  Colors.black.withValues(
                alpha: 0.05,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withValues(
                  alpha: 0.14,
                ),
                blurRadius: 12,
                offset:
                    const Offset(2, 4),
              ),
            ],
          ),
          textStyle:
              AppTextStyles.small.copyWith(
            color: Colors.white,
            fontSize: 11,
            fontWeight:
                FontWeight.w600,
            letterSpacing: 0.1,
          ),
          padding:
              const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 8,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius:
                BorderRadius.circular(
              AppRadius.lg,
            ),
            child: InkWell(
              borderRadius:
                  BorderRadius.circular(
                AppRadius.lg,
              ),
              mouseCursor:
                  SystemMouseCursors.click,
              onTap: () {
                widget.onLogout?.call();
              },
              child: Container(
                width: double.infinity,
                height: 48,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal:
                      AppSpacing.md,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      AppColors.dangerLight,
                  borderRadius:
                      BorderRadius.circular(
                    AppRadius.lg,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.logout_outlined,
                      size: 22,
                      color:
                          AppColors.danger,
                    ),

                    const SizedBox(
                      width: AppSpacing.md,
                    ),

                    Expanded(
                      child: Text(
                        'Logout',
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            AppTextStyles.small
                                .copyWith(
                          color:
                              AppColors.danger,
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w700,
                          letterSpacing:
                              0.15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // ==========================================================
    // COLLAPSED SIDEBAR
    // ==========================================================

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Tooltip(
        message: 'Logout',
        waitDuration:
            const Duration(
          milliseconds: 180,
        ),
        showDuration:
            const Duration(
          seconds: 2,
        ),
        preferBelow: false,
        verticalOffset: 8,
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius:
              BorderRadius.circular(
            AppRadius.sm,
          ),
          border: Border.all(
            color:
                Colors.black.withValues(
              alpha: 0.05,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withValues(
                alpha: 0.14,
              ),
              blurRadius: 12,
              offset:
                  const Offset(2, 4),
            ),
          ],
        ),
        textStyle:
            AppTextStyles.small.copyWith(
          color: Colors.white,
          fontSize: 11,
          fontWeight:
              FontWeight.w600,
          letterSpacing: 0.1,
        ),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 8,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius:
              BorderRadius.circular(
            AppRadius.lg,
          ),
          child: InkWell(
            borderRadius:
                BorderRadius.circular(
              AppRadius.lg,
            ),
            mouseCursor:
                SystemMouseCursors.click,
            onTap: () {
              widget.onLogout?.call();
            },
            child: Container(
              width: double.infinity,
              height: 48,
              decoration:
                  BoxDecoration(
                color:
                    AppColors.dangerLight,
                borderRadius:
                    BorderRadius.circular(
                  AppRadius.lg,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.logout_outlined,
                  size: 22,
                  color:
                      AppColors.danger,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DESTINATION
  // ============================================================

  Widget _buildDestination(
    BuildContext context, {
    required int index,
    required _SidebarDestination destination,
    required bool extended,
  }) {
    final isSelected =
        widget.selectedIndex == index;

    if (extended) {
      return _buildExtendedDestination(
        context,
        index: index,
        destination: destination,
        isSelected: isSelected,
      );
    }

    return _buildCollapsedDestination(
      context,
      index: index,
      destination: destination,
      isSelected: isSelected,
    );
  }

  // ============================================================
  // EXTENDED DESTINATION
  // ============================================================

  Widget _buildExtendedDestination(
    BuildContext context, {
    required int index,
    required _SidebarDestination destination,
    required bool isSelected,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius:
            BorderRadius.circular(
          AppRadius.lg,
        ),
        child: InkWell(
          borderRadius:
              BorderRadius.circular(
            AppRadius.lg,
          ),
          mouseCursor:
              SystemMouseCursors.click,
          onTap: () {
            widget.onDestinationSelected(
              index,
            );
          },
          child: AnimatedContainer(
            duration:
                const Duration(
              milliseconds: 160,
            ),
            curve: Curves.easeOut,
            width: double.infinity,
            height: 48,
            padding:
                const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(
                      alpha: 0.10,
                    )
                  : Colors.transparent,
              borderRadius:
                  BorderRadius.circular(
                AppRadius.lg,
              ),
            ),
            child: Row(
              children: [
                _buildIcon(
                  destination,
                  isSelected,
                ),

                const SizedBox(
                  width: AppSpacing.md,
                ),

                Expanded(
                  child: Text(
                    destination.label,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        AppTextStyles.small
                            .copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors
                              .textSecondary,
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      letterSpacing: 0.15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // COLLAPSED DESTINATION
  // ============================================================

  Widget _buildCollapsedDestination(
    BuildContext context, {
    required int index,
    required _SidebarDestination destination,
    required bool isSelected,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      child: Tooltip(
        message: destination.label,
        waitDuration:
            const Duration(
          milliseconds: 180,
        ),
        showDuration:
            const Duration(
          seconds: 2,
        ),
        preferBelow: false,
        verticalOffset: 8,
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius:
              BorderRadius.circular(
            AppRadius.sm,
          ),
          border: Border.all(
            color:
                Colors.black.withValues(
              alpha: 0.05,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withValues(
                alpha: 0.14,
              ),
              blurRadius: 12,
              offset:
                  const Offset(2, 4),
            ),
          ],
        ),
        textStyle:
            AppTextStyles.small.copyWith(
          color: Colors.white,
          fontSize: 11,
          fontWeight:
              FontWeight.w600,
          letterSpacing: 0.1,
        ),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 8,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius:
              BorderRadius.circular(
            AppRadius.lg,
          ),
          child: InkWell(
            borderRadius:
                BorderRadius.circular(
              AppRadius.lg,
            ),
            mouseCursor:
                SystemMouseCursors.click,
            onTap: () {
              widget.onDestinationSelected(
                index,
              );
            },
            child: AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 160,
              ),
              curve: Curves.easeOut,
              width: double.infinity,
              height: 48,
              decoration:
                  BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                        .withValues(
                        alpha: 0.10,
                      )
                    : Colors.transparent,
                borderRadius:
                    BorderRadius.circular(
                  AppRadius.lg,
                ),
              ),
              child: Center(
                child: _buildIcon(
                  destination,
                  isSelected,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ICON
  // ============================================================

  Widget _buildIcon(
    _SidebarDestination destination,
    bool isSelected,
  ) {
    return AnimatedSwitcher(
      duration:
          const Duration(
        milliseconds: 150,
      ),
      transitionBuilder:
          (
        Widget child,
        Animation<double> animation,
      ) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation,
            child: child,
          ),
        );
      },
      child: Icon(
        isSelected
            ? destination.selectedIcon
            : destination.icon,
        key: ValueKey(
          '${destination.label}-$isSelected',
        ),
        size: 22,
        color: isSelected
            ? AppColors.primary
            : AppColors.textSecondary,
      ),
    );
  }
}

// ================================================================
// SIDEBAR DESTINATION MODEL
// ================================================================

class _SidebarDestination {
  const _SidebarDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
