//lib/features/stocks/stock_adjustment_screen.dart

import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;

import 'package:supermarket_inventory/core/widgets/back_button.dart';
import '../../core/theme/styles.dart';
import '../../database/app_database.dart';
import '../../database/daos/product_dao.dart';
import '../../database/daos/stock_movement_dao.dart';

class StockAdjustmentScreen extends StatefulWidget {
  const StockAdjustmentScreen({super.key});

  @override
  State<StockAdjustmentScreen> createState() =>
      _StockAdjustmentScreenState();
}

class _StockAdjustmentScreenState
    extends State<StockAdjustmentScreen> {
  final _formKey = GlobalKey<FormState>();

  late final ProductDao _productDao;
  late final StockMovementDao _movementDao;

  int? _selectedProductId;

  String _adjustmentType = 'increase';

  final _quantityController = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _productDao = getProductDao();
    _movementDao = getStockMovementDao();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _saveAdjustment() async {
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
      final quantity =
          int.parse(_quantityController.text.trim());

      final product =
          await _productDao.getProductById(
        _selectedProductId!,
      );

      final currentStock = product.stock;

      final adjustmentQuantity =
          _adjustmentType == 'increase'
              ? quantity
              : -quantity;

      final newStock =
          currentStock + adjustmentQuantity;

      if (newStock < 0) {
        throw Exception(
          'Stock cannot become negative. '
          'Current stock is $currentStock.',
        );
      }

      final movement = StockMovementsCompanion(
        productId: Value(_selectedProductId!),
        supplierId: const Value(null),
        type: const Value('adjustment'),
        quantity: Value(adjustmentQuantity),
        unitPrice: const Value(0.0),
        date: Value(DateTime.now()),
      );

      await _movementDao.insertMovement(movement);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Stock adjusted successfully. '
            '$currentStock → $newStock',
          ),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to adjust stock: $e',
          ),
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
          'Stock Adjustment',
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
                  if (snapshot.connectionState !=
                      ConnectionState.done) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Text(
                      'Error loading products: '
                      '${snapshot.error}',
                    );
                  }

                  final products =
                      snapshot.data ?? [];

                  if (products.isEmpty) {
                    return const Text(
                      'No products available. '
                      'Create a product first.',
                    );
                  }

                  return DropdownButtonFormField<int>(
                    initialValue:
                        _selectedProductId,

                    decoration:
                        const InputDecoration(
                      labelText: 'Product',
                    ),

                    items: products.map((product) {
                      return DropdownMenuItem<int>(
                        value: product.id,

                        child: Text(
                          '${product.name} '
                          '(${product.brand ?? ''}) '
                          '- Stock: '
                          '${product.stock}',
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

              const SizedBox(height: 20),

              // ======================================================
              // ADJUSTMENT TYPE
              // ======================================================

              DropdownButtonFormField<String>(
                initialValue: _adjustmentType,

                decoration:
                    const InputDecoration(
                  labelText: 'Adjustment Type',
                ),

                items: const [
                  DropdownMenuItem(
                    value: 'increase',
                    child: Text(
                      'Increase Stock',
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'decrease',
                    child: Text(
                      'Decrease Stock',
                    ),
                  ),
                ],

                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _adjustmentType = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              // ======================================================
              // QUANTITY
              // ======================================================

              TextFormField(
                controller:
                    _quantityController,

                decoration:
                    const InputDecoration(
                  labelText: 'Quantity',
                  hintText: 'e.g. 10',
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
                    return 'Enter a quantity greater than 0';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 28),

              // ======================================================
              // SAVE
              // ======================================================

              ElevatedButton(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.accent,
                ),

                onPressed:
                    _saving
                        ? null
                        : _saveAdjustment,

                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Adjustment',
                        style:
                            AppTextStyles.body,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}