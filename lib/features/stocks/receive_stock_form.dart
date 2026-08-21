// lib/features/stocks/receive_stock_form.dart

import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;
import 'package:go_router/go_router.dart';

import '../../database/app_database.dart';
import '../../database/daos/stock_movement_dao.dart';
import '../../database/daos/supplier_dao.dart';
import '../../database/daos/product_dao.dart';
import '../../core/theme/styles.dart';

class ReceiveStockForm extends StatefulWidget {
  const ReceiveStockForm({super.key});

  @override
  State<ReceiveStockForm> createState() =>
      _ReceiveStockFormState();
}

class _ReceiveStockFormState extends State<ReceiveStockForm> {
  final _formKey = GlobalKey<FormState>();

  late final StockMovementDao _movementDao;
  late final SupplierDao _supplierDao;
  late final ProductDao _productDao;

  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();

  int? _selectedSupplierId;
  int? _selectedProductId;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _movementDao = getStockMovementDao();
    _supplierDao = getSupplierDao();
    _productDao = getProductDao();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _unitPriceController.dispose();
    super.dispose();
  }

  // ============================================================
  // SAVE STOCK MOVEMENT
  // ============================================================

  Future<void> _saveMovement() async {
    if (_saving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedProductId == null) {
      return;
    }

    if (_selectedSupplierId == null) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final quantity =
          int.tryParse(
        _quantityController.text.trim(),
      );

      final unitPrice =
          double.tryParse(
        _unitPriceController.text.trim(),
      );

      if (quantity == null || quantity <= 0) {
        throw Exception(
          'Quantity must be greater than zero.',
        );
      }

      if (unitPrice == null || unitPrice < 0) {
        throw Exception(
          'Enter a valid unit price.',
        );
      }

      // ----------------------------------------------------------
      // GET CURRENT PRODUCT
      // ----------------------------------------------------------
      //
      // We only read the current stock here so that we can show
      // the user what happened after the movement is saved.
      //
      // We DO NOT update the product stock here.
      //
      // StockMovementDao.insertMovement() is responsible for:
      //
      // 1. Creating the movement
      // 2. Updating Products.stock
      //
      // Both operations happen atomically inside one transaction.
      //
      // ----------------------------------------------------------

      final product =
          await _productDao.getProductById(
        _selectedProductId!,
      );

      final currentStock = product.stock;

      // ----------------------------------------------------------
      // CREATE PURCHASE MOVEMENT
      // ----------------------------------------------------------

      final movement =
          StockMovementsCompanion(
        productId: Value(
          _selectedProductId!,
        ),
        supplierId: Value(
          _selectedSupplierId!,
        ),
        type: const Value(
          'purchase',
        ),
        quantity: Value(
          quantity,
        ),
        unitPrice: Value(
          unitPrice,
        ),
        date: Value(
          DateTime.now(),
        ),
      );

      // ----------------------------------------------------------
      // INSERT MOVEMENT
      // ----------------------------------------------------------
      //
      // The DAO will automatically increase stock by quantity.
      //
      // currentStock = 50
      // purchase      = 10
      // new stock     = 60
      //
      // DO NOT call updateProductStock() here.
      //
      // ----------------------------------------------------------

      await _movementDao.insertMovement(
        movement,
      );

      if (!mounted) return;

      final newStock =
          currentStock + quantity;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Stock received successfully.\n'
            'Stock increased from '
            '$currentStock to $newStock.',
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );

      context.pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to receive stock: $e',
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        title: const Text(
          'Receive Stock',
          style: AppTextStyles.heading,
        ),
        backgroundColor:
            AppColors.primary,
        foregroundColor: Colors.white,
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: Padding(
        padding:
            AppTextStyles.screenPadding,

        child: Form(
          key: _formKey,

          child: ListView(
            children: [
              // ====================================================
              // PRODUCT
              // ====================================================

              FutureBuilder<List<Product>>(
                future:
                    _productDao.getAllProducts(),

                builder:
                    (context, snapshot) {
                  if (snapshot.connectionState !=
                      ConnectionState.done) {
                    return const Center(
                      child:
                          CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Text(
                      'Error loading products: '
                      '${snapshot.error}',
                      style:
                          AppTextStyles.bodySecondary,
                    );
                  }

                  final products =
                      snapshot.data ?? [];

                  if (products.isEmpty) {
                    return const Text(
                      'No products available. '
                      'Create a product first.',
                      style:
                          AppTextStyles.bodySecondary,
                    );
                  }

                  return DropdownButtonFormField<int>(
                    initialValue:
                        _selectedProductId,

                    isExpanded: true,

                    decoration:
                        const InputDecoration(
                      labelText: 'Product',
                      border:
                          OutlineInputBorder(),
                    ),

                    items:
                        products.map(
                      (product) {
                        return DropdownMenuItem<int>(
                          value:
                              product.id,

                          child: Text(
                            '${product.name}'
                            ' (${product.brand ?? ''})'
                            ' - Stock: '
                            '${product.stock}',
                            overflow:
                                TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ).toList(),

                    onChanged: _saving
                        ? null
                        : (value) {
                            if (!mounted) {
                              return;
                            }

                            setState(() {
                              _selectedProductId =
                                  value;
                            });
                          },

                    validator: (value) {
                      if (value == null) {
                        return 'Select product';
                      }

                      return null;
                    },
                  );
                },
              ),

              const SizedBox(height: 16),

              // ====================================================
              // SUPPLIER
              // ====================================================

              FutureBuilder<List<Supplier>>(
                future:
                    _supplierDao.getAllSuppliers(),

                builder:
                    (context, snapshot) {
                  if (snapshot.connectionState !=
                      ConnectionState.done) {
                    return const Center(
                      child:
                          CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Text(
                      'Error loading suppliers: '
                      '${snapshot.error}',
                      style:
                          AppTextStyles.bodySecondary,
                    );
                  }

                  final suppliers =
                      snapshot.data ?? [];

                  if (suppliers.isEmpty) {
                    return const Text(
                      'No suppliers available. '
                      'Create a supplier first.',
                      style:
                          AppTextStyles.bodySecondary,
                    );
                  }

                  return DropdownButtonFormField<int>(
                    initialValue:
                        _selectedSupplierId,

                    isExpanded: true,

                    decoration:
                        const InputDecoration(
                      labelText: 'Supplier',
                      border:
                          OutlineInputBorder(),
                    ),

                    items:
                        suppliers.map(
                      (supplier) {
                        return DropdownMenuItem<int>(
                          value:
                              supplier.id,

                          child: Text(
                            supplier.name,
                            overflow:
                                TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ).toList(),

                    onChanged: _saving
                        ? null
                        : (value) {
                            if (!mounted) {
                              return;
                            }

                            setState(() {
                              _selectedSupplierId =
                                  value;
                            });
                          },

                    validator: (value) {
                      if (value == null) {
                        return 'Select supplier';
                      }

                      return null;
                    },
                  );
                },
              ),

              const SizedBox(height: 16),

              // ====================================================
              // QUANTITY
              // ====================================================

              TextFormField(
                controller:
                    _quantityController,

                enabled: !_saving,

                decoration:
                    const InputDecoration(
                  labelText: 'Quantity',
                  hintText: 'e.g. 100',
                  border:
                      OutlineInputBorder(),
                ),

                keyboardType:
                    TextInputType.number,

                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Enter quantity';
                  }

                  final quantity =
                      int.tryParse(
                    value.trim(),
                  );

                  if (quantity == null ||
                      quantity <= 0) {
                    return
                        'Enter a valid quantity greater than 0';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ====================================================
              // UNIT PRICE
              // ====================================================

              TextFormField(
                controller:
                    _unitPriceController,

                enabled: !_saving,

                decoration:
                    const InputDecoration(
                  labelText:
                      'Unit Cost Price',
                  hintText: 'e.g. 1000',
                  border:
                      OutlineInputBorder(),
                ),

                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal: true,
                ),

                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return
                        'Enter unit cost price';
                  }

                  final price =
                      double.tryParse(
                    value.trim(),
                  );

                  if (price == null ||
                      price < 0) {
                    return
                        'Enter a valid price';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              // ====================================================
              // SAVE
              // ====================================================

              SizedBox(
                height: 50,

                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.accent,
                    foregroundColor:
                        Colors.white,
                  ),

                  onPressed:
                      _saving
                          ? null
                          : _saveMovement,

                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                Colors.white,
                          ),
                        )
                      : const Text(
                          'Save Stock Movement',
                          style:
                              AppTextStyles.body,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

