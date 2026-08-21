// lib/features/stocks/receive_stock_screen.dart

import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;


import 'package:supermarket_inventory/core/widgets/back_button.dart';
import '../../core/theme/styles.dart';
import '../../database/app_database.dart';
import '../../database/daos/product_dao.dart';
import '../../database/daos/supplier_dao.dart';
import '../../database/daos/stock_movement_dao.dart';
import 'package:go_router/go_router.dart';

class ReceiveStockScreen extends StatefulWidget {
  const ReceiveStockScreen({super.key});

  @override
  State<ReceiveStockScreen> createState() => _ReceiveStockScreenState();
}

class _ReceiveStockScreenState extends State<ReceiveStockScreen> {
  final _formKey = GlobalKey<FormState>();

  late final ProductDao _productDao;
  late final SupplierDao _supplierDao;
  late final StockMovementDao _movementDao;

  int? _selectedProductId;
  int? _selectedSupplierId;

  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _productDao = getProductDao();
    _supplierDao = getSupplierDao();
    _movementDao = getStockMovementDao();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _unitPriceController.dispose();
    super.dispose();
  }

  Future<void> _saveMovement() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedProductId == null) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final quantity = int.parse(_quantityController.text.trim());
      final unitPrice =
          double.tryParse(_unitPriceController.text.trim()) ?? 0.0;

      // ------------------------------------------------------------
      // 1. Get current product
      // ------------------------------------------------------------

      final product =
          await _productDao.getProductById(_selectedProductId!);

      // ------------------------------------------------------------
      // 2. Calculate new stock
      // ------------------------------------------------------------

      final currentStock = product.stock;
      final newStock = currentStock + quantity;

      // ------------------------------------------------------------
      // 3. Record stock movement
      // ------------------------------------------------------------

      final movement = StockMovementsCompanion(
        productId: Value(_selectedProductId!),
        supplierId: Value(_selectedSupplierId),
        type: const Value('purchase'),
        quantity: Value(quantity),
        unitPrice: Value(unitPrice),
        date: Value(DateTime.now()),
      );

      await _movementDao.insertMovement(movement);

      // ------------------------------------------------------------
      // 4. Update current product stock
      // ------------------------------------------------------------

      await _productDao.updateProductStock(
        _selectedProductId!,
        newStock,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Stock received successfully. '
            'Stock increased from $currentStock to $newStock.',
          ),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to receive stock: $e'),
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
      backgroundColor: AppColors.background,

      appBar: AppBar(
        leading: const CentralBackButton(),
        title: const Text(
          'Receive Stock',
          style: AppTextStyles.heading,
        ),
        backgroundColor: AppColors.primary,
      ),

      body: Padding(
        padding: AppTextStyles.screenPadding,

        child: Form(
          key: _formKey,

          child: ListView(
            children: [

              // ======================================================
              // PRODUCT
              // ======================================================

              FutureBuilder<List<Product>>(
                future: _productDao.getAllProducts(),

                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Text(
                      'Error loading products: ${snapshot.error}',
                    );
                  }

                  final products = snapshot.data ?? [];

                  if (products.isEmpty) {
                    return const Text(
                      'No products available. '
                      'Create a product first.',
                    );
                  }

                  return DropdownButtonFormField<int>(
                    initialValue: _selectedProductId,

                    decoration: const InputDecoration(
                      labelText: 'Product',
                    ),

                    items: products.map((product) {
                      return DropdownMenuItem<int>(
                        value: product.id,

                        child: Text(
                          '${product.name} '
                          '(${product.brand }) '
                          '- Stock: ${product.stock }',
                        ),
                      );
                    }).toList(),

                    onChanged: (value) {
                      setState(() {
                        _selectedProductId = value;
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

              // ======================================================
              // SUPPLIER
              // ======================================================

              FutureBuilder<List<Supplier>>(
                future: _supplierDao.getAllSuppliers(),

                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Text(
                      'Error loading suppliers: ${snapshot.error}',
                    );
                  }

                  final suppliers = snapshot.data ?? [];

                  if (suppliers.isEmpty) {
                    return const Text(
                      'No suppliers available. '
                      'Create a supplier first.',
                    );
                  }

                  return DropdownButtonFormField<int>(
                    initialValue: _selectedSupplierId,

                    decoration: const InputDecoration(
                      labelText: 'Supplier',
                    ),

                    items: suppliers.map((supplier) {
                      return DropdownMenuItem<int>(
                        value: supplier.id,

                        child: Text(
                          supplier.name,
                        ),
                      );
                    }).toList(),

                    onChanged: (value) {
                      setState(() {
                        _selectedSupplierId = value;
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

              // ======================================================
              // QUANTITY
              // ======================================================

              TextFormField(
                controller: _quantityController,

                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  hintText: 'e.g. 100',
                ),

                keyboardType: TextInputType.number,

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter quantity';
                  }

                  final quantity = int.tryParse(value.trim());

                  if (quantity == null || quantity <= 0) {
                    return 'Enter a valid quantity greater than 0';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ======================================================
              // UNIT PRICE
              // ======================================================

              TextFormField(
                controller: _unitPriceController,

                decoration: const InputDecoration(
                  labelText: 'Unit Cost Price',
                  hintText: 'e.g. 1000',
                ),

                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter unit cost price';
                  }

                  final price =
                      double.tryParse(value.trim());

                  if (price == null || price < 0) {
                    return 'Enter a valid price';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              // ======================================================
              // STOCK ADJUSTMENT TEST
              // ======================================================

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                onPressed: () {
                  context.push('/stock-adjustment');
                },
                child: const Text(
                  'Stock Adjustment',
                  style: AppTextStyles.body,
                ),
              ),

              const SizedBox(height: 12),
              // ======================================================
              // SAVE
              // ======================================================

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                ),

                onPressed: _saving ? null : _saveMovement,

                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Stock Movement',
                        style: AppTextStyles.body,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}