// lib/features/stocks/stock_adjustment_screen.dart

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/styles.dart';
import '../../database/app_database.dart';
import '../../database/daos/stock_movement_dao.dart';

class StockAdjustmentScreen extends StatefulWidget {
  /// Optional supplier context.
  ///
  /// Supplier Management can open this screen with:
  ///
  /// StockAdjustmentScreen(
  ///   supplierId: supplier.id,
  /// )
  ///
  /// When null, the user may perform a general inventory adjustment.
  final int? supplierId;

  const StockAdjustmentScreen({super.key, this.supplierId});

  @override
  State<StockAdjustmentScreen> createState() => _StockAdjustmentScreenState();
}

class _StockAdjustmentScreenState extends State<StockAdjustmentScreen> {
  // ============================================================
  // DATABASE
  // ============================================================

  final AppDatabase _db = getDatabase();

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _quantityController = TextEditingController();

  final TextEditingController _searchController = TextEditingController();

  // ============================================================
  // STATE
  // ============================================================

  List<Product> _products = [];
  List<Supplier> _suppliers = [];

  Product? _selectedProduct;
  Supplier? _selectedSupplier;

  bool _isIncrease = true;
  bool _isLoading = true;
  bool _isSaving = false;

  String _searchQuery = '';

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _quantityController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> _loadData() async {
    try {
      final products =
          await (_db.select(_db.products)..orderBy([
                (p) => drift.OrderingTerm(
                  expression: p.name,
                  mode: drift.OrderingMode.asc,
                ),
              ]))
              .get();

      final suppliers =
          await (_db.select(_db.suppliers)..orderBy([
                (s) => drift.OrderingTerm(
                  expression: s.name,
                  mode: drift.OrderingMode.asc,
                ),
              ]))
              .get();

      Supplier? initialSupplier;

      if (widget.supplierId != null) {
        for (final supplier in suppliers) {
          if (supplier.id == widget.supplierId) {
            initialSupplier = supplier;
            break;
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _products = products;
        _suppliers = suppliers;
        _selectedSupplier = initialSupplier;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showError('Unable to load inventory data.\n$e');
    }
  }

  // ============================================================
  // FILTERED PRODUCTS
  // ============================================================

  List<Product> get _filteredProducts {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return _products;
    }

    return _products.where((product) {
      final name = product.name.toLowerCase();

      final barcode = (product.barcode ?? '').trim().toLowerCase();

      return name.contains(query) || barcode.contains(query);
    }).toList();
  }

  // ============================================================
  // QUANTITY
  // ============================================================

  int? get _enteredQuantity {
    final value = int.tryParse(_quantityController.text.trim());

    if (value == null || value <= 0) {
      return null;
    }

    return value;
  }

  // ============================================================
  // SIGNED QUANTITY
  // ============================================================

  int? get _signedQuantity {
    final quantity = _enteredQuantity;

    if (quantity == null) {
      return null;
    }

    return _isIncrease ? quantity : -quantity;
  }

  // ============================================================
  // NEW STOCK
  // ============================================================

  int? get _newStock {
    final product = _selectedProduct;
    final quantity = _signedQuantity;

    if (product == null || quantity == null) {
      return null;
    }

    return product.stock + quantity;
  }

  // ============================================================
  // SAVE ADJUSTMENT
  // ============================================================

  Future<void> _saveAdjustment() async {
    FocusScope.of(context).unfocus();

    final product = _selectedProduct;

    if (product == null) {
      _showError('Please select a product.');
      return;
    }

    final signedQuantity = _signedQuantity;

    if (signedQuantity == null || signedQuantity == 0) {
      _showError('Please enter a quantity greater than zero.');
      return;
    }

    final resultingStock = product.stock + signedQuantity;

    if (resultingStock < 0) {
      _showError(
        'This adjustment would make stock negative.\n'
        'Current stock: ${product.stock} ${product.unit}',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // ========================================================
      // STOCK ARCHITECTURE
      //
      // Do NOT update Products.stock directly here.
      //
      // StockMovementDao.insertMovement() is responsible for:
      //
      // 1. Creating the stock movement.
      // 2. Calculating the signed stock delta.
      // 3. Updating Products.stock.
      //
      // This keeps the ledger and stock quantity synchronized
      // without creating duplicate stock updates.
      // ========================================================

      final movementDao = StockMovementDao(_db);

      await movementDao.insertMovement(
        StockMovementsCompanion(
          productId: drift.Value(product.id),
          supplierId: _selectedSupplier == null
              ? const drift.Value.absent()
              : drift.Value(_selectedSupplier!.id),
          type: const drift.Value('adjustment'),
          deliveryId: const drift.Value.absent(),
          quantity: drift.Value(signedQuantity),
          unitPrice: drift.Value(product.costPrice),
        ),
      );

      if (!mounted) return;

      final adjustmentText = signedQuantity > 0
          ? '+$signedQuantity'
          : '$signedQuantity';

      final supplierText = _selectedSupplier == null
          ? ''
          : '\nSupplier: ${_selectedSupplier!.name}';

      _showSuccess(
        'Stock adjustment saved.\n'
        '${product.name}: '
        '$adjustmentText ${product.unit}'
        '$supplierText',
      );

      await _loadData();

      if (!mounted) return;

      setState(() {
        _selectedProduct = null;
        _quantityController.clear();
        _isIncrease = true;

        // Keep supplier context when opened from
        // Supplier Management.
        if (widget.supplierId == null) {
          _selectedSupplier = null;
        }
      });
    } catch (e) {
      if (!mounted) return;

      _showError('Unable to save stock adjustment.\n$e');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // SUCCESS MESSAGE
  // ============================================================

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: AppTextStyles.body),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ),
      );
  }

  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: AppTextStyles.body),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                responsive.horizontalPadding,
                responsive.verticalPadding,
                responsive.horizontalPadding,
                responsive.verticalPadding,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: responsive.contentMaxWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPageHeader(),

                      const SizedBox(height: AppSpacing.xxl),

                      _buildContent(responsive),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      titleSpacing: AppSpacing.xl,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Stock Adjustment', style: AppTextStyles.title),
          SizedBox(height: AppSpacing.xs),
          Text('Correct inventory quantities', style: AppTextStyles.small),
        ],
      ),
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent(Responsive responsive) {
    final form = _buildAdjustmentForm();
    final products = _buildProductList();

    if (responsive.isCompact || responsive.isTablet) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          form,
          const SizedBox(height: AppSpacing.xxl),
          products,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: form),
        const SizedBox(width: AppSpacing.xxl),
        Expanded(flex: 7, child: products),
      ],
    );
  }

  // ============================================================
  // PAGE HEADER
  // ============================================================

  Widget _buildPageHeader() {
    final supplier = _selectedSupplier;

    return _panel(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSizes.iconButton,
            height: AppSizes.iconButton,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Icon(Icons.tune_rounded, color: AppColors.primary),
          ),

          const SizedBox(width: AppSpacing.lg),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Adjust Inventory', style: AppTextStyles.heading),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  supplier == null
                      ? 'Use this screen for stock corrections, '
                            'damages, losses, counting differences, '
                            'or other inventory changes.'
                      : 'Adjust inventory associated with '
                            '${supplier.name}. This creates an '
                            'adjustment movement without creating '
                            'a supplier delivery.',
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ADJUSTMENT FORM
  // ============================================================

  Widget _buildAdjustmentForm() {
    final responsive = context.responsive;

    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Adjustment Details', style: AppTextStyles.heading),

          const SizedBox(height: AppSpacing.xs),

          const Text(
            'Select a product and specify how much stock should change.',
            style: AppTextStyles.small,
          ),

          const SizedBox(height: AppSpacing.xl),

          _buildProductDropdown(),

          if (_selectedProduct != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _buildCurrentStockCard(),
          ],

          const SizedBox(height: AppSpacing.xl),

          const Text('Adjustment Type', style: AppTextStyles.bodySecondary),

          const SizedBox(height: AppSpacing.sm),

          _buildDirectionSelector(),

          const SizedBox(height: AppSpacing.lg),

          _buildQuantityField(responsive),

          const SizedBox(height: AppSpacing.lg),

          _buildSupplierDropdown(),

          const SizedBox(height: AppSpacing.xl),

          if (_selectedProduct != null && _signedQuantity != null)
            _buildPreview(),

          const SizedBox(height: AppSpacing.xl),

          SizedBox(
            width: double.infinity,
            height: responsive.buttonHeight,
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _saveAdjustment,
              icon: _isSaving
                  ? const SizedBox(
                      width: AppSpacing.lg,
                      height: AppSpacing.lg,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.surface,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(
                _isSaving ? 'Saving Adjustment...' : 'Save Stock Adjustment',
                style: AppTextStyles.body,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          _buildInformationCard(),
        ],
      ),
    );
  }

  // ============================================================
  // QUANTITY FIELD
  // ============================================================

  Widget _buildQuantityField(Responsive responsive) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: responsive.controlHeight),
      child: TextField(
        controller: _quantityController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        enabled: !_isSaving,
        style: AppTextStyles.body,
        decoration: _inputDecoration(
          label: 'Quantity',
          hint: 'Enter quantity',
          prefixIcon: Icons.numbers_rounded,
        ),
        onChanged: (_) {
          setState(() {});
        },
        onSubmitted: (_) {
          if (!_isSaving) {
            _saveAdjustment();
          }
        },
      ),
    );
  }

  // ============================================================
  // PRODUCT DROPDOWN
  // ============================================================

  Widget _buildProductDropdown() {
    return DropdownButtonFormField<Product>(
      initialValue: _selectedProduct,
      isExpanded: true,
      style: AppTextStyles.body,
      decoration: _inputDecoration(
        label: 'Product',
        hint: 'Select product',
        prefixIcon: Icons.inventory_2_outlined,
      ),
      items: _filteredProducts
          .map(
            (product) => DropdownMenuItem<Product>(
              value: product,
              child: Text(
                '${product.name} • '
                'Stock: ${product.stock} ${product.unit}',
                style: AppTextStyles.body,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: _isSaving
          ? null
          : (product) {
              setState(() {
                _selectedProduct = product;
              });
            },
    );
  }

  // ============================================================
  // SUPPLIER DROPDOWN
  // ============================================================

  Widget _buildSupplierDropdown() {
    final isSupplierContext = widget.supplierId != null;

    return DropdownButtonFormField<Supplier?>(
      initialValue: _selectedSupplier,
      isExpanded: true,
      style: AppTextStyles.body,
      decoration: _inputDecoration(
        label: 'Supplier',
        hint: isSupplierContext
            ? 'Supplier context'
            : 'Optional supplier reference',
        prefixIcon: Icons.business_outlined,
      ),
      items: [
        if (!isSupplierContext)
          const DropdownMenuItem<Supplier?>(
            value: null,
            child: Text('No supplier', style: AppTextStyles.body),
          ),

        ..._suppliers.map(
          (supplier) => DropdownMenuItem<Supplier?>(
            value: supplier,
            child: Text(
              supplier.name,
              style: AppTextStyles.body,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
      onChanged: _isSaving || isSupplierContext
          ? null
          : (supplier) {
              setState(() {
                _selectedSupplier = supplier;
              });
            },
    );
  }

  // ============================================================
  // CURRENT STOCK
  // ============================================================

  Widget _buildCurrentStockCard() {
    final product = _selectedProduct!;
    final stock = product.stock;

    final stockColor = stock <= 0
        ? AppColors.danger
        : stock <= 10
        ? AppColors.warning
        : AppColors.primary;

    final stockBackground = stock <= 0
        ? AppColors.dangerLight
        : stock <= 10
        ? AppColors.warningLight
        : AppColors.primaryLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: stockBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: stockColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(Icons.inventory_2_outlined, color: stockColor),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current Stock', style: AppTextStyles.small),

                const SizedBox(height: AppSpacing.xs),

                Text(
                  '$stock ${product.unit}',
                  style: AppTextStyles.price.copyWith(color: stockColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DIRECTION SELECTOR
  // ============================================================

  Widget _buildDirectionSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildDirectionButton(
            title: 'Increase',
            subtitle: 'Add stock',
            icon: Icons.add_circle_outline,
            selected: _isIncrease,
            onTap: () {
              setState(() {
                _isIncrease = true;
              });
            },
          ),
        ),

        const SizedBox(width: AppSpacing.md),

        Expanded(
          child: _buildDirectionButton(
            title: 'Decrease',
            subtitle: 'Remove stock',
            icon: Icons.remove_circle_outline,
            selected: !_isIncrease,
            onTap: () {
              setState(() {
                _isIncrease = false;
              });
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DIRECTION BUTTON
  // ============================================================

  Widget _buildDirectionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _isSaving ? null : onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: AppSpacing.xl,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),

            const SizedBox(width: AppSpacing.sm),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodySecondary.copyWith(
                      color: selected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  Text(subtitle, style: AppTextStyles.small),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PREVIEW
  // ============================================================

  Widget _buildPreview() {
    final product = _selectedProduct!;
    final quantity = _signedQuantity!;
    final newStock = product.stock + quantity;
    final isValid = newStock >= 0;

    final backgroundColor = isValid
        ? AppColors.primaryLight
        : AppColors.dangerLight;

    final borderColor = isValid ? AppColors.primary : AppColors.danger;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Stock Preview', style: AppTextStyles.bodySecondary),

          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                child: _previewValue(
                  label: 'Current',
                  value: '${product.stock}',
                ),
              ),

              const Icon(
                Icons.arrow_forward,
                size: AppSpacing.lg,
                color: AppColors.textSecondary,
              ),

              Expanded(
                child: _previewValue(
                  label: 'Adjustment',
                  value: quantity > 0 ? '+$quantity' : '$quantity',
                ),
              ),

              const Icon(
                Icons.arrow_forward,
                size: AppSpacing.lg,
                color: AppColors.textSecondary,
              ),

              Expanded(
                child: _previewValue(label: 'New Stock', value: '$newStock'),
              ),
            ],
          ),

          if (!isValid) ...[
            const SizedBox(height: AppSpacing.sm),

            const Text(
              'This adjustment would result in negative stock.',
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // PREVIEW VALUE
  // ============================================================

  Widget _previewValue({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.small),

        const SizedBox(height: AppSpacing.xs),

        Text(value, style: AppTextStyles.price),
      ],
    );
  }

  // ============================================================
  // INFORMATION CARD
  // ============================================================

  Widget _buildInformationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: AppSpacing.lg,
            color: AppColors.info,
          ),

          const SizedBox(width: AppSpacing.sm),

          Expanded(
            child: Text(
              'This creates one adjustment movement in the '
              'stock ledger. It does not create a supplier '
              'delivery, purchase movement, or duplicate stock update.',
              style: AppTextStyles.small.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRODUCT LIST
  // ============================================================

  Widget _buildProductList() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Products', style: AppTextStyles.heading),

                    SizedBox(height: AppSpacing.xs),

                    Text(
                      'Select a product to adjust its stock.',
                      style: AppTextStyles.small,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.round),
                ),
                child: Text(
                  '${_filteredProducts.length}',
                  style: AppTextStyles.small.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          TextField(
            controller: _searchController,
            enabled: !_isSaving,
            style: AppTextStyles.body,
            decoration: _inputDecoration(
              label: 'Search',
              hint: 'Product name or barcode',
              prefixIcon: Icons.search_rounded,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),

          const SizedBox(height: AppSpacing.lg),

          if (_filteredProducts.isEmpty)
            _buildEmptyProducts()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredProducts.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];

                final selected = _selectedProduct?.id == product.id;

                return _buildProductRow(product, selected);
              },
            ),
        ],
      ),
    );
  }

  // ============================================================
  // PRODUCT ROW
  // ============================================================

  Widget _buildProductRow(Product product, bool selected) {
    final stock = product.stock;

    final stockColor = stock <= 0
        ? AppColors.danger
        : stock <= 10
        ? AppColors.warning
        : AppColors.textPrimary;

    return InkWell(
      onTap: _isSaving
          ? null
          : () {
              setState(() {
                _selectedProduct = product;
              });
            },
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Container(
              width: AppSizes.iconButton,
              height: AppSizes.iconButton,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                color: selected ? AppColors.surface : AppColors.primary,
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySecondary.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  Text(
                    product.barcode == null || product.barcode!.trim().isEmpty
                        ? 'No barcode'
                        : product.barcode!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.small,
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Stock', style: AppTextStyles.small),

                const SizedBox(height: AppSpacing.xs),

                Text(
                  '$stock',
                  style: AppTextStyles.bodySecondary.copyWith(
                    color: stockColor,
                  ),
                ),
              ],
            ),

            const SizedBox(width: AppSpacing.sm),

            Icon(
              selected ? Icons.check_circle : Icons.chevron_right,
              size: AppSpacing.xl,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY PRODUCTS
  // ============================================================

  Widget _buildEmptyProducts() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.huge),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: AppSpacing.section,
              color: AppColors.textMuted,
            ),

            SizedBox(height: AppSpacing.md),

            Text('No products found', style: AppTextStyles.bodySecondary),

            SizedBox(height: AppSpacing.xs),

            Text(
              'Try another product name or barcode.',
              textAlign: TextAlign.center,
              style: AppTextStyles.small,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PANEL
  // ============================================================

  Widget _panel({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(AppSpacing.xl),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(prefixIcon),
      labelStyle: AppTextStyles.bodySecondary,
      hintStyle: AppTextStyles.small,
      filled: true,
      fillColor: AppColors.background,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(color: AppColors.border),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),

      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(color: AppColors.divider),
      ),

      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
    );
  }
}
