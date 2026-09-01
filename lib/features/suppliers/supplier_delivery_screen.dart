// lib/features/suppliers/supplier_deliveries_screen.dart

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import 'package:supermarket_inventory/core/responsive/responsive.dart';
import 'package:supermarket_inventory/core/widgets/back_button.dart';

import '../../core/theme/styles.dart';
import '../../database/app_database.dart';
import '../../database/daos/product_dao.dart';
import '../../database/daos/supplier_delivery_dao.dart';

class SupplierDeliveriesScreen extends StatefulWidget {
  final Supplier supplier;

  const SupplierDeliveriesScreen({
    super.key,
    required this.supplier,
  });

  @override
  State<SupplierDeliveriesScreen> createState() =>
      _SupplierDeliveriesScreenState();
}

class _SupplierDeliveriesScreenState
    extends State<SupplierDeliveriesScreen> {
  late final SupplierDeliveryDao _deliveryDao;

  bool _loading = true;

  List<SupplierDelivery> _deliveries = [];

  double _totalPurchases = 0;

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _deliveryDao = getSupplierDeliveryDao();

    _loadDeliveries();
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> _loadDeliveries() async {
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

    try {
      final supplierId = widget.supplier.id;

      final results = await Future.wait([
        _deliveryDao.getDeliveriesForSupplier(supplierId),
        _deliveryDao.getSupplierPurchaseTotal(supplierId),
      ]);

      final deliveries = results[0] as List<SupplierDelivery>;
      final total = results[1] as double;

      if (!mounted) return;

      setState(() {
        _deliveries = deliveries;
        _totalPurchases = total;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Supplier deliveries error: $e');

      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      _showError(
        'Unable to load supplier deliveries.\n$e',
      );
    }
  }

  // ============================================================
  // FILTER
  // ============================================================

  List<SupplierDelivery> get _filteredDeliveries {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return _deliveries;
    }

    return _deliveries.where((delivery) {
      final invoice = delivery.invoiceNumber ?? '';
      final notes = delivery.notes ?? '';

      return invoice.toLowerCase().contains(query) ||
          notes.toLowerCase().contains(query) ||
          delivery.id.toString().contains(query);
    }).toList();
  }

  // ============================================================
  // ADD DELIVERY
  // ============================================================

  Future<void> _showAddDeliveryDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _AddDeliveryDialog(
          supplier: widget.supplier,
          deliveryDao: _deliveryDao,
        );
      },
    );

    if (result == true) {
      await _loadDeliveries();
    }
  }

  // ============================================================
  // DETAILS
  // ============================================================

  Future<void> _openDeliveryDetails(
    SupplierDelivery delivery,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _DeliveryDetailsSheet(
          delivery: delivery,
          deliveryDao: _deliveryDao,
        );
      },
    );
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _confirmDelete(
    SupplierDelivery delivery,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Delivery',
            style: AppTextStyles.title,
          ),
          content: Text(
            'Delete delivery #${delivery.id}?\n\n'
            'This removes the delivery record and its delivery items.',
            style: AppTextStyles.body,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _deliveryDao.deleteDelivery(delivery.id);

      await _loadDeliveries();

      if (!mounted) return;

      _showMessage('Delivery deleted.');
    } catch (e) {
      _showError(
        'Unable to delete delivery.\n$e',
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        leading: const CentralBackButton(),

        title: const Text(
          'Deliveries',
          style: AppTextStyles.heading,
        ),

        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,

        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _loadDeliveries,
            icon: const Icon(Icons.refresh),
          ),
          SizedBox(
            width: responsive.isCompact ? 4 : 8,
          ),
        ],
      ),

      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _loadDeliveries,

              child: CustomScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),

                slivers: [
                  // ========================================================
                  // HEADER
                  // ========================================================

                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      responsive.horizontalPadding,
                      responsive.isCompact ? 12 : 16,
                      responsive.horizontalPadding,
                      8,
                    ),

                    sliver: SliverToBoxAdapter(
                      child: _buildHeader(),
                    ),
                  ),

                  // ========================================================
                  // SEARCH
                  // ========================================================

                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      responsive.horizontalPadding,
                      8,
                      responsive.horizontalPadding,
                      8,
                    ),

                    sliver: SliverToBoxAdapter(
                      child: _buildSearch(),
                    ),
                  ),

                  // ========================================================
                  // CONTENT
                  // ========================================================

                  if (_filteredDeliveries.isEmpty)

                    // ------------------------------------------------------
                    // IMPORTANT:
                    //
                    // hasScrollBody is true here because the empty state
                    // can be taller than the remaining viewport on the
                    // CM8800plus.
                    //
                    // This prevents:
                    //
                    // RenderFlex overflowed by X pixels on the bottom.
                    // ------------------------------------------------------

                    SliverFillRemaining(
                      hasScrollBody: true,
                      child: _buildEmptyState(),
                    )

                  else
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        responsive.horizontalPadding,
                        8,
                        responsive.horizontalPadding,
                        110,
                      ),

                      sliver: SliverLayoutBuilder(
                        builder: (
                          context,
                          constraints,
                        ) {
                          final width =
                              constraints.crossAxisExtent;

                          // ------------------------------------------------
                          // CM8800plus:
                          //
                          // Physical: 800 x 1280
                          // Density override: 248
                          // Flutter logical width ≈ 516
                          //
                          // Keep ONE column here.
                          // ------------------------------------------------

                          int columns;

                          if (width >= 1150) {
                            columns = 3;
                          } else if (width >= 760) {
                            columns = 2;
                          } else {
                            columns = 1;
                          }

                          final double aspectRatio;

                          if (columns == 1) {
                            aspectRatio = width < 600
                                ? 1.72
                                : 1.85;
                          } else if (columns == 2) {
                            aspectRatio = 1.48;
                          } else {
                            aspectRatio = 1.38;
                          }

                          return SliverGrid(
                            delegate:
                                SliverChildBuilderDelegate(
                              (
                                context,
                                index,
                              ) {
                                final delivery =
                                    _filteredDeliveries[index];

                                return _DeliveryCard(
                                  delivery: delivery,
                                  deliveryDao: _deliveryDao,
                                  onTap: () =>
                                      _openDeliveryDetails(
                                    delivery,
                                  ),
                                  onDelete: () =>
                                      _confirmDelete(
                                    delivery,
                                  ),
                                );
                              },
                              childCount:
                                  _filteredDeliveries.length,
                            ),

                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio:
                                  aspectRatio,
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

      // ============================================================
      // RECEIVE DELIVERY
      // ============================================================

      floatingActionButton:
          FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,

        onPressed: _showAddDeliveryDialog,

        icon: const Icon(
          Icons.local_shipping_outlined,
        ),

        label: const Text(
          'Receive Delivery',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    final responsive = context.responsive;

    return Container(
      padding: EdgeInsets.all(
        responsive.isCompact ? 16 : 20,
      ),

      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.center,

            children: [
              Container(
                width:
                    responsive.isCompact
                        ? 50
                        : 56,

                height:
                    responsive.isCompact
                        ? 50
                        : 56,

                decoration: BoxDecoration(
                  color:
                      AppColors.primaryLight,
                  borderRadius:
                      BorderRadius.circular(15),
                ),

                child: Icon(
                  Icons.local_shipping_outlined,
                  color:
                      AppColors.primary,
                  size:
                      responsive.isCompact
                          ? 26
                          : 29,
                ),
              ),

              SizedBox(
                width:
                    responsive.isCompact
                        ? 11
                        : 14,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      widget.supplier.name,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          AppTextStyles.heading,
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'Supplier delivery history',
                      style:
                          AppTextStyles
                              .bodySecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(
            height:
                responsive.isCompact
                    ? 16
                    : 20,
          ),

          LayoutBuilder(
            builder: (
              context,
              constraints,
            ) {
              final compact =
                  constraints.maxWidth < 500;

              if (compact) {
                return Column(
                  children: [
                    _buildMetric(
                      icon:
                          Icons
                              .local_shipping_outlined,
                      label:
                          'Deliveries',
                      value:
                          '${_deliveries.length}',
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    _buildMetric(
                      icon:
                          Icons
                              .account_balance_wallet_outlined,
                      label:
                          'Purchase Value',
                      value:
                          _money(
                        _totalPurchases,
                      ),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _buildMetric(
                      icon:
                          Icons
                              .local_shipping_outlined,
                      label:
                          'Deliveries',
                      value:
                          '${_deliveries.length}',
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child: _buildMetric(
                      icon:
                          Icons
                              .account_balance_wallet_outlined,
                      label:
                          'Purchase Value',
                      value:
                          _money(
                        _totalPurchases,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetric({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(14),

      decoration:
          BoxDecoration(
        color:
            AppColors.background,
        borderRadius:
            BorderRadius.circular(13),
        border: Border.all(
          color:
              AppColors.border,
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,

            decoration:
                BoxDecoration(
              color:
                  AppColors.primaryLight,
              borderRadius:
                  BorderRadius.circular(
                10,
              ),
            ),

            child: Icon(
              icon,
              color:
                  AppColors.primary,
              size: 20,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  label,
                  style:
                      AppTextStyles.small,
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      AppTextStyles.price,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearch() {
    return TextField(
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },

      decoration: InputDecoration(
        hintText:
            'Search invoice, delivery number or notes...',

        prefixIcon:
            const Icon(Icons.search),

        suffixIcon:
            _searchQuery.isEmpty
                ? null
                : IconButton(
                    tooltip:
                        'Clear search',
                    onPressed: () {
                      setState(() {
                        _searchQuery =
                            '';
                      });
                    },
                    icon:
                        const Icon(
                      Icons.clear,
                    ),
                  ),

        filled: true,
        fillColor:
            AppColors.surface,

        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(13),
          borderSide:
              const BorderSide(
            color:
                AppColors.border,
          ),
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(13),
          borderSide:
              const BorderSide(
            color:
                AppColors.border,
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(13),
          borderSide:
              const BorderSide(
            color:
                AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    final searching =
        _searchQuery.trim().isNotEmpty;

    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        return SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),

          padding:
              const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),

          child: ConstrainedBox(
            constraints:
                BoxConstraints(
              minHeight:
                  constraints.maxHeight,
            ),

            child: Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 8,
                ),

                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(
                    maxWidth: 430,
                  ),

                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,

                    children: [
                      // ==================================================
                      // ICON
                      // ==================================================

                      Container(
                        width: 76,
                        height: 76,

                        decoration:
                            const BoxDecoration(
                          color:
                              AppColors
                                  .primaryLight,
                          shape:
                              BoxShape.circle,
                        ),

                        child: Icon(
                          searching
                              ? Icons.search_off
                              : Icons
                                  .local_shipping_outlined,

                          size: 36,

                          color:
                              AppColors.primary,
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      // ==================================================
                      // TITLE
                      // ==================================================

                      Text(
                        searching
                            ? 'No deliveries found'
                            : 'No deliveries yet',

                        textAlign:
                            TextAlign.center,

                        style:
                            AppTextStyles.title,
                      ),

                      const SizedBox(
                        height: 7,
                      ),

                      // ==================================================
                      // DESCRIPTION
                      // ==================================================

                      Padding(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 8,
                        ),

                        child: Text(
                          searching
                              ? 'Try a different invoice number, delivery number or note.'
                              : 'Receive your first supplier delivery to begin tracking purchases and stock.',

                          textAlign:
                              TextAlign.center,

                          style:
                              AppTextStyles
                                  .bodySecondary,
                        ),
                      ),

                      // ==================================================
                      // BUTTON
                      // ==================================================

                      if (!searching) ...[
                        const SizedBox(
                          height: 20,
                        ),

                        ElevatedButton.icon(
                          onPressed:
                              _showAddDeliveryDialog,

                          icon:
                              const Icon(
                            Icons.add,
                          ),

                          label:
                              const Text(
                            'Receive Delivery',
                          ),
                        ),
                      ],

                      // ==================================================
                      // BOTTOM BREATHING ROOM
                      // ==================================================

                      const SizedBox(
                        height: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _money(double amount) {
    return '₦${amount.toStringAsFixed(2)}';
  }

  void _showMessage(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(message),
      ),
    );
  }

  void _showError(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(message),
        backgroundColor:
            AppColors.danger,
      ),
    );
  }
}

// ============================================================================
// ADD DELIVERY DIALOG
// ============================================================================

class _AddDeliveryDialog
    extends StatefulWidget {
  final Supplier supplier;
  final SupplierDeliveryDao deliveryDao;

  const _AddDeliveryDialog({
    required this.supplier,
    required this.deliveryDao,
  });

  @override
  State<_AddDeliveryDialog> createState() =>
      _AddDeliveryDialogState();
}

class _AddDeliveryDialogState
    extends State<_AddDeliveryDialog> {
  late final ProductDao _productDao;

  final _formKey =
      GlobalKey<FormState>();

  final _invoiceController =
      TextEditingController();

  final _notesController =
      TextEditingController();

  final _quantityController =
      TextEditingController();

  final _unitCostController =
      TextEditingController();

  bool _loadingProducts = true;
  bool _saving = false;

  List<Product> _products = [];

  Product? _selectedProduct;

  DateTime _deliveryDate =
      DateTime.now();

  @override
  void initState() {
    super.initState();

    _productDao =
        getProductDao();

    _loadProducts();
  }

  // ============================================================
  // LOAD PRODUCTS
  // ============================================================

  Future<void> _loadProducts() async {
    try {
      final products =
          await _productDao
              .getAllProducts();

      if (!mounted) return;

      setState(() {
        _products =
            products;
        _loadingProducts =
            false;
      });
    } catch (e) {
      debugPrint(
        'Load products for delivery error: $e',
      );

      if (!mounted) return;

      setState(() {
        _loadingProducts =
            false;
      });

      _showError(
        'Unable to load products.\n$e',
      );
    }
  }

  // ============================================================
  // SAVE DELIVERY
  // ============================================================

  Future<void> _saveDelivery() async {
    if (_saving) {
      return;
    }

    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    final product =
        _selectedProduct;

    if (product == null) {
      _showError(
        'Please select a product.',
      );
      return;
    }

    final quantity =
        int.tryParse(
              _quantityController.text
                  .trim(),
            ) ??
            0;

    final unitCost =
        double.tryParse(
              _unitCostController.text
                  .trim(),
            ) ??
            0;

    if (quantity <= 0) {
      _showError(
        'Enter a valid quantity.',
      );
      return;
    }

    if (unitCost < 0) {
      _showError(
        'Enter a valid unit cost.',
      );
      return;
    }

    final totalCost =
        quantity * unitCost;

    setState(() {
      _saving = true;
    });

    try {
      final delivery =
          SupplierDeliveriesCompanion(
        supplierId:
            Value(
          widget.supplier.id,
        ),

        deliveryDate:
            Value(
          _deliveryDate,
        ),

        invoiceNumber:
            _invoiceController
                    .text
                    .trim()
                    .isEmpty
                ? const Value.absent()
                : Value(
                    _invoiceController
                        .text
                        .trim(),
                  ),

        totalAmount:
            Value(
          totalCost,
        ),

        notes:
            _notesController
                    .text
                    .trim()
                    .isEmpty
                ? const Value.absent()
                : Value(
                    _notesController
                        .text
                        .trim(),
                  ),
      );

      final item =
          SupplierDeliveryItemsCompanion(
        productId:
            Value(
          product.id,
        ),

        quantity:
            Value(
          quantity,
        ),

        unitCost:
            Value(
          unitCost,
        ),

        totalCost:
            Value(
          totalCost,
        ),

        expiryDate:
            const Value.absent(),
      );

      await widget.deliveryDao
          .receiveDelivery(
        delivery:
            delivery,
        items: [
          item,
        ],
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context)
          .pop(true);
    } catch (e) {
      debugPrint(
        'Receive delivery error: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _saving = false;
      });

      _showError(
        'Unable to receive delivery.\n$e',
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final responsive =
        context.responsive;

    final width =
        MediaQuery.sizeOf(context)
            .width;

    final screenHeight =
        MediaQuery.sizeOf(context)
            .height;

    final dialogWidth =
        responsive.isCompact
            ? width - 24
            : width >= 900
                ? 650.0
                : width >= 600
                    ? 580.0
                    : width - 32;

    final quantity =
        int.tryParse(
              _quantityController
                  .text
                  .trim(),
            ) ??
            0;

    final unitCost =
        double.tryParse(
              _unitCostController
                  .text
                  .trim(),
            ) ??
            0;

    final total =
        quantity * unitCost;

    return AlertDialog(
      insetPadding:
          EdgeInsets.symmetric(
        horizontal:
            responsive.isCompact
                ? 12
                : 16,
        vertical: 20,
      ),

      titlePadding:
          EdgeInsets.fromLTRB(
        responsive.isCompact
            ? 18
            : 24,
        18,
        responsive.isCompact
            ? 18
            : 24,
        8,
      ),

      contentPadding:
          EdgeInsets.fromLTRB(
        responsive.isCompact
            ? 18
            : 24,
        10,
        responsive.isCompact
            ? 18
            : 24,
        8,
      ),

      actionsPadding:
          EdgeInsets.fromLTRB(
        responsive.isCompact
            ? 12
            : 16,
        4,
        responsive.isCompact
            ? 12
            : 16,
        12,
      ),

      title: Row(
        children: [
          Container(
            width: 42,
            height: 42,

            decoration:
                BoxDecoration(
              color:
                  AppColors
                      .primaryLight,
              borderRadius:
                  BorderRadius.circular(
                11,
              ),
            ),

            child:
                const Icon(
              Icons
                  .local_shipping_outlined,
              color:
                  AppColors.primary,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          const Expanded(
            child: Text(
              'Receive Supplier Delivery',
              style:
                  AppTextStyles.title,
            ),
          ),
        ],
      ),

      content: SizedBox(
        width:
            dialogWidth,

        child:
            ConstrainedBox(
          constraints:
              BoxConstraints(
            maxHeight:
                screenHeight *
                    0.68,
          ),

          child:
              SingleChildScrollView(
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior
                    .onDrag,

            child: Form(
              key:
                  _formKey,

              child:
                  Column(
                mainAxisSize:
                    MainAxisSize.min,

                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [
                  // ========================================================
                  // INVOICE
                  // ========================================================

                  TextFormField(
                    controller:
                        _invoiceController,

                    decoration:
                        const InputDecoration(
                      labelText:
                          'Invoice / Delivery Note',
                      hintText:
                          'Optional',
                      border:
                          OutlineInputBorder(),
                      prefixIcon:
                          Icon(
                        Icons
                            .receipt_long_outlined,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  // ========================================================
                  // DATE
                  // ========================================================

                  InkWell(
                    borderRadius:
                        BorderRadius
                            .circular(
                      8,
                    ),

                    onTap:
                        _saving
                            ? null
                            : _selectDeliveryDate,

                    child:
                        InputDecorator(
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Delivery Date',
                        border:
                            OutlineInputBorder(),
                        prefixIcon:
                            Icon(
                          Icons
                              .calendar_today_outlined,
                        ),
                      ),

                      child:
                          Text(
                        _formatDate(
                          _deliveryDate,
                        ),
                        style:
                            AppTextStyles
                                .body,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // ========================================================
                  // SECTION TITLE
                  // ========================================================

                  const Text(
                    'Delivery Item',
                    style:
                        AppTextStyles.title,
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  // ========================================================
                  // PRODUCT
                  // ========================================================

                  _buildProductSelector(),

                  const SizedBox(
                    height: 14,
                  ),

                  // ========================================================
                  // QUANTITY / COST
                  // ========================================================

                  LayoutBuilder(
                    builder: (
                      context,
                      constraints,
                    ) {
                      final compact =
                          constraints
                                  .maxWidth <
                              420;

                      if (compact) {
                        return Column(
                          children: [
                            TextFormField(
                              controller:
                                  _quantityController,

                              keyboardType:
                                  TextInputType
                                      .number,

                              decoration:
                                  const InputDecoration(
                                labelText:
                                    'Quantity',
                                hintText:
                                    '0',
                                border:
                                    OutlineInputBorder(),
                              ),

                              validator:
                                  (value) {
                                final quantity =
                                    int.tryParse(
                                  value
                                          ?.trim() ??
                                      '',
                                );

                                if (quantity ==
                                        null ||
                                    quantity <=
                                        0) {
                                  return 'Enter quantity';
                                }

                                return null;
                              },

                              onChanged:
                                  (_) {
                                setState(
                                  () {},
                                );
                              },
                            ),

                            const SizedBox(
                              height: 14,
                            ),

                            TextFormField(
                              controller:
                                  _unitCostController,

                              keyboardType:
                                  const TextInputType
                                      .numberWithOptions(
                                decimal:
                                    true,
                              ),

                              decoration:
                                  const InputDecoration(
                                labelText:
                                    'Unit Cost',
                                hintText:
                                    '0.00',
                                border:
                                    OutlineInputBorder(),
                              ),

                              validator:
                                  (value) {
                                final cost =
                                    double.tryParse(
                                  value
                                          ?.trim() ??
                                      '',
                                );

                                if (cost ==
                                        null ||
                                    cost <
                                        0) {
                                  return 'Enter valid cost';
                                }

                                return null;
                              },

                              onChanged:
                                  (_) {
                                setState(
                                  () {},
                                );
                              },
                            ),
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [
                          Expanded(
                            child:
                                TextFormField(
                              controller:
                                  _quantityController,

                              keyboardType:
                                  TextInputType
                                      .number,

                              decoration:
                                  const InputDecoration(
                                labelText:
                                    'Quantity',
                                hintText:
                                    '0',
                                border:
                                    OutlineInputBorder(),
                              ),

                              validator:
                                  (value) {
                                final quantity =
                                    int.tryParse(
                                  value
                                          ?.trim() ??
                                      '',
                                );

                                if (quantity ==
                                        null ||
                                    quantity <=
                                        0) {
                                  return 'Enter quantity';
                                }

                                return null;
                              },

                              onChanged:
                                  (_) {
                                setState(
                                  () {},
                                );
                              },
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child:
                                TextFormField(
                              controller:
                                  _unitCostController,

                              keyboardType:
                                  const TextInputType
                                      .numberWithOptions(
                                decimal:
                                    true,
                              ),

                              decoration:
                                  const InputDecoration(
                                labelText:
                                    'Unit Cost',
                                hintText:
                                    '0.00',
                                border:
                                    OutlineInputBorder(),
                              ),

                              validator:
                                  (value) {
                                final cost =
                                    double.tryParse(
                                  value
                                          ?.trim() ??
                                      '',
                                );

                                if (cost ==
                                        null ||
                                    cost <
                                        0) {
                                  return 'Enter valid cost';
                                }

                                return null;
                              },

                              onChanged:
                                  (_) {
                                setState(
                                  () {},
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // ========================================================
                  // TOTAL
                  // ========================================================

                  Container(
                    width:
                        double.infinity,

                    padding:
                        const EdgeInsets
                            .all(
                      15,
                    ),

                    decoration:
                        BoxDecoration(
                      color:
                          AppColors
                              .primaryLight,
                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),
                      border:
                          Border.all(
                        color: AppColors
                            .primary
                            .withValues(
                          alpha:
                              0.12,
                        ),
                      ),
                    ),

                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,

                          decoration:
                              BoxDecoration(
                            color:
                                AppColors
                                    .surface,
                            borderRadius:
                                BorderRadius
                                    .circular(
                              9,
                            ),
                          ),

                          child:
                              const Icon(
                            Icons
                                .calculate_outlined,
                            color:
                                AppColors
                                    .primary,
                            size: 20,
                          ),
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [
                              Text(
                                'Delivery Total',
                                style:
                                    AppTextStyles
                                        .small,
                              ),

                              SizedBox(
                                height: 2,
                              ),

                              Text(
                                'Purchase value',
                                style:
                                    AppTextStyles
                                        .bodySecondary,
                              ),
                            ],
                          ),
                        ),

                        Flexible(
                          child:
                              Text(
                            _money(
                              total,
                            ),

                            maxLines:
                                1,

                            overflow:
                                TextOverflow
                                    .ellipsis,

                            textAlign:
                                TextAlign
                                    .end,

                            style:
                                AppTextStyles
                                    .price,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // ========================================================
                  // NOTES
                  // ========================================================

                  TextFormField(
                    controller:
                        _notesController,

                    maxLines: 3,

                    decoration:
                        const InputDecoration(
                      labelText:
                          'Notes',
                      hintText:
                          'Optional delivery notes...',
                      border:
                          OutlineInputBorder(),
                      alignLabelWithHint:
                          true,

                      prefixIcon:
                          Padding(
                        padding:
                            EdgeInsets.only(
                          bottom: 42,
                        ),

                        child:
                            Icon(
                          Icons
                              .notes_outlined,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  // ========================================================
                  // INFORMATION
                  // ========================================================

                  Container(
                    padding:
                        const EdgeInsets
                            .all(
                      12,
                    ),

                    decoration:
                        BoxDecoration(
                      color:
                          AppColors
                              .warningLight,
                      borderRadius:
                          BorderRadius
                              .circular(
                        11,
                      ),
                      border:
                          Border.all(
                        color:
                            AppColors
                                .warning
                                .withValues(
                          alpha:
                              0.25,
                        ),
                      ),
                    ),

                    child: const Row(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [
                        Icon(
                          Icons
                              .info_outline,
                          size: 19,
                          color:
                              AppColors
                                  .warning,
                        ),

                        SizedBox(
                          width: 8,
                        ),

                        Expanded(
                          child: Text(
                            'Receiving this delivery will increase product stock and create the corresponding purchase stock movement.',
                            style:
                                AppTextStyles
                                    .small,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed:
              _saving
                  ? null
                  : () {
                      Navigator.of(
                        context,
                      ).pop(false);
                    },

          child:
              const Text(
            'Cancel',
          ),
        ),

        ElevatedButton.icon(
          onPressed:
              _saving
                  ? null
                  : _saveDelivery,

          icon:
              _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,

                      child:
                          CircularProgressIndicator(
                        strokeWidth:
                            2,
                        color:
                            Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.check,
                    ),

          label:
              Text(
            _saving
                ? 'Receiving...'
                : 'Receive Delivery',
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PRODUCT SELECTOR
  // ============================================================

  Widget _buildProductSelector() {
    if (_loadingProducts) {
      return const InputDecorator(
        decoration:
            InputDecoration(
          labelText:
              'Product',
          border:
              OutlineInputBorder(),
        ),

        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,

              child:
                  CircularProgressIndicator(
                strokeWidth:
                    2,
              ),
            ),

            SizedBox(
              width: 10,
            ),

            Text(
              'Loading products...',
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return Container(
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
                  .warningLight,
          borderRadius:
              BorderRadius
                  .circular(
            11,
          ),
          border:
              Border.all(
            color:
                AppColors
                    .warning,
          ),
        ),

        child: const Row(
          children: [
            Icon(
              Icons
                  .warning_amber_outlined,
              color:
                  AppColors
                      .warning,
            ),

            SizedBox(
              width: 10,
            ),

            Expanded(
              child: Text(
                'No products are available. Create a product first.',
              ),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<int>(
      initialValue:
          _selectedProduct?.id,

      isExpanded:
          true,

      decoration:
          const InputDecoration(
        labelText:
            'Product',
        hintText:
            'Select a product',
        border:
            OutlineInputBorder(),
        prefixIcon:
            Icon(
          Icons
              .inventory_2_outlined,
        ),
      ),

      items:
          _products.map(
        (product) {
          return DropdownMenuItem<int>(
            value:
                product.id,

            child:
                Text(
              product.name,
              maxLines:
                  1,
              overflow:
                  TextOverflow
                      .ellipsis,
            ),
          );
        },
      ).toList(),

      onChanged:
          _saving
              ? null
              : (productId) {
                  if (productId ==
                      null) {
                    return;
                  }

                  final product =
                      _products.firstWhere(
                    (p) =>
                        p.id ==
                        productId,
                  );

                  setState(() {
                    _selectedProduct =
                        product;
                  });
                },

      validator:
          (value) {
        if (value ==
            null) {
          return 'Select a product';
        }

        return null;
      },
    );
  }

  // ============================================================
  // DATE
  // ============================================================

  Future<void>
      _selectDeliveryDate() async {
    final selected =
        await showDatePicker(
      context:
          context,

      initialDate:
          _deliveryDate,

      firstDate:
          DateTime(2020),

      lastDate:
          DateTime(2100),
    );

    if (selected ==
            null ||
        !mounted) {
      return;
    }

    setState(() {
      _deliveryDate =
          selected;
    });
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _money(
    double amount,
  ) {
    return '₦${amount.toStringAsFixed(2)}';
  }

  String _formatDate(
    DateTime date,
  ) {
    final day =
        date.day
            .toString()
            .padLeft(
              2,
              '0',
            );

    final month =
        date.month
            .toString()
            .padLeft(
              2,
              '0',
            );

    return '$day/$month/${date.year}';
  }

  void _showError(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content:
            Text(message),
        backgroundColor:
            AppColors
                .danger,
      ),
    );
  }

  @override
  void dispose() {
    _invoiceController
        .dispose();

    _notesController
        .dispose();

    _quantityController
        .dispose();

    _unitCostController
        .dispose();

    super.dispose();
  }
}

// ============================================================================
// DELIVERY CARD
// ============================================================================

class _DeliveryCard
    extends StatefulWidget {
  final SupplierDelivery delivery;
  final SupplierDeliveryDao deliveryDao;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _DeliveryCard({
    required this.delivery,
    required this.deliveryDao,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<_DeliveryCard> createState() =>
      _DeliveryCardState();
}

class _DeliveryCardState
    extends State<_DeliveryCard> {
  int _itemCount = 0;

  bool _loadingCount =
      true;

  @override
  void initState() {
    super.initState();

    _loadItemCount();
  }

  Future<void>
      _loadItemCount() async {
    try {
      final count =
          await widget
              .deliveryDao
              .getDeliveryItemCount(
        widget.delivery.id,
      );

      if (!mounted) return;

      setState(() {
        _itemCount =
            count;

        _loadingCount =
            false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loadingCount =
            false;
      });
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final delivery =
        widget.delivery;

    final invoice =
        delivery.invoiceNumber;

    return Material(
      color:
          AppColors.surface,

      borderRadius:
          BorderRadius.circular(
        16,
      ),

      child: InkWell(
        onTap:
            widget.onTap,

        borderRadius:
            BorderRadius.circular(
          16,
        ),

        child: Container(
          padding:
              const EdgeInsets
                  .all(
            16,
          ),

          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              16,
            ),

            border:
                Border.all(
              color:
                  AppColors.border,
            ),
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,

            children: [
              // ========================================================
              // TOP
              // ========================================================

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [
                  Container(
                    width: 43,
                    height: 43,

                    decoration:
                        BoxDecoration(
                      color:
                          AppColors
                              .primaryLight,
                      borderRadius:
                          BorderRadius
                              .circular(
                        11,
                      ),
                    ),

                    child:
                        const Icon(
                      Icons
                          .local_shipping_outlined,
                      color:
                          AppColors
                              .primary,
                      size: 21,
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  Expanded(
                    child:
                        Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [
                        Text(
                          invoice?.isNotEmpty ==
                                  true
                              ? invoice!
                              : 'Delivery #${delivery.id}',

                          maxLines:
                              1,

                          overflow:
                              TextOverflow
                                  .ellipsis,

                          style:
                              AppTextStyles
                                  .title,
                        ),

                        const SizedBox(
                          height: 4,
                        ),

                        Row(
                          children: [
                            const Icon(
                              Icons
                                  .calendar_today_outlined,
                              size:
                                  13,
                              color:
                                  AppColors
                                      .textSecondary,
                            ),

                            const SizedBox(
                              width: 5,
                            ),

                            Text(
                              _formatDate(
                                delivery
                                    .deliveryDate,
                              ),
                              style:
                                  AppTextStyles
                                      .small,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  PopupMenuButton<
                      String>(
                    padding:
                        EdgeInsets.zero,

                    icon:
                        const Icon(
                      Icons.more_vert,
                    ),

                    onSelected:
                        (value) {
                      if (value ==
                          'delete') {
                        widget
                            .onDelete();
                      }
                    },

                    itemBuilder:
                        (context) =>
                            const [
                      PopupMenuItem(
                        value:
                            'delete',

                        child:
                            Row(
                          children: [
                            Icon(
                              Icons
                                  .delete_outline,
                              color:
                                  AppColors
                                      .danger,
                            ),

                            SizedBox(
                              width: 8,
                            ),

                            Text(
                              'Delete',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(),

              // ========================================================
              // BOTTOM
              // ========================================================

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .end,

                children: [
                  Expanded(
                    child:
                        Wrap(
                      spacing: 7,
                      runSpacing: 6,

                      children: [
                        _infoChip(
                          icon: Icons
                              .inventory_2_outlined,

                          text:
                              _loadingCount
                                  ? '...'
                                  : '$_itemCount items',
                        ),

                        if ((delivery
                                    .notes ??
                                '')
                            .isNotEmpty)
                          const _InfoIconChip(
                            icon: Icons
                                .notes_outlined,
                            text:
                                'Notes',
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  Flexible(
                    child:
                        Text(
                      _money(
                        delivery
                            .totalAmount,
                      ),

                      maxLines:
                          1,

                      overflow:
                          TextOverflow
                              .ellipsis,

                      textAlign:
                          TextAlign
                              .end,

                      style:
                          AppTextStyles
                              .price
                              .copyWith(
                        fontSize:
                            17,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding:
          const EdgeInsets
              .symmetric(
        horizontal: 9,
        vertical: 6,
      ),

      decoration:
          BoxDecoration(
        color:
            AppColors
                .background,
        borderRadius:
            BorderRadius.circular(
          8,
        ),
      ),

      child: Row(
        mainAxisSize:
            MainAxisSize.min,

        children: [
          Icon(
            icon,
            size: 15,
            color:
                AppColors
                    .textSecondary,
          ),

          const SizedBox(
            width: 5,
          ),

          Text(
            text,
            style:
                AppTextStyles
                    .small,
          ),
        ],
      ),
    );
  }

  String _money(
    double amount,
  ) {
    return '₦${amount.toStringAsFixed(2)}';
  }

  String _formatDate(
    DateTime date,
  ) {
    final day =
        date.day
            .toString()
            .padLeft(
              2,
              '0',
            );

    final month =
        date.month
            .toString()
            .padLeft(
              2,
              '0',
            );

    return '$day/$month/${date.year}';
  }
}

// ============================================================================
// SMALL INFO CHIP
// ============================================================================

class _InfoIconChip
    extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoIconChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets
              .symmetric(
        horizontal: 9,
        vertical: 6,
      ),

      decoration:
          BoxDecoration(
        color:
            AppColors
                .background,
        borderRadius:
            BorderRadius.circular(
          8,
        ),
      ),

      child: Row(
        mainAxisSize:
            MainAxisSize.min,

        children: [
          Icon(
            icon,
            size: 15,
            color:
                AppColors
                    .textSecondary,
          ),

          const SizedBox(
            width: 5,
          ),

          Text(
            text,
            style:
                AppTextStyles
                    .small,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DELIVERY DETAILS
// ============================================================================

class _DeliveryDetailsSheet
    extends StatefulWidget {
  final SupplierDelivery delivery;
  final SupplierDeliveryDao deliveryDao;

  const _DeliveryDetailsSheet({
    required this.delivery,
    required this.deliveryDao,
  });

  @override
  State<_DeliveryDetailsSheet> createState() =>
      _DeliveryDetailsSheetState();
}

class _DeliveryDetailsSheetState
    extends State<_DeliveryDetailsSheet> {
  bool _loading = true;

  List<SupplierDeliveryItemWithProduct>
      _items = [];

  @override
  void initState() {
    super.initState();

    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final items =
          await widget
              .deliveryDao
              .getDeliveryItemsWithProducts(
        widget.delivery.id,
      );

      if (!mounted) return;

      setState(() {
        _items =
            items;

        _loading =
            false;
      });
    } catch (e) {
      debugPrint(
        'Delivery details error: $e',
      );

      if (!mounted) return;

      setState(() {
        _loading =
            false;
      });
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final delivery =
        widget.delivery;

    final size =
        MediaQuery.sizeOf(
      context,
    );

    final isCompact =
        size.width < 600;

    final sheetHeight =
        size.height *
            (isCompact
                ? 0.94
                : 0.84);

    return SafeArea(
      child: Container(
        height:
            sheetHeight,

        decoration:
            const BoxDecoration(
          color:
              AppColors.surface,

          borderRadius:
              BorderRadius.vertical(
            top:
                Radius.circular(
              24,
            ),
          ),
        ),

        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),

            Container(
              width: 42,
              height: 4,

              decoration:
                  BoxDecoration(
                color:
                    AppColors
                        .border,
                borderRadius:
                    BorderRadius
                        .circular(
                  10,
                ),
              ),
            ),

            // ========================================================
            // HEADER
            // ========================================================

            Padding(
              padding:
                  EdgeInsets.fromLTRB(
                isCompact
                    ? 16
                    : 20,
                16,
                8,
                14,
              ),

              child: Row(
                children: [
                  Container(
                    width: 43,
                    height: 43,

                    decoration:
                        BoxDecoration(
                      color:
                          AppColors
                              .primaryLight,
                      borderRadius:
                          BorderRadius
                              .circular(
                        11,
                      ),
                    ),

                    child:
                        const Icon(
                      Icons
                          .local_shipping_outlined,
                      color:
                          AppColors
                              .primary,
                    ),
                  ),

                  const SizedBox(
                    width: 11,
                  ),

                  Expanded(
                    child:
                        Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [
                        const Text(
                          'Delivery Details',
                          style:
                              AppTextStyles
                                  .heading,
                        ),

                        const SizedBox(
                          height: 3,
                        ),

                        Text(
                          delivery
                                      .invoiceNumber
                                      ?.isNotEmpty ==
                                  true
                              ? delivery
                                  .invoiceNumber!
                              : 'Delivery #${delivery.id}',

                          maxLines:
                              1,

                          overflow:
                              TextOverflow
                                  .ellipsis,

                          style:
                              AppTextStyles
                                  .bodySecondary,
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    tooltip:
                        'Close',

                    onPressed:
                        () {
                      Navigator.pop(
                        context,
                      );
                    },

                    icon:
                        const Icon(
                      Icons.close,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(
              height: 1,
            ),

            // ========================================================
            // CONTENT
            // ========================================================

            Expanded(
              child:
                  _loading
                      ? const Center(
                          child:
                              CircularProgressIndicator(),
                        )
                      : ListView(
                          physics:
                              const AlwaysScrollableScrollPhysics(),

                          padding:
                              EdgeInsets.all(
                            isCompact
                                ? 16
                                : 20,
                          ),

                          children: [
                            _buildSummary(
                              delivery,
                            ),

                            const SizedBox(
                              height: 20,
                            ),

                            const Text(
                              'Items Received',
                              style:
                                  AppTextStyles
                                      .title,
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            if (_items
                                .isEmpty)
                              _emptyItems()
                            else
                              ..._items
                                  .map(
                                _buildItem,
                              ),

                            if ((delivery
                                        .notes ??
                                    '')
                                .isNotEmpty) ...[
                              const SizedBox(
                                height: 20,
                              ),

                              _buildNotes(
                                delivery
                                    .notes!,
                              ),
                            ],
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary(
    SupplierDelivery delivery,
  ) {
    return Container(
      padding:
          const EdgeInsets
              .all(
        16,
      ),

      decoration:
          BoxDecoration(
        color:
            AppColors
                .primaryLight,

        borderRadius:
            BorderRadius.circular(
          14,
        ),

        border:
            Border.all(
          color:
              AppColors
                  .primary
                  .withValues(
            alpha:
                0.10,
          ),
        ),
      ),

      child:
          LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final compact =
              constraints
                      .maxWidth <
                  380;

          if (compact) {
            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [
                _summaryValue(
                  'Delivery Date',
                  _formatDate(
                    delivery
                        .deliveryDate,
                  ),
                ),

                const SizedBox(
                  height: 14,
                ),

                _summaryValue(
                  'Purchase Total',
                  _money(
                    delivery
                        .totalAmount,
                  ),
                  price:
                      true,
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child:
                    _summaryValue(
                  'Delivery Date',
                  _formatDate(
                    delivery
                        .deliveryDate,
                  ),
                ),
              ),

              Container(
                width: 1,
                height: 45,

                color:
                    AppColors
                        .border,
              ),

              const SizedBox(
                width: 16,
              ),

              Expanded(
                child:
                    Align(
                  alignment:
                      Alignment
                          .centerRight,

                  child:
                      _summaryValue(
                    'Purchase Total',
                    _money(
                      delivery
                          .totalAmount,
                    ),
                    price:
                        true,
                    alignEnd:
                        true,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryValue(
    String label,
    String value, {
    bool price = false,
    bool alignEnd = false,
  }) {
    return Column(
      crossAxisAlignment:
          alignEnd
              ? CrossAxisAlignment
                  .end
              : CrossAxisAlignment
                  .start,

      children: [
        Text(
          label,
          style:
              AppTextStyles
                  .small,
        ),

        const SizedBox(
          height: 4,
        ),

        Text(
          value,
          style:
              price
                  ? AppTextStyles
                      .price
                  : AppTextStyles
                      .body,
        ),
      ],
    );
  }

  // ============================================================
  // ITEM
  // ============================================================

  Widget _buildItem(
    SupplierDeliveryItemWithProduct
        entry,
  ) {
    final item =
        entry.item;

    final product =
        entry.product;

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),

      padding:
          const EdgeInsets
              .all(
        14,
      ),

      decoration:
          BoxDecoration(
        color:
            AppColors
                .background,

        borderRadius:
            BorderRadius.circular(
          12,
        ),

        border:
            Border.all(
          color:
              AppColors
                  .border,
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,

            decoration:
                BoxDecoration(
              color:
                  AppColors
                      .surface,
              borderRadius:
                  BorderRadius
                      .circular(
                10,
              ),
            ),

            child:
                const Icon(
              Icons
                  .inventory_2_outlined,
              color:
                  AppColors
                      .primary,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [
                Text(
                  product.name,

                  maxLines:
                      1,

                  overflow:
                      TextOverflow
                          .ellipsis,

                  style:
                      AppTextStyles
                          .body,
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  '${item.quantity} × ${_money(item.unitCost)}',

                  maxLines:
                      1,

                  overflow:
                      TextOverflow
                          .ellipsis,

                  style:
                      AppTextStyles
                          .small,
                ),
              ],
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          Flexible(
            child:
                Text(
              _money(
                item.totalCost,
              ),

              maxLines:
                  1,

              overflow:
                  TextOverflow
                      .ellipsis,

              textAlign:
                  TextAlign
                      .end,

              style:
                  AppTextStyles
                      .price
                      .copyWith(
                fontSize:
                    16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NOTES
  // ============================================================

  Widget _buildNotes(
    String notes,
  ) {
    return Container(
      padding:
          const EdgeInsets
              .all(
        14,
      ),

      decoration:
          BoxDecoration(
        color:
            AppColors
                .background,

        borderRadius:
            BorderRadius.circular(
          12,
        ),

        border:
            Border.all(
          color:
              AppColors
                  .border,
        ),
      ),

      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,

        children: [
          Row(
            children: [
              const Icon(
                Icons
                    .notes_outlined,
                size: 19,
                color:
                    AppColors
                        .primary,
              ),

              const SizedBox(
                width: 7,
              ),

              const Text(
                'Notes',
                style:
                    AppTextStyles
                        .title,
              ),
            ],
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            notes,
            style:
                AppTextStyles
                    .body,
          ),
        ],
      ),
    );
  }

  Widget _emptyItems() {
    return Container(
      padding:
          const EdgeInsets
              .all(
        22,
      ),

      decoration:
          BoxDecoration(
        color:
            AppColors
                .background,

        borderRadius:
            BorderRadius.circular(
          12,
        ),

        border:
            Border.all(
          color:
              AppColors
                  .border,
        ),
      ),

      child:
          Column(
        children: [
          const Icon(
            Icons
                .inventory_2_outlined,
            size: 32,
            color:
                AppColors
                    .textSecondary,
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            'No delivery items found.',
            textAlign:
                TextAlign.center,
            style:
                AppTextStyles
                    .bodySecondary,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _money(
    double amount,
  ) {
    return '₦${amount.toStringAsFixed(2)}';
  }

  String _formatDate(
    DateTime date,
  ) {
    final day =
        date.day
            .toString()
            .padLeft(
              2,
              '0',
            );

    final month =
        date.month
            .toString()
            .padLeft(
              2,
              '0',
            );

    return '$day/$month/${date.year}';
  }
}

