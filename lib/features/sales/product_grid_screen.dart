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

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_handleSearchChanged);
  }

  void _handleSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();

    if (_searchQuery == query) {
      return;
    }

    setState(() {
      _searchQuery = query;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChanged);
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
      final barcode = product.barcode?.toString().toLowerCase() ?? '';

      return name.contains(_searchQuery) || barcode.contains(_searchQuery);
    }).toList();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final products = _filteredProducts;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(responsive),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // ----------------------------------------------------
            // SEARCH
            // ----------------------------------------------------
            _buildSearchSection(responsive),

            // ----------------------------------------------------
            // PRODUCT GRID
            // ----------------------------------------------------
            Expanded(
              child: products.isEmpty
                  ? _buildEmptyState(responsive)
                  : _buildProductGrid(products, responsive),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar(Responsive responsive) {
    final compact = responsive.isCompact;

    final toolbarHeight = compact ? 50.0 : 56.0;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      automaticallyImplyLeading: true,
      toolbarHeight: toolbarHeight,
      titleSpacing: compact ? 8 : 12,
      centerTitle: false,
      title: Row(
        children: [
          // ----------------------------------------------------
          // CATEGORY ICON
          // ----------------------------------------------------
          Container(
            width: compact ? 30 : 34,
            height: compact ? 30 : 34,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(
                compact ? AppRadius.sm : AppRadius.md,
              ),
            ),
            child: Icon(
              Icons.category_outlined,
              color: AppColors.primary,
              size: compact ? 16 : 18,
            ),
          ),

          SizedBox(width: compact ? 7 : 9),

          // ----------------------------------------------------
          // CATEGORY NAME
          // ----------------------------------------------------
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.heading.copyWith(
                    fontSize: compact ? 13 : 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                if (!compact)
                  Text(
                    '${widget.products.length} product'
                    '${widget.products.length == 1 ? '' : 's'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.small.copyWith(
                      fontSize: 9,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),

          // ----------------------------------------------------
          // CART
          // ----------------------------------------------------
          _buildCartIndicator(compact: compact),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH SECTION
  // ============================================================

  Widget _buildSearchSection(Responsive responsive) {
    final compact = responsive.isCompact;

    return Container(
      color: AppColors.background,
      padding: EdgeInsets.fromLTRB(
        compact ? AppSpacing.sm : AppSpacing.md,
        compact ? 5 : AppSpacing.sm,
        compact ? AppSpacing.sm : AppSpacing.md,
        compact ? 4 : AppSpacing.sm,
      ),
      child: SizedBox(
        height: compact ? 38 : 42,
        child: _buildSearchField(compact: compact),
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
        fontSize: compact ? 11 : 12,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: 'Search products or scan barcode...',
        hintStyle: AppTextStyles.small.copyWith(
          fontSize: compact ? 9 : 10,
          color: AppColors.textMuted,
        ),
        prefixIcon: Icon(
          Icons.search,
          size: compact ? 17 : 18,
          color: AppColors.textSecondary,
        ),
        prefixIconConstraints: BoxConstraints(
          minWidth: compact ? 36 : 40,
          minHeight: compact ? 36 : 40,
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                tooltip: 'Clear search',
                padding: EdgeInsets.zero,
                iconSize: compact ? 16 : 17,
                onPressed: _searchController.clear,
                icon: const Icon(Icons.close),
              )
            : null,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10,
          vertical: 4,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            compact ? AppRadius.md : AppRadius.lg,
          ),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            compact ? AppRadius.md : AppRadius.lg,
          ),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            compact ? AppRadius.md : AppRadius.lg,
          ),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.1),
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
        // COLUMN COUNT
        //
        // Based on actual available width.
        //
        // 800px tablet:
        // approximately 4 columns
        //
        // Larger tablet:
        // 5 columns
        //
        // Desktop:
        // 6-8 columns
        // --------------------------------------------------------

        int columns;

        if (width < 420) {
          columns = 2;
        } else if (width < 650) {
          columns = 3;
        } else if (width < 900) {
          columns = 4;
        } else if (width < 1200) {
          columns = 5;
        } else if (width < 1500) {
          columns = 6;
        } else {
          columns = 7;
        }

        // --------------------------------------------------------
        // COMPACT GRID SPACING
        // --------------------------------------------------------

        final compact = responsive.isCompact;

        final horizontalPadding = compact ? 7.0 : 10.0;

        final horizontalSpacing = width < 700 ? 5.0 : 7.0;

        final verticalSpacing = width < 700 ? 5.0 : 7.0;

        final availableWidth =
            width -
            (horizontalPadding * 2) -
            (horizontalSpacing * (columns - 1));

        final cardWidth = availableWidth / columns;

        // --------------------------------------------------------
        // CONTROLLED CARD HEIGHT
        //
        // Avoid a large square card on tablets.
        // --------------------------------------------------------

        double cardHeight;

        if (width < 420) {
          cardHeight = 142;
        } else if (width < 650) {
          cardHeight = 148;
        } else if (width < 900) {
          cardHeight = 154;
        } else if (width < 1200) {
          cardHeight = 160;
        } else {
          cardHeight = 166;
        }

        return GridView.builder(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            2,
            horizontalPadding,
            compact ? 10 : 16,
          ),
          physics: const ClampingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: horizontalSpacing,
            mainAxisSpacing: verticalSpacing,
            mainAxisExtent: cardHeight,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];

            return _buildProductCard(context, product, responsive, cardWidth);
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
    double cardWidth,
  ) {
    final compact = responsive.isCompact;

    final qty = widget.cart[product.id] ?? 0;

    final stock = product.stock;

    final isOutOfStock = stock <= 0;

    final canAdd = qty < stock;

    final isInCart = qty > 0;

    // ----------------------------------------------------------
    // IMAGE HEIGHT
    //
    // Smaller cards receive smaller image areas.
    // ----------------------------------------------------------

    double imageHeight;

    if (cardWidth < 130) {
      imageHeight = 58;
    } else if (cardWidth < 170) {
      imageHeight = 64;
    } else if (cardWidth < 220) {
      imageHeight = 70;
    } else {
      imageHeight = 76;
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(
        compact ? AppRadius.md : AppRadius.lg,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(
          compact ? AppRadius.md : AppRadius.lg,
        ),
        onTap: isOutOfStock ? null : () => _addToCart(product),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: EdgeInsets.all(compact ? 5 : 7),
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
              width: isInCart ? 1.1 : 0.7,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // IMAGE
              // ==================================================
              SizedBox(
                height: imageHeight,
                width: double.infinity,
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
                    // STOCK
                    // ------------------------------------------------
                    Positioned(
                      top: 3,
                      right: 3,
                      child: _buildStockBadge(stock, compact),
                    ),

                    // ------------------------------------------------
                    // CART QUANTITY
                    // ------------------------------------------------
                    if (isInCart)
                      Positioned(
                        top: 3,
                        left: 3,
                        child: _buildCartQuantityBadge(qty, compact),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // ==================================================
              // NAME
              // ==================================================
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  fontSize: compact ? 9 : 10,
                  height: 1.05,
                  fontWeight: FontWeight.w700,
                  color: AppColors.productText,
                ),
              ),

              const SizedBox(height: 2),

              // ==================================================
              // PRICE
              // ==================================================
              Text(
                '₦${_formatMoney(product.sellingPrice)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.price.copyWith(
                  fontSize: compact ? 10 : 11,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),

              const Spacer(),

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
        size: compact ? 21 : 25,
        color: isOutOfStock
            ? AppColors.textMuted
            : AppColors.primary.withValues(alpha: 0.50),
      ),
    );
  }

  // ============================================================
  // CART QUANTITY BADGE
  // ============================================================

  Widget _buildCartQuantityBadge(int quantity, bool compact) {
    return Container(
      constraints: BoxConstraints(
        minWidth: compact ? 18 : 20,
        minHeight: compact ? 18 : 20,
      ),
      padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 5),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(compact ? 5 : 6),
      ),
      child: Center(
        child: Text(
          '$quantity',
          style: TextStyle(
            color: Colors.white,
            fontSize: compact ? 8 : 9,
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
    final horizontal = compact ? 4.0 : 5.0;

    final vertical = compact ? 2.0 : 3.0;

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
            fontSize: compact ? 6 : 7,
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
            fontSize: compact ? 6 : 7,
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
      child: Text(
        '$stock',
        style: TextStyle(
          color: AppColors.success,
          fontSize: compact ? 6 : 7,
          fontWeight: FontWeight.w800,
        ),
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
    final height = compact ? 25.0 : 28.0;

    final buttonWidth = compact ? 25.0 : 29.0;

    final iconSize = compact ? 13.0 : 14.0;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: qty > 0 ? AppColors.primaryLight : AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(
            compact ? AppRadius.sm : AppRadius.md,
          ),
          border: Border.all(
            color: qty > 0
                ? AppColors.primary.withValues(alpha: 0.25)
                : AppColors.border,
            width: 0.7,
          ),
        ),
        child: Row(
          children: [
            // --------------------------------------------------
            // REMOVE
            // --------------------------------------------------
            SizedBox(
              width: buttonWidth,
              height: height,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashRadius: compact ? 11 : 13,
                tooltip: 'Remove item',
                iconSize: iconSize,
                color: qty > 0 ? AppColors.danger : AppColors.textMuted,
                onPressed: qty > 0 ? () => _removeFromCart(product) : null,
                icon: const Icon(Icons.remove_rounded),
              ),
            ),

            // --------------------------------------------------
            // QUANTITY
            // --------------------------------------------------
            Expanded(
              child: Center(
                child: Text(
                  '$qty',
                  style: AppTextStyles.body.copyWith(
                    fontSize: compact ? 9 : 10,
                    fontWeight: FontWeight.w800,
                    color: qty > 0
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),

            // --------------------------------------------------
            // ADD
            // --------------------------------------------------
            SizedBox(
              width: buttonWidth,
              height: height,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashRadius: compact ? 11 : 13,
                tooltip: canAdd ? 'Add item' : 'Maximum stock reached',
                iconSize: iconSize,
                color: canAdd ? AppColors.primary : AppColors.textMuted,
                onPressed: canAdd ? () => _addToCart(product) : null,
                icon: const Icon(Icons.add_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // OUT OF STOCK
  // ============================================================

  Widget _buildOutOfStockButton(bool compact) {
    return Container(
      height: compact ? 25 : 28,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.dangerLight,
        borderRadius: BorderRadius.circular(
          compact ? AppRadius.sm : AppRadius.md,
        ),
      ),
      child: Center(
        child: Text(
          'Out of stock',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.danger,
            fontWeight: FontWeight.w700,
            fontSize: compact ? 7 : 8,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ADD TO CART
  // ============================================================

  void _addToCart(dynamic product) {
    final currentQty = widget.cart[product.id] ?? 0;

    if (currentQty >= product.stock) {
      return;
    }

    widget.cart[product.id] = currentQty + 1;

    widget.onCartUpdated();

    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // REMOVE FROM CART
  // ============================================================

  void _removeFromCart(dynamic product) {
    final currentQty = widget.cart[product.id] ?? 0;

    if (currentQty <= 1) {
      widget.cart.remove(product.id);
    } else {
      widget.cart[product.id] = currentQty - 1;
    }

    widget.onCartUpdated();

    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // CART INDICATOR
  // ============================================================

  Widget _buildCartIndicator({required bool compact}) {
    final totalItems = widget.cart.values.fold<int>(
      0,
      (sum, quantity) => sum + quantity,
    );

    return Container(
      height: compact ? 32 : 34,
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 9),
      decoration: BoxDecoration(
        color: totalItems > 0 ? AppColors.primary : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(
          compact ? AppRadius.md : AppRadius.lg,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: compact ? 15 : 16,
            color: totalItems > 0 ? Colors.white : AppColors.primary,
          ),
          SizedBox(width: compact ? 3 : 4),
          Text(
            '$totalItems',
            style: TextStyle(
              fontSize: compact ? 10 : 11,
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

  Widget _buildEmptyState(Responsive responsive) {
    final compact = responsive.isCompact;

    final isSearching = _searchQuery.isNotEmpty;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(compact ? AppSpacing.xl : AppSpacing.huge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: compact ? 58 : 72,
              height: compact ? 58 : 72,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearching
                    ? Icons.search_off_rounded
                    : Icons.inventory_2_outlined,
                size: compact ? 27 : 34,
                color: AppColors.primary,
              ),
            ),

            SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),

            Text(
              isSearching ? 'No products found' : 'No products available',
              style: AppTextStyles.heading.copyWith(
                fontSize: compact ? 15 : 18,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 3),

            Text(
              isSearching
                  ? 'Try another product name or barcode.'
                  : 'There are currently no products in '
                        '${widget.category.name}.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary.copyWith(
                fontSize: compact ? 10 : 12,
              ),
            ),

            if (isSearching) ...[
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: _searchController.clear,
                icon: const Icon(Icons.clear, size: 15),
                label: const Text('Clear search'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(110, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
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
  // MONEY
  // ============================================================

  String _formatMoney(num value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
  }
}
