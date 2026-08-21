// lib/features/suppliers/supplier_deliveries_screen.dart

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

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

      final deliveries =
          results[0] as List<SupplierDelivery>;

      final total =
          results[1] as double;

      if (!mounted) return;

      setState(() {
        _deliveries = deliveries;
        _totalPurchases = total;
        _loading = false;
      });
    } catch (e) {
      debugPrint(
        'Supplier deliveries error: $e',
      );

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
    final query =
        _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return _deliveries;
    }

    return _deliveries.where((delivery) {
      final invoice =
          delivery.invoiceNumber ?? '';

      final notes =
          delivery.notes ?? '';

      return invoice
              .toLowerCase()
              .contains(query) ||
          notes
              .toLowerCase()
              .contains(query) ||
          delivery.id
              .toString()
              .contains(query);
    }).toList();
  }

  // ============================================================
  // ADD DELIVERY
  // ============================================================

  Future<void> _showAddDeliveryDialog() async {
    final result =
        await showDialog<bool>(
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
  // DELIVERY DETAILS
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
    final confirmed =
        await showDialog<bool>(
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
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child:
                  const Text('Cancel'),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.danger,
                foregroundColor:
                    Colors.white,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child:
                  const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _deliveryDao.deleteDelivery(
        delivery.id,
      );

      await _loadDeliveries();

      if (!mounted) return;

      _showMessage(
        'Delivery deleted.',
      );
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
    return Scaffold(
      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        leading:
            const CentralBackButton(),

        title: Text(
          'Deliveries',
          style:
              AppTextStyles.heading,
        ),

        backgroundColor:
            AppColors.primary,

        foregroundColor:
            Colors.white,

        elevation: 0,

        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed:
                _loadDeliveries,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh:
                  _loadDeliveries,

              child:
                  CustomScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),

                slivers: [
                  SliverPadding(
                    padding:
                        const EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      8,
                    ),

                    sliver:
                        SliverToBoxAdapter(
                      child:
                          _buildHeader(),
                    ),
                  ),

                  SliverPadding(
                    padding:
                        const EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      8,
                    ),

                    sliver:
                        SliverToBoxAdapter(
                      child:
                          _buildSearch(),
                    ),
                  ),

                  if (_filteredDeliveries
                      .isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child:
                          _buildEmptyState(),
                    )
                  else
                    SliverPadding(
                      padding:
                          const EdgeInsets.fromLTRB(
                        16,
                        8,
                        16,
                        100,
                      ),

                      sliver:
                          SliverLayoutBuilder(
                        builder:
                            (
                          context,
                          constraints,
                        ) {
                          final width =
                              constraints.crossAxisExtent;

                          final columns =
                              width >= 850
                                  ? 2
                                  : 1;

                          return SliverGrid(
                            delegate:
                                SliverChildBuilderDelegate(
                              (
                                context,
                                index,
                              ) {
                                final delivery =
                                    _filteredDeliveries[
                                        index];

                                return _DeliveryCard(
                                  delivery:
                                      delivery,
                                  deliveryDao:
                                      _deliveryDao,
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
                                  _filteredDeliveries
                                      .length,
                            ),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                                  columns,
                              crossAxisSpacing:
                                  14,
                              mainAxisSpacing:
                                  14,
                              childAspectRatio:
                                  columns == 2
                                      ? 1.55
                                      : 2.25,
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

      floatingActionButton:
          FloatingActionButton.extended(
        backgroundColor:
            AppColors.accent,

        foregroundColor:
            Colors.white,

        onPressed:
            _showAddDeliveryDialog,

        icon: const Icon(
          Icons.local_shipping_outlined,
        ),

        label: const Text(
          'Receive Delivery',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      padding:
          const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color:
            AppColors.surface,

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color:
              AppColors.border,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,

                decoration:
                    BoxDecoration(
                  color:
                      AppColors.primaryLight,
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),

                child: const Icon(
                  Icons
                      .local_shipping_outlined,
                  color:
                      AppColors.primary,
                  size: 28,
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      widget.supplier.name,
                      style:
                          AppTextStyles.heading,
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      'Supplier deliveries',
                      style:
                          AppTextStyles.bodySecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          LayoutBuilder(
            builder:
                (context, constraints) {
              final compact =
                  constraints.maxWidth <
                      520;

              if (compact) {
                return Column(
                  children: [
                    _metric(
                      icon: Icons
                          .local_shipping_outlined,
                      label:
                          'Deliveries',
                      value:
                          '${_deliveries.length}',
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    _metric(
                      icon: Icons
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
                    child: _metric(
                      icon: Icons
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
                    child: _metric(
                      icon: Icons
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

  Widget _metric({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color:
            AppColors.background,

        borderRadius:
            BorderRadius.circular(12),

        border: Border.all(
          color:
              AppColors.border,
        ),
      ),

      child: Row(
        children: [
          Icon(
            icon,
            color:
                AppColors.primary,
            size: 21,
          ),

          const SizedBox(
            width: 10,
          ),

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

                const SizedBox(
                  height: 2,
                ),

                Text(
                  value,
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

      decoration:
          InputDecoration(
        hintText:
            'Search invoice, delivery number or notes...',

        prefixIcon:
            const Icon(
          Icons.search,
        ),

        suffixIcon:
            _searchQuery.isEmpty
                ? null
                : IconButton(
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

        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),
          borderSide:
              BorderSide(
            color:
                AppColors.border,
          ),
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),
          borderSide:
              BorderSide(
            color:
                AppColors.border,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
    final searching =
        _searchQuery.isNotEmpty;

    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(32),

        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            Container(
              padding:
                  const EdgeInsets.all(20),

              decoration:
                  const BoxDecoration(
                color:
                    AppColors.primaryLight,
                shape:
                    BoxShape.circle,
              ),

              child: Icon(
                searching
                    ? Icons.search_off
                    : Icons
                        .local_shipping_outlined,
                size: 42,
                color:
                    AppColors.primary,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            Text(
              searching
                  ? 'No deliveries found'
                  : 'No deliveries yet',
              style:
                  AppTextStyles.title,
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              searching
                  ? 'Try a different search term.'
                  : 'Receive your first supplier delivery to begin tracking purchases and stock.',
              textAlign:
                  TextAlign.center,
              style:
                  AppTextStyles.bodySecondary,
            ),

            if (!searching) ...[
              const SizedBox(
                height: 18,
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
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _money(double amount) {
    return '₦${amount.toStringAsFixed(2)}';
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(message),
      ),
    );
  }

  void _showError(String message) {
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

class _AddDeliveryDialog extends StatefulWidget {
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

    _productDao = getProductDao();

    _loadProducts();
  }

  // ============================================================
  // LOAD PRODUCTS
  // ============================================================

  Future<void> _loadProducts() async {
    try {
      final products =
          await _productDao.getAllProducts();

      if (!mounted) return;

      setState(() {
        _products = products;
        _loadingProducts = false;
      });
    } catch (e) {
      debugPrint(
        'Load products for delivery error: $e',
      );

      if (!mounted) return;

      setState(() {
        _loadingProducts = false;
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

      Navigator.of(context).pop(
        true,
      );
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

    final total =
        quantity * unitCost;

    return AlertDialog(
      title: const Text(
        'Receive Supplier Delivery',
        style:
            AppTextStyles.title,
      ),

      content: SizedBox(
        width: 560,

        child: SingleChildScrollView(
          child: Form(
            key: _formKey,

            child: Column(
              mainAxisSize:
                  MainAxisSize.min,

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                // ------------------------------------------------
                // INVOICE
                // ------------------------------------------------

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
                  ),
                ),

                const SizedBox(
                  height: 14,
                ),

                // ------------------------------------------------
                // DATE
                // ------------------------------------------------

                InkWell(
                  borderRadius:
                      BorderRadius.circular(
                    8,
                  ),

                  onTap:
                      _selectDeliveryDate,

                  child:
                      InputDecorator(
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Delivery Date',
                      border:
                          OutlineInputBorder(),
                      suffixIcon:
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
                          AppTextStyles.body,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                const Text(
                  'Delivery Item',
                  style:
                      AppTextStyles.title,
                ),

                const SizedBox(
                  height: 10,
                ),

                // ------------------------------------------------
                // PRODUCT SELECTOR
                // ------------------------------------------------

                _buildProductSelector(),

                const SizedBox(
                  height: 14,
                ),

                // ------------------------------------------------
                // QUANTITY / COST
                // ------------------------------------------------

                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Expanded(
                      child:
                          TextFormField(
                        controller:
                            _quantityController,

                        keyboardType:
                            TextInputType.number,

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
                            value?.trim() ??
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
                          decimal: true,
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
                            value?.trim() ??
                                '',
                          );

                          if (cost ==
                                  null ||
                              cost < 0) {
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
                ),

                const SizedBox(
                  height: 14,
                ),

                // ------------------------------------------------
                // TOTAL
                // ------------------------------------------------

                Container(
                  width:
                      double.infinity,

                  padding:
                      const EdgeInsets.all(
                    14,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        AppColors.primaryLight,

                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),

                  child: Row(
                    children: [
                      const Icon(
                        Icons
                            .calculate_outlined,
                        color:
                            AppColors.primary,
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      const Expanded(
                        child:
                            Text(
                          'Delivery Total',
                          style:
                              AppTextStyles.body,
                        ),
                      ),

                      Text(
                        _money(
                          total,
                        ),
                        style:
                            AppTextStyles.price,
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 14,
                ),

                // ------------------------------------------------
                // NOTES
                // ------------------------------------------------

                TextFormField(
                  controller:
                      _notesController,

                  maxLines: 3,

                  decoration:
                      const InputDecoration(
                    labelText:
                        'Notes',
                    hintText:
                        'Optional',
                    border:
                        OutlineInputBorder(),
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                // ------------------------------------------------
                // INFORMATION
                // ------------------------------------------------

                Container(
                  padding:
                      const EdgeInsets.all(
                    12,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        AppColors.warningLight,

                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),

                  child: const Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color:
                            AppColors.warning,
                      ),

                      SizedBox(
                        width: 8,
                      ),

                      Expanded(
                        child:
                            Text(
                          'Receiving this delivery will increase product stock and create the corresponding purchase stock movement.',
                          style:
                              AppTextStyles.small,
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
              const Text('Cancel'),
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
                strokeWidth: 2,
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
            const EdgeInsets.all(
          14,
        ),

        decoration:
            BoxDecoration(
          color:
              AppColors.warningLight,

          borderRadius:
              BorderRadius.circular(
            10,
          ),

          border:
              Border.all(
            color:
                AppColors.warning,
          ),
        ),

        child: const Row(
          children: [
            Icon(
              Icons.warning_amber_outlined,
              color:
                  AppColors.warning,
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child:
                  Text(
                'No products are available. Create a product first.',
              ),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<int>(
      value:
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
          Icons.inventory_2_outlined,
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
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
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

                    // If your Product table has
                    // costPrice, this can later
                    // automatically populate
                    // the unit cost.
                  });
                },

      validator:
          (value) {
        if (value == null) {
          return 'Select a product';
        }

        return null;
      },
    );
  }

  // ============================================================
  // DATE
  // ============================================================

  Future<void> _selectDeliveryDate() async {
    final selected =
        await showDatePicker(
      context: context,

      initialDate:
          _deliveryDate,

      firstDate:
          DateTime(2020),

      lastDate:
          DateTime(2100),
    );

    if (selected == null ||
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

  String _money(double amount) {
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

  @override
  void dispose() {
    _invoiceController.dispose();
    _notesController.dispose();
    _quantityController.dispose();
    _unitCostController.dispose();

    super.dispose();
  }
}

// ============================================================================
// DELIVERY CARD
// ============================================================================

class _DeliveryCard extends StatefulWidget {
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
  bool _loadingCount = true;

  @override
  void initState() {
    super.initState();

    _loadItemCount();
  }

  Future<void> _loadItemCount() async {
    try {
      final count =
          await widget.deliveryDao
              .getDeliveryItemCount(
        widget.delivery.id,
      );

      if (!mounted) return;

      setState(() {
        _itemCount = count;
        _loadingCount = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loadingCount = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final delivery =
        widget.delivery;

    final invoice =
        delivery.invoiceNumber;

    return Material(
      color:
          AppColors.surface,

      borderRadius:
          BorderRadius.circular(16),

      child: InkWell(
        onTap:
            widget.onTap,

        borderRadius:
            BorderRadius.circular(16),

        child: Container(
          padding:
              const EdgeInsets.all(16),

          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              16,
            ),

            border: Border.all(
              color:
                  AppColors.border,
            ),
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.all(
                      9,
                    ),

                    decoration:
                        BoxDecoration(
                      color:
                          AppColors.primaryLight,
                      borderRadius:
                          BorderRadius.circular(
                        10,
                      ),
                    ),

                    child: const Icon(
                      Icons
                          .local_shipping_outlined,
                      color:
                          AppColors.primary,
                      size: 21,
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoice?.isNotEmpty ==
                                  true
                              ? invoice!
                              : 'Delivery #${delivery.id}',
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              AppTextStyles.title,
                        ),

                        const SizedBox(
                          height: 3,
                        ),

                        Text(
                          _formatDate(
                            delivery
                                .deliveryDate,
                          ),
                          style:
                              AppTextStyles.small,
                        ),
                      ],
                    ),
                  ),

                  PopupMenuButton<String>(
                    onSelected:
                        (value) {
                      if (value ==
                          'delete') {
                        widget.onDelete();
                      }
                    },

                    itemBuilder:
                        (context) => const [
                      PopupMenuItem(
                        value:
                            'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons
                                  .delete_outline,
                              color:
                                  AppColors.danger,
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

              Row(
                children: [
                  _infoChip(
                    icon:
                        Icons.inventory_2_outlined,
                    text:
                        _loadingCount
                            ? '...'
                            : '$_itemCount items',
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  if ((delivery.notes ??
                          '')
                      .isNotEmpty)
                    const _InfoIconChip(
                      icon:
                          Icons.notes_outlined,
                      text:
                          'Notes',
                    ),

                  const Spacer(),

                  Text(
                    _money(
                      delivery
                          .totalAmount,
                    ),
                    style:
                        AppTextStyles.price
                            .copyWith(
                      fontSize: 17,
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
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),

      decoration:
          BoxDecoration(
        color:
            AppColors.background,
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
                AppColors.textSecondary,
          ),

          const SizedBox(
            width: 5,
          ),

          Text(
            text,
            style:
                AppTextStyles.small,
          ),
        ],
      ),
    );
  }

  String _money(double amount) {
    return '₦${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    final day =
        date.day.toString().padLeft(
              2,
              '0',
            );

    final month =
        date.month.toString().padLeft(
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
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),

      decoration:
          BoxDecoration(
        color:
            AppColors.background,
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
                AppColors.textSecondary,
          ),

          const SizedBox(
            width: 5,
          ),

          Text(
            text,
            style:
                AppTextStyles.small,
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
          await widget.deliveryDao
              .getDeliveryItemsWithProducts(
        widget.delivery.id,
      );

      if (!mounted) return;

      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      debugPrint(
        'Delivery details error: $e',
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final delivery =
        widget.delivery;

    return SafeArea(
      child: Container(
        height:
            MediaQuery.of(context)
                    .size
                    .height *
                0.88,

        decoration:
            const BoxDecoration(
          color:
              AppColors.surface,

          borderRadius:
              BorderRadius.vertical(
            top: Radius.circular(
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
                    AppColors.border,
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
              ),
            ),

            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                18,
                12,
                14,
              ),

              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Delivery Details',
                          style:
                              AppTextStyles.heading,
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
                          style:
                              AppTextStyles.bodySecondary,
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: () {
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

            Expanded(
              child: _loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(),
                    )
                  : ListView(
                      padding:
                          const EdgeInsets.all(
                        20,
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
                              AppTextStyles.title,
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        if (_items.isEmpty)
                          _emptyItems()
                        else
                          ..._items.map(
                            _buildItem,
                          ),

                        if ((delivery
                                    .notes ??
                                '')
                            .isNotEmpty) ...[
                          const SizedBox(
                            height: 20,
                          ),

                          Container(
                            padding:
                                const EdgeInsets
                                    .all(
                              14,
                            ),

                            decoration:
                                BoxDecoration(
                              color:
                                  AppColors.background,
                              borderRadius:
                                  BorderRadius.circular(
                                12,
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
                                const Text(
                                  'Notes',
                                  style:
                                      AppTextStyles.title,
                                ),

                                const SizedBox(
                                  height: 6,
                                ),

                                Text(
                                  delivery
                                      .notes!,
                                  style:
                                      AppTextStyles.body,
                                ),
                              ],
                            ),
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

  Widget _buildSummary(
    SupplierDelivery delivery,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(16),

      decoration:
          BoxDecoration(
        color:
            AppColors.primaryLight,
        borderRadius:
            BorderRadius.circular(
          14,
        ),
      ),

      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const Text(
                  'Delivery Date',
                  style:
                      AppTextStyles.small,
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  _formatDate(
                    delivery
                        .deliveryDate,
                  ),
                  style:
                      AppTextStyles.body,
                ),
              ],
            ),
          ),

          Container(
            width: 1,
            height: 42,
            color:
                AppColors.border,
          ),

          const SizedBox(
            width: 16,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.end,

              children: [
                const Text(
                  'Purchase Total',
                  style:
                      AppTextStyles.small,
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  _money(
                    delivery
                        .totalAmount,
                  ),
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
          const EdgeInsets.all(
        14,
      ),

      decoration:
          BoxDecoration(
        color:
            AppColors.background,
        borderRadius:
            BorderRadius.circular(
          12,
        ),
        border:
            Border.all(
          color:
              AppColors.border,
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,

            decoration:
                BoxDecoration(
              color:
                  AppColors.surface,
              borderRadius:
                  BorderRadius.circular(
                10,
              ),
            ),

            child: const Icon(
              Icons.inventory_2_outlined,
              color:
                  AppColors.primary,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      AppTextStyles.body,
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  '${item.quantity} × ${_money(item.unitCost)}',
                  style:
                      AppTextStyles.small,
                ),
              ],
            ),
          ),

          Text(
            _money(
              item.totalCost,
            ),
            style:
                AppTextStyles.price.copyWith(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyItems() {
    return Padding(
      padding:
          const EdgeInsets.all(
        20,
      ),

      child: Text(
        'No delivery items found.',
        textAlign:
            TextAlign.center,
        style:
            AppTextStyles.bodySecondary,
      ),
    );
  }

  String _money(double amount) {
    return '₦${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    final day =
        date.day.toString().padLeft(
              2,
              '0',
            );

    final month =
        date.month.toString().padLeft(
              2,
              '0',
            );

    return '$day/$month/${date.year}';
  }
}