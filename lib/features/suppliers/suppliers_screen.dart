// lib/features/suppliers/suppliers_screen.dart

import 'package:flutter/material.dart';

import 'package:supermarket_inventory/core/widgets/back_button.dart';

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

  Future<List<Supplier>> _loadSuppliers() async {
    final suppliersEnabled =
        await _supplierSettings.suppliersEnabled;

    if (!suppliersEnabled) {
      return [];
    }

    final suppliers = await _supplierDao.getAllSuppliers();

    debugPrint('Loaded ${suppliers.length} suppliers');

    return suppliers;
  }

  // ============================================================
  // CHECK MASTER SUPPLIER SETTING
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
    return Scaffold(
      backgroundColor: AppColors.background,
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
          const SizedBox(width: 4),
        ],
      ),
      body: FutureBuilder<bool>(
        future: _isSuppliersEnabled(),
        builder: (context, settingsSnapshot) {
          // ------------------------------------------------------
          // SETTINGS LOADING
          // ------------------------------------------------------

          if (settingsSnapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          // ------------------------------------------------------
          // SETTINGS ERROR
          // ------------------------------------------------------

          if (settingsSnapshot.hasError) {
            return _buildErrorState(
              settingsSnapshot.error,
            );
          }

          // ------------------------------------------------------
          // SUPPLIER MODULE DISABLED
          // ------------------------------------------------------

          final suppliersEnabled =
              settingsSnapshot.data ?? true;

          if (!suppliersEnabled) {
            return _buildDisabledState();
          }

          // ------------------------------------------------------
          // SUPPLIERS ENABLED
          // ------------------------------------------------------

          return FutureBuilder<List<Supplier>>(
            future: _loadSuppliers(),
            builder: (context, snapshot) {
              // --------------------------------------------------
              // LOADING
              // --------------------------------------------------

              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                );
              }

              // --------------------------------------------------
              // ERROR
              // --------------------------------------------------

              if (snapshot.hasError) {
                return _buildErrorState(
                  snapshot.error,
                );
              }

              // --------------------------------------------------
              // DATA
              // --------------------------------------------------

              final suppliers = snapshot.data ?? [];

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
      floatingActionButton: FutureBuilder<bool>(
        future: _isSuppliersEnabled(),
        builder: (context, snapshot) {
          final enabled = snapshot.data ?? true;

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
  // DISABLED STATE
  // ============================================================

  Widget _buildDisabledState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 480,
          ),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.business_outlined,
                    size: 42,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Supplier Management Disabled',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.title,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Supplier management has been disabled in business settings.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SUPPLIER CONTENT
  // ============================================================

  Widget _buildSupplierContent(
    List<Supplier> suppliers,
  ) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final width = constraints.maxWidth;

        final bool isWide = width >= 600;
        final int columns = isWide ? 2 : 1;
        final double horizontalPadding =
            isWide ? 24 : 16;
        final double maxContentWidth =
            isWide ? 1200 : double.infinity;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxContentWidth,
            ),
            child: CustomScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    20,
                    horizontalPadding,
                    12,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _buildPageHeader(
                      suppliers.length,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    4,
                    horizontalPadding,
                    100,
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
                      childCount: suppliers.length,
                    ),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing:
                          isWide ? 16 : 0,
                      mainAxisSpacing: 16,
                      childAspectRatio:
                          isWide ? 2.15 : 2.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // PAGE HEADER
  // ============================================================

  Widget _buildPageHeader(
    int supplierCount,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.business_outlined,
              size: 28,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Supplier Management',
                  style: AppTextStyles.title,
                ),
                const SizedBox(height: 4),
                Text(
                  supplierCount == 1
                      ? '1 supplier registered'
                      : '$supplierCount suppliers registered',
                  style:
                      AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 2),
                const Text(
                  'Manage supplier accounts, deliveries, payments and balances.',
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: AppTextStyles.small,
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
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 480,
          ),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius:
                  BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration:
                      const BoxDecoration(
                    color:
                        AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.business_outlined,
                    size: 42,
                    color:
                        AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'No suppliers yet',
                  style: AppTextStyles.title,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add your first supplier to begin managing deliveries, payments and outstanding balances.',
                  textAlign:
                      TextAlign.center,
                  style:
                      AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 22),
                ElevatedButton.icon(
                  onPressed:
                      _addSupplier,
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
                        const EdgeInsets
                            .symmetric(
                      horizontal: 22,
                      vertical: 14,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        10,
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
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState(
    Object? error,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(
            maxWidth: 520,
          ),
          child: Container(
            padding:
                const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius:
                  BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.danger
                    .withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
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
                const SizedBox(height: 16),
                const Text(
                  'Unable to load suppliers',
                  style:
                      AppTextStyles.title,
                ),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  textAlign:
                      TextAlign.center,
                  style:
                      AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
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

// ============================================================
// SUPPLIER CARD
// ============================================================

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
    return Material(
      color: AppColors.surface,
      borderRadius:
          BorderRadius.circular(14),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color:
                      AppColors.primaryLight,
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.business_outlined,
                  size: 27,
                  color:
                      AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
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
                      style:
                          AppTextStyles.title,
                    ),
                    if ((supplier.contact ?? '')
                        .isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            size: 14,
                            color:
                                AppColors.textSecondary,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              supplier.contact!,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style:
                                  AppTextStyles
                                      .bodySecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if ((supplier.address ?? '')
                        .isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons
                                .location_on_outlined,
                            size: 14,
                            color:
                                AppColors.textMuted,
                          ),
                          const SizedBox(width: 5),
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
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Edit supplier',
                onPressed: onEdit,
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 21,
                  color:
                      AppColors.textSecondary,
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color:
                      AppColors.surfaceSoft,
                  borderRadius:
                      BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.chevron_right,
                  size: 22,
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