// lib/features/sales/product_grid_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/theme/styles.dart';
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
  State<ProductGridScreen> createState() =>
      _ProductGridScreenState();
}

class _ProductGridScreenState extends State<ProductGridScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchQuery =
            _searchController.text.trim().toLowerCase();
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
      final name =
          product.name.toString().toLowerCase();

      return name.contains(_searchQuery);
    }).toList();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;

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

        toolbarHeight: 72,

        titleSpacing: 16,

        title: Row(
          children: [
            // ----------------------------------------------------
            // CATEGORY ICON
            // ----------------------------------------------------

            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius:
                    BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.category_outlined,
                color: AppColors.primary,
                size: 24,
              ),
            ),

            const SizedBox(width: 14),

            // ----------------------------------------------------
            // CATEGORY TITLE
            // ----------------------------------------------------

            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.category.name,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        AppTextStyles.title.copyWith(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    '${widget.products.length} product${widget.products.length == 1 ? '' : 's'}',
                    style:
                        AppTextStyles.small.copyWith(
                      color:
                          AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // ----------------------------------------------------
            // SEARCH
            // ----------------------------------------------------

            SizedBox(
              width: 280,
              height: 46,
              child: TextField(
                controller: _searchController,
                textInputAction:
                    TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search products',
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 21,
                  ),
                  suffixIcon:
                      _searchQuery.isNotEmpty
                          ? IconButton(
                              tooltip: 'Clear search',
                              onPressed: () {
                                _searchController.clear();
                              },
                              icon: const Icon(
                                Icons.close,
                                size: 19,
                              ),
                            )
                          : null,
                  filled: true,
                  fillColor:
                      AppColors.surfaceSoft,
                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                    borderSide:
                        BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // ----------------------------------------------------
            // CART
            // ----------------------------------------------------

            _buildCartIndicator(),
          ],
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: products.isEmpty
          ? _buildEmptyState()
          : _buildProductGrid(products),
    );
  }

  // ============================================================
  // PRODUCT GRID
  // ============================================================

  Widget _buildProductGrid(
    List<dynamic> products,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        int columns;

        /*
         * iPad-first layout.
         *
         * Typical iPad landscape:
         * 1024 → 4 columns
         *
         * Larger iPad / desktop:
         * 1150+ → 5 columns
         * 1400+ → 6 columns
         */

        if (width >= 1500) {
          columns = 6;
        } else if (width >= 1200) {
          columns = 5;
        } else if (width >= 900) {
          columns = 4;
        } else if (width >= 650) {
          columns = 3;
        } else {
          columns = 2;
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(
            18,
            18,
            18,
            110,
          ),

          physics:
              const BouncingScrollPhysics(),

          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,

            crossAxisSpacing: 14,

            mainAxisSpacing: 14,

            /*
             * Cards are intentionally slightly taller
             * than the old version.
             *
             * This gives the product image and controls
             * enough space on iPad.
             */
            childAspectRatio:
                columns >= 5
                    ? 1.02
                    : columns == 4
                        ? 0.92
                        : 0.86,
          ),

          itemCount: products.length,

          itemBuilder: (context, index) {
            final product = products[index];

            return _buildProductCard(
              context,
              product,
            );
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
  ) {
    final qty =
        widget.cart[product.id] ?? 0;

    final stock = product.stock;

    final bool isOutOfStock =
        stock <= 0;

    final bool canAdd =
        qty < stock;

    final bool isInCart =
        qty > 0;

    return Material(
      color: AppColors.surface,

      borderRadius:
          BorderRadius.circular(16),

      child: InkWell(
        borderRadius:
            BorderRadius.circular(16),

        onTap: isOutOfStock
            ? null
            : () => _addToCart(product),

        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 160),

          decoration: BoxDecoration(
            color: isInCart
                ? AppColors.primaryLight
                    .withValues(alpha: 0.45)
                : AppColors.surface,

            borderRadius:
                BorderRadius.circular(16),

            border: Border.all(
              color: isInCart
                  ? AppColors.primary
                      .withValues(alpha: 0.55)
                  : AppColors.border,
              width: isInCart ? 1.5 : 1,
            ),

            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withValues(
                  alpha: 0.035,
                ),
                blurRadius: 8,
                offset:
                    const Offset(0, 3),
              ),
            ],
          ),

          child: Padding(
            padding:
                const EdgeInsets.all(11),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

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
                          decoration:
                              BoxDecoration(
                            color:
                                AppColors.surfaceSoft,
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                          ),

                          child:
                              ClipRRect(
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),

                            child:
                                product.imagePath !=
                                            null &&
                                        product
                                            .imagePath!
                                            .isNotEmpty
                                    ? Image.file(
                                        File(
                                          product
                                              .imagePath!,
                                        ),

                                        fit:
                                            BoxFit.contain,

                                        errorBuilder:
                                            (
                                          _,
                                          __,
                                          ___,
                                        ) {
                                          return _buildImagePlaceholder(
                                            isOutOfStock,
                                          );
                                        },
                                      )
                                    : _buildImagePlaceholder(
                                        isOutOfStock,
                                      ),
                          ),
                        ),
                      ),

                      // ==================================================
                      // STOCK BADGE
                      // ==================================================

                      Positioned(
                        top: 8,
                        right: 8,
                        child:
                            _buildStockBadge(
                          stock,
                        ),
                      ),

                      // ==================================================
                      // CART QUANTITY BADGE
                      // ==================================================

                      if (isInCart)
                        Positioned(
                          top: 8,
                          left: 8,
                          child:
                              _buildCartQuantityBadge(
                            qty,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // ==================================================
                // PRODUCT NAME
                // ==================================================

                Text(
                  product.name,

                  maxLines: 2,

                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      AppTextStyles.body.copyWith(
                    fontSize: 14,
                    height: 1.2,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 5),

                // ==================================================
                // PRICE
                // ==================================================

                Text(
                  '₦${_formatMoney(product.sellingPrice)}',

                  maxLines: 1,

                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      AppTextStyles.price.copyWith(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        AppColors.primary,
                  ),
                ),

                const SizedBox(height: 9),

                // ==================================================
                // QUANTITY CONTROLS
                // ==================================================

                if (isOutOfStock)
                  _buildOutOfStockButton()
                else
                  _buildQuantityControls(
                    product,
                    qty,
                    canAdd,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE PLACEHOLDER
  // ============================================================

  Widget _buildImagePlaceholder(
    bool isOutOfStock,
  ) {
    return Center(
      child: Icon(
        Icons.inventory_2_outlined,
        size: 42,
        color: isOutOfStock
            ? AppColors.textMuted
            : AppColors.primary
                .withValues(alpha: 0.65),
      ),
    );
  }

  // ============================================================
  // CART QUANTITY BADGE
  // ============================================================

  Widget _buildCartQuantityBadge(
    int quantity,
  ) {
    return Container(
      constraints:
          const BoxConstraints(
        minWidth: 30,
        minHeight: 30,
      ),

      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
      ),

      decoration: BoxDecoration(
        color: AppColors.primary,

        borderRadius:
            BorderRadius.circular(10),

        boxShadow: [
          BoxShadow(
            color:
                AppColors.primary.withValues(
              alpha: 0.25,
            ),
            blurRadius: 6,
          ),
        ],
      ),

      child: Center(
        child: Text(
          '$quantity',

          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STOCK BADGE
  // ============================================================

  Widget _buildStockBadge(
    int stock,
  ) {
    if (stock <= 0) {
      return Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 6,
        ),

        decoration: BoxDecoration(
          color: AppColors.dangerLight,

          borderRadius:
              BorderRadius.circular(20),
        ),

        child: const Text(
          'OUT OF STOCK',

          style: TextStyle(
            color: AppColors.danger,
            fontSize: 9,
            fontWeight:
                FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      );
    }

    if (stock <= 5) {
      return Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 6,
        ),

        decoration: BoxDecoration(
          color: AppColors.warningLight,

          borderRadius:
              BorderRadius.circular(20),
        ),

        child: Text(
          '$stock LEFT',

          style: const TextStyle(
            color: AppColors.warning,
            fontSize: 9,
            fontWeight:
                FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      );
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),

      decoration: BoxDecoration(
        color: AppColors.successLight,

        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Row(
        mainAxisSize:
            MainAxisSize.min,

        children: [
          const Icon(
            Icons.check_circle,
            size: 12,
            color: AppColors.success,
          ),

          const SizedBox(width: 4),

          Text(
            '$stock',

            style: const TextStyle(
              color:
                  AppColors.success,
              fontSize: 9,
              fontWeight:
                  FontWeight.w800,
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
  ) {
    return Container(
      height: 46,

      decoration: BoxDecoration(
        color: qty > 0
            ? AppColors.primaryLight
            : AppColors.surfaceSoft,

        borderRadius:
            BorderRadius.circular(12),

        border: Border.all(
          color: qty > 0
              ? AppColors.primary
                  .withValues(alpha: 0.25)
              : AppColors.border,
        ),
      ),

      child: Row(
        children: [
          // ==================================================
          // REMOVE
          // ==================================================

          SizedBox(
            width: 46,
            height: 46,

            child: IconButton(
              padding:
                  EdgeInsets.zero,

              tooltip: 'Remove item',

              iconSize: 21,

              color: qty > 0
                  ? AppColors.danger
                  : AppColors.textMuted,

              onPressed: qty > 0
                  ? () =>
                      _removeFromCart(
                        product,
                      )
                  : null,

              icon: const Icon(
                Icons.remove_rounded,
              ),
            ),
          ),

          // ==================================================
          // QUANTITY
          // ==================================================

          Expanded(
            child: Center(
              child: Text(
                '$qty',

                style:
                    AppTextStyles.body
                        .copyWith(
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w800,
                  color: qty > 0
                      ? AppColors.primary
                      : AppColors
                          .textSecondary,
                ),
              ),
            ),
          ),

          // ==================================================
          // ADD
          // ==================================================

          SizedBox(
            width: 46,
            height: 46,

            child: IconButton(
              padding:
                  EdgeInsets.zero,

              tooltip: canAdd
                  ? 'Add item'
                  : 'Maximum stock reached',

              iconSize: 21,

              color: canAdd
                  ? AppColors.primary
                  : AppColors.textMuted,

              onPressed: canAdd
                  ? () =>
                      _addToCart(product)
                  : null,

              icon: const Icon(
                Icons.add_rounded,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // OUT OF STOCK
  // ============================================================

  Widget _buildOutOfStockButton() {
    return Container(
      height: 46,

      width: double.infinity,

      decoration: BoxDecoration(
        color:
            AppColors.dangerLight,

        borderRadius:
            BorderRadius.circular(12),
      ),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          const Icon(
            Icons.block_outlined,
            size: 17,
            color:
                AppColors.danger,
          ),

          const SizedBox(width: 7),

          const Text(
            'Out of stock',

            style: TextStyle(
              color:
                  AppColors.danger,
              fontWeight:
                  FontWeight.w700,
              fontSize: 12,
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

  void _addToCart(
    dynamic product,
  ) {
    final currentQty =
        widget.cart[product.id] ?? 0;

    // Never allow quantity to exceed stock.
    if (currentQty >= product.stock) {
      return;
    }

    widget.cart[product.id] =
        currentQty + 1;

    widget.onCartUpdated();

    setState(() {});
  }

  // ============================================================
  // REMOVE FROM CART
  //
  // SALE PROCESSING LOGIC PRESERVED
  // ============================================================

  void _removeFromCart(
    dynamic product,
  ) {
    final currentQty =
        widget.cart[product.id] ?? 0;

    if (currentQty <= 1) {
      widget.cart.remove(product.id);
    } else {
      widget.cart[product.id] =
          currentQty - 1;
    }

    widget.onCartUpdated();

    setState(() {});
  }

  // ============================================================
  // CART INDICATOR
  // ============================================================

  Widget _buildCartIndicator() {
    final totalItems =
        widget.cart.values.fold(
      0,
      (sum, quantity) =>
          sum + quantity,
    );

    return Container(
      height: 46,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
      ),

      decoration: BoxDecoration(
        color: totalItems > 0
            ? AppColors.primary
            : AppColors.primaryLight,

        borderRadius:
            BorderRadius.circular(13),

        boxShadow: totalItems > 0
            ? [
                BoxShadow(
                  color: AppColors.primary
                      .withValues(
                    alpha: 0.20,
                  ),
                  blurRadius: 8,
                  offset:
                      const Offset(0, 3),
                ),
              ]
            : null,
      ),

      child: Row(
        mainAxisSize:
            MainAxisSize.min,

        children: [
          Icon(
            Icons.shopping_cart_outlined,

            size: 21,

            color: totalItems > 0
                ? Colors.white
                : AppColors.primary,
          ),

          const SizedBox(width: 7),

          Text(
            '$totalItems',

            style: TextStyle(
              fontSize: 14,
              fontWeight:
                  FontWeight.w800,
              color: totalItems > 0
                  ? Colors.white
                  : AppColors.primary,
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
    final bool isSearching =
        _searchQuery.isNotEmpty;

    return Center(
      child: SingleChildScrollView(
        padding:
            const EdgeInsets.all(40),

        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            Container(
              width: 100,
              height: 100,

              decoration:
                  const BoxDecoration(
                color:
                    AppColors.primaryLight,
                shape:
                    BoxShape.circle,
              ),

              child: Icon(
                isSearching
                    ? Icons.search_off_rounded
                    : Icons.inventory_2_outlined,

                size: 46,

                color:
                    AppColors.primary,
              ),
            ),

            const SizedBox(height: 22),

            Text(
              isSearching
                  ? 'No products found'
                  : 'No products available',

              style:
                  AppTextStyles.heading.copyWith(
                fontSize: 22,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              isSearching
                  ? 'Try a different product name or clear the search.'
                  : 'There are currently no products in ${widget.category.name}.',

              textAlign:
                  TextAlign.center,

              style:
                  AppTextStyles.bodySecondary.copyWith(
                fontSize: 14,
              ),
            ),

            if (isSearching) ...[
              const SizedBox(height: 18),

              OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                },

                icon: const Icon(
                  Icons.clear,
                ),

                label: const Text(
                  'Clear search',
                ),

                style:
                    OutlinedButton.styleFrom(
                  minimumSize:
                      const Size(
                    140,
                    46,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
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

  String _formatMoney(
    num value,
  ) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(
            r'\B(?=(\d{3})+(?!\d))',
          ),
          (match) => ',',
        );
  }
}