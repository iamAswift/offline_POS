// lib/features/sales/product_grid_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/theme/styles.dart';
import '../../core/responsive/responsive.dart';
import '../../database/app_database.dart';

class ProductGridScreen extends StatefulWidget {
  final Category category;
  final List products;
  final Map<int, int> cart;
  final VoidCallback onCartUpdated;

  const ProductGridScreen({
    super.key,
    required this.category,
    required this.products,
    required this.cart,
    required this.onCartUpdated,
  });

  @override
  State<ProductGridScreen> createState() => _ProductGridScreenState();
}

class _ProductGridScreenState extends State<ProductGridScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // FILTERED PRODUCTS
  // ============================================================

  List<dynamic> get _filteredProducts {
    if (_searchQuery.isEmpty) {
      return widget.products;
    }

    return widget.products.where((product) {
      final name = product.name.toString().toLowerCase();

      return name.contains(_searchQuery);
    }).toList();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: AppColors.background,

      // ==========================================================
      // APP BAR
      // ==========================================================
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        automaticallyImplyLeading: true,

        toolbarHeight: responsive.isCompact ? 58 : 66,

        titleSpacing: responsive.isCompact ? 10 : 16,

        title: Row(
          children: [
            // ----------------------------------------------------
            // CATEGORY ICON
            // ----------------------------------------------------
            Container(
              width: responsive.isCompact ? 34 : 40,
              height: responsive.isCompact ? 34 : 40,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(
                  responsive.isCompact ? AppRadius.md : AppRadius.lg,
                ),
              ),
              child: Icon(
                Icons.category_outlined,
                color: AppColors.primary,
                size: responsive.isCompact ? 18 : 21,
              ),
            ),

            SizedBox(width: responsive.isCompact ? 8 : 11),

            // ----------------------------------------------------
            // CATEGORY TITLE
            // ----------------------------------------------------
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.title.copyWith(
                      fontSize: responsive.isCompact ? 14 : 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  if (!responsive.isCompact)
                    Text(
                      '${widget.products.length} product${widget.products.length == 1 ? '' : 's'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.small.copyWith(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),

            // ----------------------------------------------------
            // DESKTOP / TABLET SEARCH
            // ----------------------------------------------------
            if (!responsive.isCompact) ...[
              const SizedBox(width: 12),

              SizedBox(
                width: responsive.isTablet ? 220 : 280,
                height: 40,
                child: _buildSearchField(compact: false),
              ),

              const SizedBox(width: 10),
            ],

            // ----------------------------------------------------
            // CART
            // ----------------------------------------------------
            _buildCartIndicator(compact: responsive.isCompact),
          ],
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================
      body: Column(
        children: [
          // ------------------------------------------------------
          // COMPACT SEARCH
          // ------------------------------------------------------
          if (responsive.isCompact)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.sm,
                2,
              ),
              child: SizedBox(
                height: 40,
                child: _buildSearchField(compact: true),
              ),
            ),

          // ------------------------------------------------------
          // PRODUCTS
          // ------------------------------------------------------
          Expanded(
            child: products.isEmpty
                ? _buildEmptyState()
                : _buildProductGrid(products, responsive),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH FIELD
  // ============================================================

  Widget _buildSearchField({required bool compact}) {
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      style: AppTextStyles.body.copyWith(
        fontSize: compact ? 12 : 13,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: 'Search products',
        hintStyle: AppTextStyles.small.copyWith(fontSize: compact ? 11 : 12),
        prefixIcon: Icon(
          Icons.search,
          size: compact ? 18 : 19,
          color: AppColors.textSecondary,
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                tooltip: 'Clear search',
                padding: EdgeInsets.zero,
                onPressed: () {
                  _searchController.clear();
                },
                icon: Icon(Icons.close, size: compact ? 17 : 18),
              )
            : null,
        filled: true,
        fillColor: AppColors.surfaceSoft,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 6,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
      ),
    );
  }

  // ============================================================
  // PRODUCT GRID
  // ============================================================

  Widget _buildProductGrid(List<dynamic> products, Responsive responsive) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // --------------------------------------------------------
        // EXTREMELY COMPACT POS GRID
        //
        // The goal here is to fit as many products as possible.
        // --------------------------------------------------------

        int columns;

        if (width >= 1500) {
          columns = 7;
        } else if (width >= 1200) {
          columns = 6;
        } else if (width >= 900) {
          columns = 5;
        } else if (width >= 650) {
          columns = 4;
        } else {
          columns = 3;
        }

        // --------------------------------------------------------
        // VERY SMALL GAPS
        // --------------------------------------------------------

        final spacing = responsive.isCompact ? AppSpacing.xs : AppSpacing.sm;

        return GridView.builder(
          padding: EdgeInsets.fromLTRB(
            responsive.isCompact ? AppSpacing.sm : AppSpacing.md,
            responsive.isCompact ? AppSpacing.xs : AppSpacing.sm,
            responsive.isCompact ? AppSpacing.sm : AppSpacing.md,
            responsive.isCompact ? 70 : 90,
          ),

          physics: const BouncingScrollPhysics(),

          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,

            // ----------------------------------------------------
            // SHORT / COMPACT CARDS
            // ----------------------------------------------------
            childAspectRatio: responsive.isCompact
                ? 1.02
                : responsive.isTablet
                ? 1.12
                : responsive.isLargeDesktop
                ? 1.30
                : 1.22,
          ),

          itemCount: products.length,

          itemBuilder: (context, index) {
            final product = products[index];

            return _buildProductCard(context, product, responsive);
          },
        );
      },
    );
  }

  // ============================================================
  // PRODUCT CARD
  // ============================================================

  Widget _buildProductCard(
    BuildContext context,
    dynamic product,
    Responsive responsive,
  ) {
    final qty = widget.cart[product.id] ?? 0;

    final stock = product.stock;

    final isOutOfStock = stock <= 0;

    final canAdd = qty < stock;

    final isInCart = qty > 0;

    final compact = responsive.isCompact;

    return Material(
      color: Colors.transparent,

      borderRadius: BorderRadius.circular(
        compact ? AppRadius.md : AppRadius.lg,
      ),

      child: InkWell(
        borderRadius: BorderRadius.circular(
          compact ? AppRadius.md : AppRadius.lg,
        ),

        onTap: isOutOfStock ? null : () => _addToCart(product),

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),

          padding: EdgeInsets.all(compact ? AppSpacing.xs : AppSpacing.sm),

          decoration: BoxDecoration(
            color: isInCart
                ? AppColors.primaryLight.withValues(alpha: 0.55)
                : AppColors.productCard,

            borderRadius: BorderRadius.circular(
              compact ? AppRadius.md : AppRadius.lg,
            ),

            border: Border.all(
              color: isInCart
                  ? AppColors.primary.withValues(alpha: 0.55)
                  : AppColors.border,
              width: isInCart ? 1.2 : 0.8,
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.025),
                blurRadius: compact ? 3 : 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ==================================================
              // PRODUCT IMAGE
              // ==================================================
              Expanded(
                flex: 5,

                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSoft,
                          borderRadius: BorderRadius.circular(
                            compact ? AppRadius.sm : AppRadius.md,
                          ),
                        ),

                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            compact ? AppRadius.sm : AppRadius.md,
                          ),

                          child:
                              product.imagePath != null &&
                                  product.imagePath!.isNotEmpty
                              ? Image.file(
                                  File(product.imagePath!),
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) {
                                    return _buildImagePlaceholder(
                                      isOutOfStock,
                                      compact,
                                    );
                                  },
                                )
                              : _buildImagePlaceholder(isOutOfStock, compact),
                        ),
                      ),
                    ),

                    // ------------------------------------------------
                    // STOCK BADGE
                    // ------------------------------------------------
                    Positioned(
                      top: compact ? 3 : 5,
                      right: compact ? 3 : 5,
                      child: _buildStockBadge(stock, compact),
                    ),

                    // ------------------------------------------------
                    // CART QUANTITY
                    // ------------------------------------------------
                    if (isInCart)
                      Positioned(
                        top: compact ? 3 : 5,
                        left: compact ? 3 : 5,
                        child: _buildCartQuantityBadge(qty, compact),
                      ),
                  ],
                ),
              ),

              SizedBox(height: compact ? 4 : 6),

              // ==================================================
              // PRODUCT NAME
              // ==================================================
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  fontSize: compact ? 10 : 12,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  color: AppColors.productText,
                ),
              ),

              SizedBox(height: compact ? 2 : 3),

              // ==================================================
              // PRICE
              // ==================================================
              Text(
                '₦${_formatMoney(product.sellingPrice)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.price.copyWith(
                  fontSize: compact ? 11 : 14,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),

              SizedBox(height: compact ? 3 : 5),

              // ==================================================
              // QUANTITY
              // ==================================================
              if (isOutOfStock)
                _buildOutOfStockButton(compact)
              else
                _buildQuantityControls(product, qty, canAdd, compact),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE PLACEHOLDER
  // ============================================================

  Widget _buildImagePlaceholder(bool isOutOfStock, bool compact) {
    return Center(
      child: Icon(
        Icons.inventory_2_outlined,
        size: compact ? 24 : 32,
        color: isOutOfStock
            ? AppColors.textMuted
            : AppColors.primary.withValues(alpha: 0.55),
      ),
    );
  }

  // ============================================================
  // CART QUANTITY BADGE
  // ============================================================

  Widget _buildCartQuantityBadge(int quantity, bool compact) {
    return Container(
      constraints: BoxConstraints(
        minWidth: compact ? 20 : 24,
        minHeight: compact ? 20 : 24,
      ),

      padding: EdgeInsets.symmetric(horizontal: compact ? 5 : 6),

      decoration: BoxDecoration(
        color: AppColors.primary,

        borderRadius: BorderRadius.circular(compact ? 6 : 8),
      ),

      child: Center(
        child: Text(
          '$quantity',

          style: TextStyle(
            color: Colors.white,
            fontSize: compact ? 9 : 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STOCK BADGE
  // ============================================================

  Widget _buildStockBadge(int stock, bool compact) {
    final horizontal = compact ? 4.0 : 6.0;

    final vertical = compact ? 3.0 : 4.0;

    if (stock <= 0) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontal,
          vertical: vertical,
        ),

        decoration: BoxDecoration(
          color: AppColors.dangerLight,
          borderRadius: BorderRadius.circular(AppRadius.round),
        ),

        child: Text(
          'OUT',
          style: TextStyle(
            color: AppColors.danger,
            fontSize: compact ? 7 : 8,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    if (stock <= 5) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontal,
          vertical: vertical,
        ),

        decoration: BoxDecoration(
          color: AppColors.warningLight,
          borderRadius: BorderRadius.circular(AppRadius.round),
        ),

        child: Text(
          '$stock',
          style: TextStyle(
            color: AppColors.warning,
            fontSize: compact ? 7 : 8,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),

      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(AppRadius.round),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, size: compact ? 8 : 9, color: AppColors.success),

          SizedBox(width: compact ? 2 : 3),

          Text(
            '$stock',
            style: TextStyle(
              color: AppColors.success,
              fontSize: compact ? 7 : 8,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUANTITY CONTROLS
  // ============================================================

  Widget _buildQuantityControls(
    dynamic product,
    int qty,
    bool canAdd,
    bool compact,
  ) {
    final height = compact ? 28.0 : 34.0;

    final iconSize = compact ? 15.0 : 17.0;

    return Container(
      height: height,

      decoration: BoxDecoration(
        color: qty > 0 ? AppColors.primaryLight : AppColors.surfaceSoft,

        borderRadius: BorderRadius.circular(
          compact ? AppRadius.sm : AppRadius.md,
        ),

        border: Border.all(
          color: qty > 0
              ? AppColors.primary.withValues(alpha: 0.25)
              : AppColors.border,
          width: 0.8,
        ),
      ),

      child: Row(
        children: [
          // ------------------------------------------------------
          // REMOVE
          // ------------------------------------------------------
          SizedBox(
            width: compact ? 28 : 34,
            height: height,

            child: IconButton(
              padding: EdgeInsets.zero,

              constraints: const BoxConstraints(),

              splashRadius: compact ? 13 : 16,

              tooltip: 'Remove item',

              iconSize: iconSize,

              color: qty > 0 ? AppColors.danger : AppColors.textMuted,

              onPressed: qty > 0 ? () => _removeFromCart(product) : null,

              icon: const Icon(Icons.remove_rounded),
            ),
          ),

          // ------------------------------------------------------
          // QUANTITY
          // ------------------------------------------------------
          Expanded(
            child: Center(
              child: Text(
                '$qty',

                style: AppTextStyles.body.copyWith(
                  fontSize: compact ? 10 : 12,
                  fontWeight: FontWeight.w800,
                  color: qty > 0 ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ),
          ),

          // ------------------------------------------------------
          // ADD
          // ------------------------------------------------------
          SizedBox(
            width: compact ? 28 : 34,
            height: height,

            child: IconButton(
              padding: EdgeInsets.zero,

              constraints: const BoxConstraints(),

              splashRadius: compact ? 13 : 16,

              tooltip: canAdd ? 'Add item' : 'Maximum stock reached',

              iconSize: iconSize,

              color: canAdd ? AppColors.primary : AppColors.textMuted,

              onPressed: canAdd ? () => _addToCart(product) : null,

              icon: const Icon(Icons.add_rounded),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // OUT OF STOCK
  // ============================================================

  Widget _buildOutOfStockButton(bool compact) {
    return Container(
      height: compact ? 28 : 34,

      width: double.infinity,

      decoration: BoxDecoration(
        color: AppColors.dangerLight,

        borderRadius: BorderRadius.circular(
          compact ? AppRadius.sm : AppRadius.md,
        ),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(
            Icons.block_outlined,
            size: compact ? 12 : 14,
            color: AppColors.danger,
          ),

          SizedBox(width: compact ? 3 : 5),

          Text(
            'Out of stock',
            style: TextStyle(
              color: AppColors.danger,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 8 : 10,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ADD TO CART
  //
  // SALE PROCESSING LOGIC PRESERVED
  // ============================================================

  void _addToCart(dynamic product) {
    final currentQty = widget.cart[product.id] ?? 0;

    // Never allow quantity to exceed stock.
    if (currentQty >= product.stock) {
      return;
    }

    widget.cart[product.id] = currentQty + 1;

    widget.onCartUpdated();

    setState(() {});
  }

  // ============================================================
  // REMOVE FROM CART
  //
  // SALE PROCESSING LOGIC PRESERVED
  // ============================================================

  void _removeFromCart(dynamic product) {
    final currentQty = widget.cart[product.id] ?? 0;

    if (currentQty <= 1) {
      widget.cart.remove(product.id);
    } else {
      widget.cart[product.id] = currentQty - 1;
    }

    widget.onCartUpdated();

    setState(() {});
  }

  // ============================================================
  // CART INDICATOR
  // ============================================================

  Widget _buildCartIndicator({required bool compact}) {
    final totalItems = widget.cart.values.fold(
      0,
      (sum, quantity) => sum + quantity,
    );

    return Container(
      height: compact ? 36 : 40,

      padding: EdgeInsets.symmetric(horizontal: compact ? 9 : 11),

      decoration: BoxDecoration(
        color: totalItems > 0 ? AppColors.primary : AppColors.primaryLight,

        borderRadius: BorderRadius.circular(
          compact ? AppRadius.md : AppRadius.lg,
        ),

        boxShadow: totalItems > 0
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: compact ? 17 : 19,
            color: totalItems > 0 ? Colors.white : AppColors.primary,
          ),

          SizedBox(width: compact ? 4 : 6),

          Text(
            '$totalItems',
            style: TextStyle(
              fontSize: compact ? 11 : 13,
              fontWeight: FontWeight.w800,
              color: totalItems > 0 ? Colors.white : AppColors.primary,
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
    final bool isSearching = _searchQuery.isNotEmpty;

    final responsive = context.responsive;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(
          responsive.isCompact ? AppSpacing.xl : AppSpacing.huge,
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Container(
              width: responsive.isCompact ? 72 : 90,
              height: responsive.isCompact ? 72 : 90,

              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),

              child: Icon(
                isSearching
                    ? Icons.search_off_rounded
                    : Icons.inventory_2_outlined,
                size: responsive.isCompact ? 32 : 42,
                color: AppColors.primary,
              ),
            ),

            SizedBox(
              height: responsive.isCompact ? AppSpacing.md : AppSpacing.xl,
            ),

            Text(
              isSearching ? 'No products found' : 'No products available',

              style: AppTextStyles.heading.copyWith(
                fontSize: responsive.isCompact ? 18 : 22,
              ),
            ),

            const SizedBox(height: AppSpacing.xs),

            Text(
              isSearching
                  ? 'Try a different product name or clear the search.'
                  : 'There are currently no products in ${widget.category.name}.',

              textAlign: TextAlign.center,

              style: AppTextStyles.bodySecondary.copyWith(
                fontSize: responsive.isCompact ? 12 : 14,
              ),
            ),

            if (isSearching) ...[
              const SizedBox(height: AppSpacing.md),

              OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                },

                icon: const Icon(Icons.clear, size: 17),

                label: const Text('Clear search'),

                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(130, 40),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MONEY FORMAT
  // ============================================================

  String _formatMoney(num value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
  }
}
