// lib/features/suppliers/suppliers_screen.dart


import 'package:flutter/material.dart';

import 'package:supermarket_inventory/core/widgets/back_button.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/styles.dart';
import '../../database/app_database.dart';
import '../../database/daos/supplier_dao.dart';
import '../../database/supplier_settings.dart';

import 'supplier_form_screen.dart';
import 'supplier_payment_screen.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  late final SupplierDao _supplierDao;
  late final SupplierSettings _supplierSettings;

  @override
  void initState() {
    super.initState();

    _supplierDao = getSupplierDao();
    _supplierSettings = SupplierSettings(getSettingsDao());
  }

  // ============================================================
  // LOAD SUPPLIERS
  // ============================================================

  Future<List<Supplier>> _loadSuppliers() async {
    final suppliersEnabled =
        await _supplierSettings.suppliersEnabled;

    if (!suppliersEnabled) {
      return [];
    }

    final suppliers = await _supplierDao.getAllSuppliers();

    debugPrint(
      'Loaded ${suppliers.length} suppliers',
    );

    return suppliers;
  }

  // ============================================================
  // CHECK SUPPLIER MODULE
  // ============================================================

  Future<bool> _isSuppliersEnabled() async {
    return _supplierSettings.suppliersEnabled;
  }

  // ============================================================
  // OPEN SUPPLIER DASHBOARD
  // ============================================================

  Future<void> _openSupplierDashboard(
    Supplier supplier,
  ) async {
    if (!await _isSuppliersEnabled()) {
      if (!mounted) return;

      _showDisabledMessage(
        'Supplier management is currently disabled.',
      );

      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SupplierPaymentScreen(
          supplier: supplier,
        ),
      ),
    );

    if (!mounted) return;

    setState(() {});
  }

  // ============================================================
  // ADD SUPPLIER
  // ============================================================

  Future<void> _addSupplier() async {
    if (!await _isSuppliersEnabled()) {
      if (!mounted) return;

      _showDisabledMessage(
        'Supplier management is currently disabled.',
      );

      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SupplierFormScreen(),
      ),
    );

    if (!mounted) return;

    setState(() {});
  }

  // ============================================================
  // EDIT SUPPLIER
  // ============================================================

  Future<void> _editSupplier(
    Supplier supplier,
  ) async {
    if (!await _isSuppliersEnabled()) {
      if (!mounted) return;

      _showDisabledMessage(
        'Supplier management is currently disabled.',
      );

      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SupplierFormScreen(
          existingSupplier: supplier,
        ),
      ),
    );

    if (!mounted) return;

    setState(() {});
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: AppColors.background,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        leading: const CentralBackButton(),
        title: const Text(
          'Suppliers',
          style: AppTextStyles.heading,
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Refresh suppliers',
            onPressed: () {
              setState(() {});
            },
            icon: const Icon(
              Icons.refresh,
            ),
          ),
          SizedBox(
            width: responsive.isCompact
                ? AppSpacing.xs
                : AppSpacing.sm,
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: FutureBuilder<bool>(
        future: _isSuppliersEnabled(),
        builder: (
          context,
          settingsSnapshot,
        ) {
          // ----------------------------------------------------
          // SETTINGS LOADING
          // ----------------------------------------------------

          if (settingsSnapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          // ----------------------------------------------------
          // SETTINGS ERROR
          // ----------------------------------------------------

          if (settingsSnapshot.hasError) {
            return _buildErrorState(
              settingsSnapshot.error,
            );
          }

          // ----------------------------------------------------
          // MODULE DISABLED
          // ----------------------------------------------------

          final suppliersEnabled =
              settingsSnapshot.data ?? true;

          if (!suppliersEnabled) {
            return _buildDisabledState();
          }

          // ----------------------------------------------------
          // SUPPLIERS
          // ----------------------------------------------------

          return FutureBuilder<List<Supplier>>(
            future: _loadSuppliers(),
            builder: (
              context,
              snapshot,
            ) {
              // ------------------------------------------------
              // LOADING
              // ------------------------------------------------

              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                );
              }

              // ------------------------------------------------
              // ERROR
              // ------------------------------------------------

              if (snapshot.hasError) {
                return _buildErrorState(
                  snapshot.error,
                );
              }

              // ------------------------------------------------
              // DATA
              // ------------------------------------------------

              final suppliers =
                  snapshot.data ?? [];

              if (suppliers.isEmpty) {
                return _buildEmptyState();
              }

              return _buildSupplierContent(
                suppliers,
              );
            },
          );
        },
      ),

      // ========================================================
      // ADD SUPPLIER BUTTON
      // ========================================================

      floatingActionButton: FutureBuilder<bool>(
        future: _isSuppliersEnabled(),
        builder: (
          context,
          snapshot,
        ) {
          final enabled =
              snapshot.data ?? true;

          if (!enabled) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton.extended(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            onPressed: _addSupplier,
            icon: const Icon(
              Icons.add_business_outlined,
            ),
            label: const Text(
              'Add Supplier',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // SUPPLIER CONTENT
  // ============================================================

  Widget _buildSupplierContent(
    List<Supplier> suppliers,
  ) {
    final responsive = context.responsive;

    final horizontalPadding =
        responsive.horizontalPadding;

    final maxWidth =
        responsive.contentMaxWidth;

    // Supplier cards need a little more width than
    // product cards, so we use supplier-specific columns
    // while still relying completely on your existing
    // responsive breakpoints.

    final int columns;

    if (responsive.isCompact) {
      columns = 1;
    } else if (responsive.isTablet) {
      columns = 2;
    } else if (responsive.isDesktop) {
      columns = responsive.isLargeDesktop ? 4 : 3;
    } else {
      columns = 1;
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        child: CustomScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ==================================================
            // PAGE HEADER
            // ==================================================

            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                responsive.verticalPadding,
                horizontalPadding,
                AppSpacing.md,
              ),
              sliver: SliverToBoxAdapter(
                child: _buildPageHeader(
                  suppliers.length,
                ),
              ),
            ),

            // ==================================================
            // SUPPLIER GRID
            // ==================================================

            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                AppSpacing.xs,
                horizontalPadding,
                responsive.isCompact
                    ? 88
                    : 100,
              ),
              sliver: SliverGrid(
                delegate:
                    SliverChildBuilderDelegate(
                  (context, index) {
                    final supplier =
                        suppliers[index];

                    return _SupplierCard(
                      supplier: supplier,
                      onTap: () =>
                          _openSupplierDashboard(
                        supplier,
                      ),
                      onEdit: () =>
                          _editSupplier(
                        supplier,
                      ),
                    );
                  },
                  childCount:
                      suppliers.length,
                ),
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing:
                      responsive.isCompact
                          ? 0
                          : AppSpacing.md,
                  mainAxisSpacing:
                      AppSpacing.md,
                  childAspectRatio:
                      responsive.isCompact
                          ? 2.35
                          : responsive.isTablet
                              ? 2.15
                              : 2.30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PAGE HEADER
  // ============================================================

  Widget _buildPageHeader(
    int supplierCount,
  ) {
    final responsive = context.responsive;

    final compact = responsive.isCompact;

    return Container(
      padding: EdgeInsets.all(
        compact
            ? AppSpacing.lg
            : AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.xl,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          // ----------------------------------------------------
          // ICON
          // ----------------------------------------------------

          Container(
            width: compact ? 46 : 52,
            height: compact ? 46 : 52,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius:
                  BorderRadius.circular(
                compact
                    ? AppRadius.lg
                    : AppRadius.xl,
              ),
            ),
            child: Icon(
              Icons.business_outlined,
              size: compact ? 24 : 27,
              color: AppColors.primary,
            ),
          ),

          SizedBox(
            width: compact
                ? AppSpacing.md
                : AppSpacing.lg,
          ),

          // ----------------------------------------------------
          // TEXT
          // ----------------------------------------------------

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Supplier Management',
                  style: compact
                      ? AppTextStyles.body.copyWith(
                          fontWeight:
                              FontWeight.w700,
                        )
                      : AppTextStyles.title,
                ),

                const SizedBox(
                  height: AppSpacing.xs,
                ),

                Text(
                  supplierCount == 1
                      ? '1 supplier registered'
                      : '$supplierCount suppliers registered',
                  style:
                      AppTextStyles.bodySecondary,
                ),

                const SizedBox(
                  height: 2,
                ),

                if (!compact)
                  const Text(
                    'Manage supplier accounts, deliveries, payments and balances.',
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        AppTextStyles.small,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    final responsive = context.responsive;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(
          responsive.horizontalPadding,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: responsive.isCompact
                ? double.infinity
                : AppSizes.maxFormWidth + 40,
          ),
          child: Container(
            padding: EdgeInsets.all(
              responsive.isCompact
                  ? AppSpacing.xl
                  : AppSpacing.xxxl,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius:
                  BorderRadius.circular(
                AppRadius.xl,
              ),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: responsive.isCompact
                      ? 68
                      : 76,
                  height: responsive.isCompact
                      ? 68
                      : 76,
                  decoration:
                      const BoxDecoration(
                    color:
                        AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.business_outlined,
                    size: responsive.isCompact
                        ? 36
                        : 40,
                    color:
                        AppColors.primary,
                  ),
                ),

                const SizedBox(
                  height: AppSpacing.lg,
                ),

                const Text(
                  'No suppliers yet',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.title,
                ),

                const SizedBox(
                  height: AppSpacing.sm,
                ),

                const Text(
                  'Add your first supplier to begin managing deliveries, payments and outstanding balances.',
                  textAlign: TextAlign.center,
                  style:
                      AppTextStyles.bodySecondary,
                ),

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                SizedBox(
                  height: responsive.buttonHeight,
                  child: ElevatedButton.icon(
                    onPressed: _addSupplier,
                    icon: const Icon(
                      Icons.add_business_outlined,
                    ),
                    label: const Text(
                      'Add Supplier',
                    ),
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          AppColors.primary,
                      foregroundColor:
                          Colors.white,
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal:
                            AppSpacing.xl,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          AppRadius.md,
                        ),
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
  }

  // ============================================================
  // DISABLED STATE
  // ============================================================

  Widget _buildDisabledState() {
    final responsive = context.responsive;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(
          responsive.horizontalPadding,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: responsive.isCompact
                ? double.infinity
                : AppSizes.maxFormWidth + 40,
          ),
          child: Container(
            padding: EdgeInsets.all(
              responsive.isCompact
                  ? AppSpacing.xl
                  : AppSpacing.xxxl,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius:
                  BorderRadius.circular(
                AppRadius.xl,
              ),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: responsive.isCompact
                      ? 68
                      : 76,
                  height: responsive.isCompact
                      ? 68
                      : 76,
                  decoration:
                      const BoxDecoration(
                    color:
                        AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.business_outlined,
                    size: responsive.isCompact
                        ? 36
                        : 40,
                    color:
                        AppColors.primary,
                  ),
                ),

                const SizedBox(
                  height: AppSpacing.lg,
                ),

                const Text(
                  'Supplier Management Disabled',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.title,
                ),

                const SizedBox(
                  height: AppSpacing.sm,
                ),

                const Text(
                  'Supplier management has been disabled in business settings.',
                  textAlign: TextAlign.center,
                  style:
                      AppTextStyles.bodySecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState(
    Object? error,
  ) {
    final responsive = context.responsive;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(
          responsive.horizontalPadding,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: responsive.isCompact
                ? double.infinity
                : 520,
          ),
          child: Container(
            padding: EdgeInsets.all(
              responsive.isCompact
                  ? AppSpacing.xl
                  : AppSpacing.xxl,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius:
                  BorderRadius.circular(
                AppRadius.xl,
              ),
              border: Border.all(
                color:
                    AppColors.danger.withValues(
                  alpha: 0.25,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration:
                      const BoxDecoration(
                    color:
                        AppColors.dangerLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    size: 34,
                    color:
                        AppColors.danger,
                  ),
                ),

                const SizedBox(
                  height: AppSpacing.lg,
                ),

                const Text(
                  'Unable to load suppliers',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.title,
                ),

                const SizedBox(
                  height: AppSpacing.sm,
                ),

                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style:
                      AppTextStyles.bodySecondary,
                ),

                const SizedBox(
                  height: AppSpacing.lg,
                ),

                SizedBox(
                  height: responsive.buttonHeight,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {});
                    },
                    icon: const Icon(
                      Icons.refresh,
                    ),
                    label: const Text(
                      'Try Again',
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
  // DISABLED MESSAGE
  // ============================================================

  void _showDisabledMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}

// ================================================================
// SUPPLIER CARD
// ================================================================

class _SupplierCard extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _SupplierCard({
    required this.supplier,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    final compact = responsive.isCompact;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(
        AppRadius.lg,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(
          AppRadius.lg,
        ),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(
            compact
                ? AppSpacing.md
                : AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              AppRadius.lg,
            ),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Row(
            children: [
              // =================================================
              // SUPPLIER ICON
              // =================================================

              Container(
                width: compact ? 44 : 50,
                height: compact ? 44 : 50,
                decoration: BoxDecoration(
                  color:
                      AppColors.primaryLight,
                  borderRadius:
                      BorderRadius.circular(
                    AppRadius.lg,
                  ),
                ),
                child: Icon(
                  Icons.business_outlined,
                  size: compact ? 23 : 25,
                  color:
                      AppColors.primary,
                ),
              ),

              SizedBox(
                width: compact
                    ? AppSpacing.md
                    : AppSpacing.lg,
              ),

              // =================================================
              // SUPPLIER DETAILS
              // =================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Text(
                      supplier.name,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: compact
                          ? AppTextStyles.body.copyWith(
                              fontWeight:
                                  FontWeight.w600,
                            )
                          : AppTextStyles.title,
                    ),

                    // ------------------------------------------------
                    // CONTACT
                    // ------------------------------------------------

                    if ((supplier.contact ?? '')
                        .isNotEmpty) ...[
                      const SizedBox(
                        height: AppSpacing.xs,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            size: 14,
                            color:
                                AppColors.textSecondary,
                          ),
                          const SizedBox(
                            width: AppSpacing.xs,
                          ),
                          Expanded(
                            child: Text(
                              supplier.contact!,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style:
                                  AppTextStyles.small,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // ------------------------------------------------
                    // ADDRESS
                    // ------------------------------------------------

                    if ((supplier.address ?? '')
                        .isNotEmpty) ...[
                      const SizedBox(
                        height: 2,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons
                                .location_on_outlined,
                            size: 14,
                            color:
                                AppColors.textMuted,
                          ),
                          const SizedBox(
                            width: AppSpacing.xs,
                          ),
                          Expanded(
                            child: Text(
                              supplier.address!,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style:
                                  AppTextStyles.small,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(
                width: AppSpacing.xs,
              ),

              // =================================================
              // EDIT
              // =================================================

              SizedBox(
                width: AppSizes.iconButton,
                height: AppSizes.iconButton,
                child: IconButton(
                  tooltip: 'Edit supplier',
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 19,
                  ),
                  color:
                      AppColors.textSecondary,
                  padding: EdgeInsets.zero,
                ),
              ),

              // =================================================
              // CHEVRON
              // =================================================

              Container(
                width: compact ? 30 : 34,
                height: compact ? 30 : 34,
                decoration: BoxDecoration(
                  color:
                      AppColors.surfaceSoft,
                  borderRadius:
                      BorderRadius.circular(
                    AppRadius.md,
                  ),
                ),
                child: Icon(
                  Icons.chevron_right,
                  size: compact ? 20 : 22,
                  color:
                      AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}