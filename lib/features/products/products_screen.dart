// lib/features/products/product_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supermarket_inventory/core/widgets/back_button.dart';

import '../../core/theme/styles.dart';
import '../../database/app_database.dart';
import '../../database/daos/category_dao.dart';
import '../../database/daos/product_dao.dart';
import 'product_form_screen.dart';
import 'product_history_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late final ProductDao _productDao;
  late final CategoryDao _categoryDao;

  // ============================================================
  // CATEGORY STREAM
  // ============================================================

  late final Stream<List<Category>> _categoriesStream;

  // ============================================================
  // FILTER / SEARCH
  // ============================================================

  String _searchQuery = "";
  int? _selectedCategoryId;
  String _sortOption = "Name";

  // ============================================================
  // PAGINATION
  // ============================================================

  int _page = 0;
  final int _pageSize = 20;

  // Products already loaded into the UI.
  final List<Product> _loadedProducts = [];

  // Prevent duplicate load-more requests.
  bool _isLoadingMore = false;

  // Whether the last query returned a full page.
  bool _hasMoreProducts = true;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _productDao = getProductDao();
    _categoryDao = getCategoryDao();

    // Keep one category stream alive instead of repeatedly
    // calling getAllCategories() every time the screen rebuilds.
    _categoriesStream = _categoryDao.watchAllCategories();
  }

  // ============================================================
  // RESET PAGINATION
  // ============================================================

  void _resetPagination() {
    _page = 0;
    _loadedProducts.clear();
    _hasMoreProducts = true;
    _isLoadingMore = false;
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.trim().toLowerCase();
      _resetPagination();
    });
  }

  // ============================================================
  // CATEGORY
  // ============================================================

  void _onCategoryChanged(int? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _resetPagination();
    });
  }

  // ============================================================
  // SORT
  // ============================================================

  void _onSortChanged(String value) {
    setState(() {
      _sortOption = value;
      _resetPagination();
    });
  }

  // ============================================================
  // EDIT PRODUCT
  // ============================================================

  Future<void> _editProductDialog(Product p) async {
    final nameController = TextEditingController(text: p.name);
    final brandController = TextEditingController(
      text: p.brand ?? '',
    );

    final costController = TextEditingController(
      text: p.costPrice.toString(),
    );

    final sellController = TextEditingController(
      text: p.sellingPrice.toString(),
    );

    final expiryController = TextEditingController(
      text: p.expiryDate != null
          ? p.expiryDate!.toIso8601String().split('T').first
          : '',
    );

    String? updatedImage = p.imagePath;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            "Edit Product",
            style: AppTextStyles.heading,
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    style: AppTextStyles.body,
                    decoration: _inputDecoration(
                      label: "Product Name",
                      icon: Icons.inventory_2_outlined,
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: brandController,
                    style: AppTextStyles.body,
                    decoration: _inputDecoration(
                      label: "Brand",
                      icon: Icons.branding_watermark_outlined,
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: costController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: AppTextStyles.body,
                    decoration: _inputDecoration(
                      label: "Cost Price",
                      icon: Icons.payments_outlined,
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: sellController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: AppTextStyles.body,
                    decoration: _inputDecoration(
                      label: "Selling Price",
                      icon: Icons.sell_outlined,
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: expiryController,
                    style: AppTextStyles.body,
                    decoration: _inputDecoration(
                      label: "Expiry Date (YYYY-MM-DD)",
                      icon: Icons.calendar_today_outlined,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton.icon(
              onPressed: () async {
                DateTime? expiry;

                if (expiryController.text.trim().isNotEmpty) {
                  expiry = DateTime.tryParse(
                    expiryController.text.trim(),
                  );
                }

                await _productDao.updateProduct(
                  Product(
                    id: p.id,
                    name: nameController.text.trim(),
                    brand: brandController.text.trim().isEmpty
                        ? null
                        : brandController.text.trim(),
                    categoryId: p.categoryId,
                    unit: p.unit,
                    costPrice:
                        double.tryParse(
                          costController.text.trim(),
                        ) ??
                        p.costPrice,
                    sellingPrice:
                        double.tryParse(
                          sellController.text.trim(),
                        ) ??
                        p.sellingPrice,
                    stock: p.stock,
                    barcode: p.barcode,
                    imagePath: updatedImage,
                    expiryDate: expiry,
                  ),
                );

                if (!mounted) return;

                Navigator.pop(dialogContext);

                // The Drift stream will automatically refresh.
              },
              icon: const Icon(Icons.save_outlined),
              label: const Text("Save Changes"),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    brandController.dispose();
    costController.dispose();
    sellController.dispose();
    expiryController.dispose();
  }

  // ============================================================
  // DELETE PRODUCT
  // ============================================================

  Future<void> _deleteProduct(Product p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.dangerLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: AppColors.danger,
                ),
              ),

              const SizedBox(width: 12),

              const Text("Delete Product"),
            ],
          ),

          content: Text(
            "Are you sure you want to delete '${p.name}'?\n\n"
            "This action cannot be undone.",
            style: AppTextStyles.body,
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      await _productDao.deleteProduct(p.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${p.name} deleted"),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // No manual setState required.
      // Drift stream will update automatically.
    }
  }

  // ============================================================
  // SEARCH FIELD
  // ============================================================

  Widget _buildSearchField() {
    return TextField(
      onChanged: _onSearchChanged,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: 'Search products...',
        hintStyle: AppTextStyles.bodySecondary,
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY DROPDOWN
  // ============================================================

  Widget _buildCategoryDropdown() {
    return StreamBuilder<List<Category>>(
      stream: _categoriesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return Container(
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return InputDecorator(
            decoration: InputDecoration(
              labelText: 'Category',
              labelStyle: AppTextStyles.bodySecondary,
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Unable to load',
              overflow: TextOverflow.ellipsis,
            ),
          );
        }

        final categories = snapshot.data ?? [];

        return DropdownButtonFormField<int?>(
          initialValue: _selectedCategoryId,
          isExpanded: true,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            labelText: 'Category',
            labelStyle: AppTextStyles.bodySecondary,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text(
                'All Categories',
                overflow: TextOverflow.ellipsis,
              ),
            ),

            ...categories.map(
              (category) {
                return DropdownMenuItem<int?>(
                  value: category.id,
                  child: Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body,
                  ),
                );
              },
            ),
          ],
          onChanged: _onCategoryChanged,
        );
      },
    );
  }

  // ============================================================
  // SORT DROPDOWN
  // ============================================================

  Widget _buildSortDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _sortOption,
      isExpanded: true,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        labelText: 'Sort By',
        labelStyle: AppTextStyles.bodySecondary,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
      items: const [
        DropdownMenuItem<String>(
          value: 'Name',
          child: Text(
            'Name',
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DropdownMenuItem<String>(
          value: 'Price',
          child: Text(
            'Price',
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DropdownMenuItem<String>(
          value: 'Stock',
          child: Text(
            'Stock',
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
      onChanged: (value) {
        if (value == null) return;

        _onSortChanged(value);
      },
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.bodySecondary,
      prefixIcon: Icon(
        icon,
        color: AppColors.textSecondary,
      ),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
    );
  }

  // ============================================================
  // PRODUCT CARD
  // ============================================================

  Widget _buildCompactProductCard(Product p) {
    final bool isOutOfStock = p.stock <= 0;
    final bool isLowStock = p.stock > 0 && p.stock <= 5;

    final bool isExpired =
        p.expiryDate != null &&
        p.expiryDate!.isBefore(DateTime.now());

    return Card(
      elevation: 1,
      color: AppColors.productCard,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(
          color: AppColors.border,
        ),
      ),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductHistoryScreen(
                productId: p.id,
                productName: p.name,
              ),
            ),
          );

          if (!mounted) return;

          // The product stream handles database changes.
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========================================================
              // IMAGE
              // ========================================================

              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: p.imagePath != null
                      ? _buildProductImage(p.imagePath!)
                      : const Center(
                          child: Icon(
                            Icons.inventory_2_outlined,
                            size: 42,
                            color: AppColors.primary,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 10),

              // ========================================================
              // PRODUCT NAME
              // ========================================================

              Text(
                p.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.title,
              ),

              if (p.brand != null &&
                  p.brand!.trim().isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  p.brand!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.small,
                ),
              ],

              const SizedBox(height: 7),

              // ========================================================
              // PRICE
              // ========================================================

              Text(
                "₦${p.sellingPrice.toStringAsFixed(2)}",
                style: AppTextStyles.price.copyWith(
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 5),

              // ========================================================
              // STOCK STATUS
              // ========================================================

              Row(
                children: [
                  Expanded(
                    child: _buildStockBadge(
                      stock: p.stock,
                      unit: p.unit,
                      isOutOfStock: isOutOfStock,
                      isLowStock: isLowStock,
                    ),
                  ),

                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    iconSize: 20,
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editProductDialog(p);
                      } else if (value == 'delete') {
                        _deleteProduct(p);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 18,
                            ),
                            SizedBox(width: 10),
                            Text("Edit"),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: AppColors.danger,
                            ),
                            SizedBox(width: 10),
                            Text("Delete"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // ========================================================
              // EXPIRY
              // ========================================================

              if (p.expiryDate != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      isExpired
                          ? Icons.warning_amber_rounded
                          : Icons.event_outlined,
                      size: 14,
                      color: isExpired
                          ? AppColors.danger
                          : AppColors.textSecondary,
                    ),

                    const SizedBox(width: 4),

                    Expanded(
                      child: Text(
                        isExpired
                            ? "Expired"
                            : "Expires ${p.expiryDate!.toIso8601String().split('T').first}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.small.copyWith(
                          color: isExpired
                              ? AppColors.danger
                              : AppColors.textSecondary,
                          fontWeight: isExpired
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PRODUCT IMAGE
  // ============================================================

  Widget _buildProductImage(String path) {
    final file = File(path);

    if (!file.existsSync()) {
      return const Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 40,
          color: AppColors.textMuted,
        ),
      );
    }

    if (path.toLowerCase().endsWith('.svg')) {
      return SvgPicture.file(
        file,
        fit: BoxFit.contain,
      );
    }

    return Image.file(
      file,
      fit: BoxFit.contain,
    );
  }

  // ============================================================
  // STOCK BADGE
  // ============================================================

  Widget _buildStockBadge({
    required int stock,
    required String unit,
    required bool isOutOfStock,
    required bool isLowStock,
  }) {
    final Color color;
    final Color background;

    if (isOutOfStock) {
      color = AppColors.danger;
      background = AppColors.dangerLight;
    } else if (isLowStock) {
      color = AppColors.warning;
      background = AppColors.warningLight;
    } else {
      color = AppColors.success;
      background = AppColors.successLight;
    }

    final String label;

    if (isOutOfStock) {
      label = "Out of stock";
    } else if (isLowStock) {
      label = "Low stock • $stock $unit";
    } else {
      label = "$stock $unit in stock";
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.small.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    final bool hasFilters =
        _searchQuery.isNotEmpty ||
        _selectedCategoryId != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 44,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              hasFilters
                  ? "No products found"
                  : "No products yet",
              style: AppTextStyles.title,
            ),

            const SizedBox(height: 6),

            Text(
              hasFilters
                  ? "Try changing your search or category filter."
                  : "Add your first product to start managing inventory.",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary,
            ),

            if (hasFilters) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = "";
                    _selectedCategoryId = null;
                    _sortOption = "Name";
                    _resetPagination();
                  });
                },
                child: const Text("Clear Filters"),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LOAD MORE
  // ============================================================

  void _loadMoreProducts() {
    if (_isLoadingMore || !_hasMoreProducts) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
      _page++;
    });
  }

  // ============================================================
  // MERGE PAGE INTO LOADED PRODUCTS
  // ============================================================

  List<Product> _mergeProducts(
    List<Product> pageProducts,
  ) {
    if (pageProducts.isEmpty) {
      _hasMoreProducts = false;
      return _loadedProducts;
    }

    final existingIds = _loadedProducts
        .map((product) => product.id)
        .toSet();

    for (final product in pageProducts) {
      if (!existingIds.contains(product.id)) {
        _loadedProducts.add(product);
      }
    }

    if (pageProducts.length < _pageSize) {
      _hasMoreProducts = false;
    }

    _isLoadingMore = false;

    return _loadedProducts;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ============================================================
      // APP BAR
      // ============================================================

      appBar: AppBar(
        leading: const CentralBackButton(),
        title: const Text(
          "Products",
          style: AppTextStyles.heading,
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      // ============================================================
      // BODY
      // ============================================================

      body: Column(
        children: [
          // ============================================================
          // SEARCH / FILTERS
          // ============================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              8,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow =
                    constraints.maxWidth < 850;

                if (isNarrow) {
                  return Column(
                    children: [
                      _buildSearchField(),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _buildCategoryDropdown(),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: _buildSortDropdown(),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildSearchField(),
                    ),

                    const SizedBox(width: 12),

                    SizedBox(
                      width: 220,
                      child: _buildCategoryDropdown(),
                    ),

                    const SizedBox(width: 12),

                    SizedBox(
                      width: 180,
                      child: _buildSortDropdown(),
                    ),
                  ],
                );
              },
            ),
          ),

          // ============================================================
          // PRODUCTS
          // ============================================================

          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: _productDao.watchProductsFiltered(
                searchQuery: _searchQuery,
                categoryId: _selectedCategoryId,
                sortBy: _sortOption,
                limit: _pageSize,
                offset: _page * _pageSize,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  _isLoadingMore = false;

                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: AppColors.danger,
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            "Unable to load products",
                            style: AppTextStyles.title,
                          ),

                          const SizedBox(height: 6),

                          Text(
                            "${snapshot.error}",
                            textAlign: TextAlign.center,
                            style:
                                AppTextStyles.bodySecondary,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final pageProducts = snapshot.data ?? [];

                // ======================================================
                // FIRST PAGE / NEW FILTER
                // ======================================================

                final products = _mergeProducts(
                  pageProducts,
                );

                // ======================================================
                // EMPTY
                // ======================================================

                if (products.isEmpty) {
                  return _buildEmptyState();
                }

                // ======================================================
                // GRID
                // ======================================================

                return Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          8,
                          16,
                          16,
                        ),
                        physics:
                            const AlwaysScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1.05,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product =
                              products[index];

                          return _buildCompactProductCard(
                            product,
                          );
                        },
                      ),
                    ),

                    // ==================================================
                    // LOAD MORE
                    // ==================================================

                    if (_hasMoreProducts)
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          16,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed:
                                _isLoadingMore
                                    ? null
                                    : _loadMoreProducts,
                            icon: _isLoadingMore
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.expand_more,
                                  ),
                            label: Text(
                              _isLoadingMore
                                  ? "Loading..."
                                  : "Load More Products",
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),

      // ============================================================
      // ADD PRODUCT
      // ============================================================

      floatingActionButton:
          FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const ProductFormScreen(),
            ),
          );

          if (!mounted) return;

          // Drift stream automatically detects the
          // newly inserted product.
        },
        icon: const Icon(Icons.add),
        label: const Text(
          "Add Product",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    super.dispose();
  }
}

