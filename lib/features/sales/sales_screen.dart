// lib/features/sales/sales_screen.dart

import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import 'package:supermarket_inventory/core/widgets/back_button.dart';

import '../../core/session.dart';
import '../../core/theme/styles.dart';
import '../../core/responsive/responsive.dart';
import '../../core/business/business_identity.dart';
import '../../core/pos/pos_settings_service.dart';

import '../../database/app_database.dart';
import '../../database/daos/settings_dao.dart';
import '../../database/daos/sales_dao.dart';
import '../../database/daos/product_dao.dart';
import '../../database/daos/category_dao.dart';

import '../../models/pos_settings.dart';

import 'payment_selector.dart';
import 'receipt_widget.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final db = getDatabase();

  late final SalesDao salesDao;
  late final ProductDao productDao;
  late final CategoryDao categoryDao;
  late final SettingsDao settingsDao;

  List<Category> categories = [];
  List<Product> products = [];

  /// productId -> quantity
  final Map<int, int> cart = {};

  String paymentMethod = 'cash';

  PosSettings? _posSettings;

  bool _loadingPosSettings = true;
  bool _processingSale = false;

  String _searchQuery = '';

  int? _selectedCategoryId;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    salesDao = SalesDao(db);
    productDao = ProductDao(db);
    categoryDao = CategoryDao(db);
    settingsDao = SettingsDao(db);

    _loadPosSettings();
    _loadCategories();
    _loadProducts();
  }

  // ============================================================
  // POS SETTINGS
  // ============================================================

  Future<void> _loadPosSettings() async {
    try {
      final service = PosSettingsService(settingsDao: settingsDao);

      final settings = await service.load();

      if (!mounted) return;

      setState(() {
        _posSettings = settings;
        paymentMethod = settings.safeDefaultPaymentMethod;
        _loadingPosSettings = false;
      });
    } catch (e) {
      if (!mounted) return;

      const fallbackSettings = PosSettings();

      setState(() {
        _posSettings = fallbackSettings;
        paymentMethod = fallbackSettings.safeDefaultPaymentMethod;
        _loadingPosSettings = false;
      });

      _showMessage(
        'Could not load POS settings. Using defaults.',
        isError: true,
      );
    }
  }

  // ============================================================
  // PAYMENT HELPERS
  // ============================================================

  bool _isPaymentMethodEnabled(String method) {
    final settings = _posSettings;

    if (settings == null) return false;

    return settings.isPaymentMethodEnabled(method);
  }

  String _getSafePaymentMethod() {
    final settings = _posSettings;

    if (settings == null) return 'cash';

    return settings.safeDefaultPaymentMethod;
  }

  String _normalizePaymentMethod(String? value) {
    final method = value?.trim().toLowerCase() ?? '';

    switch (method) {
      case 'cash':
        return 'cash';

      case 'pos':
        return 'pos';

      case 'transfer':
      case 'bank transfer':
        return 'transfer';

      case 'split':
        return 'split';

      default:
        return 'cash';
    }
  }

  String _formatPaymentMethodName(String value) {
    switch (value.trim().toLowerCase()) {
      case 'cash':
        return 'Cash';

      case 'pos':
        return 'POS';

      case 'transfer':
        return 'Transfer';

      case 'split':
        return 'Split';

      default:
        return value;
    }
  }

  // ============================================================
  // DATA
  // ============================================================

  Future<void> _loadCategories() async {
    final list = await categoryDao.getAllCategories();

    if (!mounted) return;

    setState(() {
      categories = list;
    });
  }

  Future<void> _loadProducts() async {
    final list = await productDao.getAllProducts();

    if (!mounted) return;

    setState(() {
      products = list;
    });
  }

  // ============================================================
  // TOTALS
  // ============================================================

  int get total {
    return cart.entries.fold<int>(0, (sum, entry) {
      final product = _findProduct(entry.key);

      if (product == null) return sum;

      return sum + (entry.value * product.sellingPrice.toInt());
    });
  }

  int get totalItems {
    return cart.values.fold<int>(0, (sum, quantity) => sum + quantity);
  }

  Product? _findProduct(int productId) {
    for (final product in products) {
      if (product.id == productId) {
        return product;
      }
    }

    return null;
  }

  // ============================================================
  // COMPLETE SALE
  // ============================================================

  Future<void> _completeSaleWithAmounts(
    double cashAmount,
    double posAmount,
    double transferAmount,
  ) async {
    if (_processingSale) return;

    if (_loadingPosSettings || _posSettings == null) {
      _showMessage('POS settings are still loading.', isError: true);
      return;
    }

    if (cart.isEmpty) {
      _showMessage('Cart is empty.', isError: true);
      return;
    }

    final currentUserEmail = Session.currentUserEmail;

    if (currentUserEmail == null || currentUserEmail.trim().isEmpty) {
      _showMessage('No logged-in staff found.', isError: true);
      return;
    }

    final normalizedPaymentMethod = _normalizePaymentMethod(paymentMethod);

    if (!_isPaymentMethodEnabled(normalizedPaymentMethod)) {
      _showMessage(
        '${_formatPaymentMethodName(normalizedPaymentMethod)} '
        'is disabled in POS settings.',
        isError: true,
      );

      setState(() {
        paymentMethod = _getSafePaymentMethod();
      });

      return;
    }

    if (normalizedPaymentMethod != 'cash' &&
        normalizedPaymentMethod != 'pos' &&
        normalizedPaymentMethod != 'transfer' &&
        normalizedPaymentMethod != 'split') {
      _showMessage(
        '${_formatPaymentMethodName(normalizedPaymentMethod)} '
        'is not currently supported.',
        isError: true,
      );
      return;
    }

    setState(() {
      _processingSale = true;
    });

    try {
      // ========================================================
      // 1. STAFF
      // ========================================================

      final staff = await getUserDao().getUserByEmail(currentUserEmail);

      if (staff == null) {
        throw Exception('No staff record found for the current session.');
      }

      // ========================================================
      // 2. TOTAL
      // ========================================================

      final cartTotal = total;

      if (cartTotal <= 0) {
        throw Exception('Sale total must be greater than zero.');
      }

      // ========================================================
      // 3. PAYMENT AMOUNTS
      // ========================================================

      final receivedCash = cashAmount < 0 ? 0.0 : cashAmount;
      final receivedPos = posAmount < 0 ? 0.0 : posAmount;
      final receivedTransfer = transferAmount < 0 ? 0.0 : transferAmount;

      // ========================================================
      // 4. VALIDATE PAYMENT
      // ========================================================

      if (normalizedPaymentMethod == 'cash') {
        if (receivedCash < cartTotal) {
          throw Exception(
            'Cash amount is not enough.\n'
            'Sale total: ₦${_formatMoney(cartTotal)}\n'
            'Cash received: ₦${_formatMoney(receivedCash)}',
          );
        }
      } else if (normalizedPaymentMethod == 'pos') {
        if ((receivedPos - cartTotal).abs() > 0.01) {
          throw Exception(
            'POS amount does not match sale total.\n'
            'Sale total: ₦${_formatMoney(cartTotal)}\n'
            'POS received: ₦${_formatMoney(receivedPos)}',
          );
        }
      } else if (normalizedPaymentMethod == 'transfer') {
        if ((receivedTransfer - cartTotal).abs() > 0.01) {
          throw Exception(
            'Transfer amount does not match sale total.\n'
            'Sale total: ₦${_formatMoney(cartTotal)}\n'
            'Transfer received: ₦${_formatMoney(receivedTransfer)}',
          );
        }
      } else if (normalizedPaymentMethod == 'split') {
        final paymentTotal = receivedCash + receivedPos + receivedTransfer;

        if ((paymentTotal - cartTotal).abs() > 0.01) {
          throw Exception(
            'Split payment must equal sale total.\n'
            'Sale total: ₦${_formatMoney(cartTotal)}\n'
            'Payment received: ₦${_formatMoney(paymentTotal)}',
          );
        }

        if (receivedCash > 0 && !_isPaymentMethodEnabled('cash')) {
          throw Exception('Cash is disabled in POS settings.');
        }

        if (receivedPos > 0 && !_isPaymentMethodEnabled('pos')) {
          throw Exception('POS is disabled in POS settings.');
        }

        if (receivedTransfer > 0 && !_isPaymentMethodEnabled('transfer')) {
          throw Exception('Transfer is disabled in POS settings.');
        }
      }

      // ========================================================
      // 5. STOCK
      // ========================================================

      for (final entry in cart.entries) {
        final product = _findProduct(entry.key);

        if (product == null) {
          throw Exception('Product ${entry.key} could not be found.');
        }

        final requestedQty = entry.value;

        if (requestedQty <= 0) continue;

        if (requestedQty > product.stock) {
          throw Exception(
            'Only ${product.stock} units of '
            '${product.name} are available.',
          );
        }
      }

      // ========================================================
      // 6. PAYMENT ALLOCATION
      // ========================================================

      double appliedCash = 0;
      double appliedPos = 0;
      double appliedTransfer = 0;

      if (normalizedPaymentMethod == 'cash') {
        appliedCash = cartTotal.toDouble();
      } else if (normalizedPaymentMethod == 'pos') {
        appliedPos = cartTotal.toDouble();
      } else if (normalizedPaymentMethod == 'transfer') {
        appliedTransfer = cartTotal.toDouble();
      } else if (normalizedPaymentMethod == 'split') {
        appliedCash = receivedCash;
        appliedPos = receivedPos;
        appliedTransfer = receivedTransfer;
      }

      // ========================================================
      // 7. INSERT SALES
      // ========================================================

      final List<Sale> completedSales = [];

      final entries = cart.entries.where((entry) => entry.value > 0).toList();

      if (entries.isEmpty) {
        throw Exception('No valid products were found in the cart.');
      }

      double processedCash = 0;
      double processedPos = 0;
      double processedTransfer = 0;

      for (int index = 0; index < entries.length; index++) {
        final entry = entries[index];

        final product = _findProduct(entry.key);

        if (product == null) {
          throw Exception('Product ${entry.key} could not be found.');
        }

        final qty = entry.value;

        if (qty <= 0) continue;

        final lineTotal = qty * product.sellingPrice.toInt();

        final isLastItem = index == entries.length - 1;

        double lineCash;
        double linePos;
        double lineTransfer;

        if (isLastItem) {
          lineCash = appliedCash - processedCash;
          linePos = appliedPos - processedPos;
          lineTransfer = appliedTransfer - processedTransfer;
        } else {
          final ratio = lineTotal / cartTotal;

          lineCash = appliedCash * ratio;
          linePos = appliedPos * ratio;
          lineTransfer = appliedTransfer * ratio;
        }

        if (lineCash.abs() < 0.005) {
          lineCash = 0;
        }

        if (linePos.abs() < 0.005) {
          linePos = 0;
        }

        if (lineTransfer.abs() < 0.005) {
          lineTransfer = 0;
        }

        final saleId = await salesDao.insertSale(
          SalesCompanion.insert(
            productId: product.id,
            quantity: qty,
            unitPrice: product.sellingPrice.toInt(),
            totalPrice: lineTotal,
            costPriceAtSale: Value(product.costPrice),
            paymentMethod: normalizedPaymentMethod,
            cashAmount: Value(lineCash),
            posAmount: Value(linePos),
            transferAmount: Value(lineTransfer),
            status: const Value('paid'),
            staffId: staff.id,
          ),
        );

        final sale = await (salesDao.select(
          salesDao.sales,
        )..where((s) => s.id.equals(saleId))).getSingle();

        completedSales.add(sale);

        processedCash += lineCash;
        processedPos += linePos;
        processedTransfer += lineTransfer;
      }

      // ========================================================
      // 8. CLEAR CART
      // ========================================================

      if (!mounted) return;

      setState(() {
        cart.clear();
        paymentMethod = _getSafePaymentMethod();
      });

      // ========================================================
      // 9. REFRESH PRODUCTS
      // ========================================================

      await _loadProducts();

      // ========================================================
      // 10. RECEIPT
      // ========================================================

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReceiptWidget(
            sales: completedSales,
            cashier: staff,
            products: products,
            settingsDao: settingsDao,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(e.toString().replaceFirst('Exception: ', ''), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _processingSale = false;
        });
      }
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.small.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: isError ? AppColors.danger : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.lg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
    );
  }

  // ============================================================
  // BUSINESS LOGO
  // ============================================================

  Widget _buildBusinessLogo() {
    return FutureBuilder<String?>(
      future: BusinessIdentity.getBusinessLogo(settingsDao),
      builder: (context, snapshot) {
        final logoPath = snapshot.data;

        if (logoPath == null || logoPath.trim().isEmpty) {
          return const Icon(
            Icons.storefront_outlined,
            color: Colors.white,
            size: 22,
          );
        }

        final logoFile = File(logoPath);

        if (!logoFile.existsSync()) {
          return const Icon(
            Icons.storefront_outlined,
            color: Colors.white,
            size: 22,
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Image.file(
            logoFile,
            width: 32,
            height: 32,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.storefront_outlined,
                color: Colors.white,
                size: 22,
              );
            },
          ),
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    if (_loadingPosSettings) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: const CentralBackButton(),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Point of Sale',
            style: AppTextStyles.title.copyWith(color: Colors.white),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(r),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool useSplitLayout = constraints.maxWidth >= 900;

            if (useSplitLayout) {
              return _buildSplitLayout();
            }

            return _buildStackedLayout(constraints, r);
          },
        ),
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar(Responsive r) {
    final email = Session.currentUserEmail ?? 'Unknown Staff';

    final toolbarHeight = r.isCompact ? 54.0 : 60.0;

    return AppBar(
      leading: const CentralBackButton(),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: toolbarHeight,
      titleSpacing: AppSpacing.xs,
      title: Row(
        children: [
          Container(
            width: r.isCompact ? 32 : 36,
            height: r.isCompact ? 32 : 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: _buildBusinessLogo(),
          ),

          const SizedBox(width: AppSpacing.sm),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Point of Sale',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.heading.copyWith(
                    color: Colors.white,
                    fontSize: r.isCompact ? 14 : 17,
                  ),
                ),
                Text(
                  'Cashier: $email',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.small.copyWith(
                    color: Colors.white70,
                    fontSize: r.isCompact ? 8 : 10,
                  ),
                ),
              ],
            ),
          ),

          if (totalItems > 0)
            Container(
              margin: EdgeInsets.only(
                right: r.isCompact ? AppSpacing.xs : AppSpacing.sm,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppRadius.round),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 15,
                    color: Colors.white,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '$totalItems',
                    style: AppTextStyles.small.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // SPLIT LAYOUT
  // ============================================================

  Widget _buildSplitLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(flex: 7, child: _buildProductsPanel()),

        const VerticalDivider(width: 1, thickness: 1, color: AppColors.border),

        Expanded(flex: 3, child: _buildCurrentSalePanel()),
      ],
    );
  }

  // ============================================================
  // STACKED LAYOUT
  // ============================================================

  Widget _buildStackedLayout(BoxConstraints constraints, Responsive r) {
    final availableHeight = constraints.maxHeight;

    /*
     * Compact iPad / portrait layout.
     *
     * The current-sale section receives enough
     * room for:
     *
     *   1. Cart header
     *   2. Scrollable cart
     *   3. Compact payment section
     *
     * PaymentSelector itself can scroll internally.
     */

    final bool veryShort = availableHeight < 600;

    final bool compactHeight = availableHeight < 720;

    final double paymentHeight = veryShort
        ? 178
        : compactHeight
        ? 190
        : 205;

    final double productHeight = availableHeight - paymentHeight - 1;

    /*
     * Extremely short window.
     *
     * Use a vertical scroll instead of creating
     * impossible flex constraints.
     */

    if (productHeight < 240) {
      return SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 380, child: _buildProductsPanel()),

            const Divider(height: 1, thickness: 1, color: AppColors.border),

            SizedBox(
              height: 360,
              child: _buildCurrentSalePanel(forceCompact: true),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(child: _buildProductsPanel()),

        const Divider(height: 1, thickness: 1, color: AppColors.border),

        SizedBox(
          height: paymentHeight,
          child: _buildCurrentSalePanel(forceCompact: true),
        ),
      ],
    );
  }

  // ============================================================
  // PRODUCTS PANEL
  // ============================================================

  Widget _buildProductsPanel() {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          _buildSearchBar(),

          _buildCategoryBar(),

          const Divider(height: 1, thickness: 1, color: AppColors.border),

          Expanded(child: _buildProductArea()),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH BAR
  // ============================================================

  Widget _buildSearchBar() {
    final r = context.responsive;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        r.horizontalPadding,
        r.isCompact ? AppSpacing.xs : AppSpacing.sm,
        r.horizontalPadding,
        AppSpacing.xs,
      ),
      child: SizedBox(
        height: r.isCompact ? 38 : 44,
        child: TextField(
          style: AppTextStyles.body.copyWith(fontSize: r.isCompact ? 11 : 12),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search products or scan barcode...',
            hintStyle: AppTextStyles.bodySecondary.copyWith(
              color: AppColors.textMuted,
              fontSize: r.isCompact ? 10 : 11,
            ),
            prefixIcon: const Icon(
              Icons.search,
              size: 18,
              color: AppColors.textSecondary,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    tooltip: 'Clear search',
                    icon: const Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.2,
              ),
            ),
          ),
          onChanged: (query) {
            setState(() {
              _searchQuery = query.trim().toLowerCase();
            });
          },
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY BAR
  // ============================================================

  Widget _buildCategoryBar() {
    final r = context.responsive;

    return SizedBox(
      height: r.isCompact ? 42 : 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: r.horizontalPadding,
          vertical: AppSpacing.xs,
        ),
        children: [
          _buildCategoryChip(
            label: 'All',
            selected: _selectedCategoryId == null,
            onTap: () {
              setState(() {
                _selectedCategoryId = null;
              });
            },
          ),
          for (final category in categories)
            _buildCategoryChip(
              label: category.name,
              selected: _selectedCategoryId == category.id,
              onTap: () {
                setState(() {
                  _selectedCategoryId = category.id;
                });
              },
            ),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORY CHIP
  // ============================================================

  Widget _buildCategoryChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final r = context.responsive;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: Material(
        color: selected ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.round),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.round),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: r.isCompact ? AppSpacing.sm : AppSpacing.md,
              vertical: r.isCompact ? 4 : AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.round),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.small.copyWith(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontSize: r.isCompact ? 9 : 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PRODUCT AREA
  // ============================================================

  Widget _buildProductArea() {
    final r = context.responsive;

    final search = _searchQuery.trim().toLowerCase();

    List<Product> visibleProducts = products;

    if (search.isNotEmpty) {
      visibleProducts = visibleProducts.where((product) {
        final name = product.name.toLowerCase();

        final barcode = product.barcode?.toLowerCase() ?? '';

        return name.contains(search) || barcode.contains(search);
      }).toList();
    }

    if (_selectedCategoryId != null) {
      visibleProducts = visibleProducts.where((product) {
        return product.categoryId == _selectedCategoryId;
      }).toList();
    }

    if (visibleProducts.isEmpty) {
      return _buildNoProductsState();
    }

    final horizontalSpacing = r.isCompact ? AppSpacing.xs : AppSpacing.sm;

    final verticalSpacing = r.isCompact ? AppSpacing.xs : AppSpacing.sm;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth - (r.horizontalPadding * 2);

        int columns;

        if (constraints.maxWidth < 430) {
          columns = 2;
        } else if (constraints.maxWidth < 700) {
          columns = 3;
        } else if (constraints.maxWidth < 1100) {
          columns = 4;
        } else {
          columns = 5;
        }

        final cardWidth =
            (availableWidth - (horizontalSpacing * (columns - 1))) / columns;

        /*
         * SMALL COMPACT PRODUCT CARD
         *
         * This is intentionally much smaller
         * for iPad and compact screens.
         */

        final cardHeight = r.isCompact ? 126.0 : 145.0;

        return GridView.builder(
          padding: EdgeInsets.all(r.horizontalPadding),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: verticalSpacing,
            crossAxisSpacing: horizontalSpacing,
            childAspectRatio: cardWidth / cardHeight,
          ),
          itemCount: visibleProducts.length,
          itemBuilder: (context, index) {
            return _buildProductCard(visibleProducts[index]);
          },
        );
      },
    );
  }

  // ============================================================
  // NO PRODUCTS
  // ============================================================

  Widget _buildNoProductsState() {
    final r = context.responsive;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(r.horizontalPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: r.isCompact ? 48 : 56,
              height: r.isCompact ? 48 : 56,
              decoration: const BoxDecoration(
                color: AppColors.surfaceSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: r.isCompact ? 22 : 26,
                color: AppColors.textMuted,
              ),
            ),

            const SizedBox(height: AppSpacing.xs),

            Text(
              _searchQuery.isNotEmpty
                  ? 'No products found'
                  : 'No products available',
              style: AppTextStyles.body.copyWith(
                fontSize: r.isCompact ? 11 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              _searchQuery.isNotEmpty
                  ? 'Try another product name or barcode.'
                  : 'Add products to start selling.',
              textAlign: TextAlign.center,
              style: AppTextStyles.small.copyWith(
                fontSize: r.isCompact ? 9 : 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PRODUCT CARD
  // ============================================================

  Widget _buildProductCard(Product product) {
    final r = context.responsive;

    final qty = cart[product.id] ?? 0;

    final stock = product.stock;

    final isOutOfStock = stock <= 0;

    final canAdd = qty < stock;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: AppColors.productCard,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: isOutOfStock
            ? null
            : () {
                _addProductToCart(product);
              },
        child: Padding(
          padding: EdgeInsets.all(r.isCompact ? 6 : AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------------------------------------
              // SMALL IMAGE
              // ------------------------------------------------
              SizedBox(
                height: r.isCompact ? 42 : 52,
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          child:
                              product.imagePath != null &&
                                  product.imagePath!.isNotEmpty
                              ? Image.file(
                                  File(product.imagePath!),
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) {
                                    return const Center(
                                      child: Icon(
                                        Icons.image_not_supported_outlined,
                                        size: 18,
                                        color: AppColors.textMuted,
                                      ),
                                    );
                                  },
                                )
                              : Center(
                                  child: Icon(
                                    Icons.inventory_2_outlined,
                                    size: r.isCompact ? 20 : 23,
                                    color: isOutOfStock
                                        ? AppColors.textMuted
                                        : AppColors.primary,
                                  ),
                                ),
                        ),
                      ),

                      Positioned(
                        top: 2,
                        right: 2,
                        child: _buildStockBadge(stock),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 3),

              // ------------------------------------------------
              // PRODUCT NAME
              // ------------------------------------------------
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  fontSize: r.isCompact ? 9 : 10,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 1),

              // ------------------------------------------------
              // PRICE
              // ------------------------------------------------
              Text(
                '₦${_formatMoney(product.sellingPrice)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.price.copyWith(
                  fontSize: r.isCompact ? 10 : 11,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const Spacer(),

              // ------------------------------------------------
              // QUANTITY
              // ------------------------------------------------
              if (isOutOfStock)
                _buildOutOfStockButton()
              else
                _buildQuantityControls(product, qty, canAdd),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // QUANTITY CONTROLS
  // ============================================================

  Widget _buildQuantityControls(Product product, int qty, bool canAdd) {
    final r = context.responsive;

    final controlHeight = r.isCompact ? 25.0 : 29.0;

    return SizedBox(
      height: controlHeight,
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            SizedBox(
              width: r.isCompact ? 26 : 30,
              height: controlHeight,
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: r.isCompact ? 12 : 14,
                tooltip: 'Remove',
                color: qty > 0 ? AppColors.danger : AppColors.textMuted,
                onPressed: qty > 0
                    ? () {
                        _removeProductFromCart(product);
                      }
                    : null,
                icon: const Icon(Icons.remove),
              ),
            ),

            Expanded(
              child: Center(
                child: Text(
                  '$qty',
                  style: AppTextStyles.body.copyWith(
                    fontSize: r.isCompact ? 9 : 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            SizedBox(
              width: r.isCompact ? 26 : 30,
              height: controlHeight,
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: r.isCompact ? 12 : 14,
                tooltip: canAdd ? 'Add' : 'Maximum stock reached',
                color: canAdd ? AppColors.primary : AppColors.textMuted,
                onPressed: canAdd
                    ? () {
                        _addProductToCart(product);
                      }
                    : null,
                icon: const Icon(Icons.add),
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

  Widget _buildOutOfStockButton() {
    final r = context.responsive;

    return Container(
      height: r.isCompact ? 25 : 29,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.dangerLight,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Center(
        child: Text(
          'Out of stock',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.small.copyWith(
            color: AppColors.danger,
            fontSize: r.isCompact ? 8 : 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CURRENT SALE PANEL
  // ============================================================

  Widget _buildCurrentSalePanel({bool forceCompact = false}) {
    final r = context.responsive;

    return Container(
      color: AppColors.surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          /*
           * IMPORTANT FIX
           *
           * The old implementation gave PaymentSelector
           * a minHeight of 190-205 while the entire
           * Current Sale panel could itself be around
           * 190-285 pixels tall.
           *
           * That caused the cart and payment section
           * to compete for the same space.
           *
           * Now:
           *
           *   Header = fixed small height
           *   Cart = Expanded + scrollable
           *   Payment = fixed compact section
           *
           * No minHeight is forced on PaymentSelector.
           */

          final height = constraints.maxHeight;

          final bool compact = forceCompact || r.isCompact || height < 260;

          final headerHeight = compact ? 44.0 : 50.0;

          /*
           * Payment gets a small predictable
           * area. PaymentSelector scrolls inside it.
           */
          double paymentHeight;

          if (height < 220) {
            paymentHeight = 112;
          } else if (height < 260) {
            paymentHeight = 125;
          } else if (height < 320) {
            paymentHeight = 145;
          } else {
            paymentHeight = 160;
          }

          /*
           * Never allow the payment section to
           * consume the whole Current Sale panel.
           */
          final maximumPayment = height - headerHeight - 50;

          if (paymentHeight > maximumPayment) {
            paymentHeight = maximumPayment.clamp(90.0, 160.0);
          }

          return Column(
            children: [
              SizedBox(
                height: headerHeight,
                child: _buildCartHeader(compact: compact),
              ),

              const Divider(height: 1, thickness: 1, color: AppColors.border),

              /*
               * CART
               *
               * Expanded means the cart can never
               * overlap the payment section.
               */
              Expanded(child: _buildCartSummary(compact: compact)),

              const Divider(height: 1, thickness: 1, color: AppColors.border),

              /*
               * PAYMENT
               *
               * Fixed compact area.
               *
               * PaymentSelector scrolls internally.
               */
              SizedBox(
                height: paymentHeight,
                child: ClipRect(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    child: PaymentSelector(
                      selectedMethod: paymentMethod,
                      total: total,
                      posSettings: _posSettings ?? const PosSettings(),
                      onMethodSelected: (method) {
                        if (!mounted) {
                          return;
                        }

                        final normalized = _normalizePaymentMethod(method);

                        if (!_isPaymentMethodEnabled(normalized)) {
                          _showMessage(
                            '${_formatPaymentMethodName(normalized)} '
                            'is disabled in POS settings.',
                            isError: true,
                          );
                          return;
                        }

                        setState(() {
                          paymentMethod = normalized;
                        });
                      },
                      onPaymentConfirmed: _completeSaleWithAmounts,
                    ),
                  ),
                ),
              ),

              if (_processingSale)
                const LinearProgressIndicator(
                  minHeight: 2,
                  color: AppColors.success,
                  backgroundColor: AppColors.successLight,
                ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // CART HEADER
  // ============================================================

  Widget _buildCartHeader({bool compact = false}) {
    final r = context.responsive;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: r.isCompact ? AppSpacing.sm : AppSpacing.md,
        vertical: compact ? 4 : AppSpacing.xs,
      ),
      color: AppColors.surface,
      child: Row(
        children: [
          Container(
            width: compact ? 28 : 32,
            height: compact ? 28 : 32,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: compact ? 15 : 17,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: AppSpacing.xs),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Current Sale',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    fontSize: compact ? 11 : 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  totalItems == 0
                      ? 'No items'
                      : '$totalItems item${totalItems == 1 ? '' : 's'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.small.copyWith(
                    fontSize: compact ? 8 : 9,
                  ),
                ),
              ],
            ),
          ),

          if (totalItems > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppRadius.round),
              ),
              child: Text(
                '$totalItems',
                style: AppTextStyles.small.copyWith(
                  fontSize: 9,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // CART SUMMARY
  // ============================================================

  Widget _buildCartSummary({bool compact = false}) {
    final r = context.responsive;

    if (cart.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(
            compact ? AppSpacing.sm : r.horizontalPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: compact ? 42 : 48,
                height: compact ? 42 : 48,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  size: compact ? 20 : 23,
                  color: AppColors.textMuted,
                ),
              ),

              const SizedBox(height: AppSpacing.xs),

              Text(
                'Cart is empty',
                style: AppTextStyles.body.copyWith(
                  fontSize: compact ? 10 : 11,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                'Select products to begin',
                textAlign: TextAlign.center,
                style: AppTextStyles.small.copyWith(fontSize: compact ? 8 : 9),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        compact ? 6 : AppSpacing.sm,
        compact ? 5 : AppSpacing.sm,
        compact ? 6 : AppSpacing.sm,
        compact ? 5 : AppSpacing.sm,
      ),
      itemCount: cart.length + 1,
      itemBuilder: (context, index) {
        if (index == cart.length) {
          return _buildSubtotalCard(compact: compact);
        }

        final entry = cart.entries.elementAt(index);

        final product = _findProduct(entry.key);

        if (product == null) {
          return const SizedBox.shrink();
        }

        final qty = entry.value;

        final lineTotal = qty * product.sellingPrice.toInt();

        return _buildCartItem(product, qty, lineTotal, compact: compact);
      },
    );
  }

  // ============================================================
  // CART ITEM
  // ============================================================

  Widget _buildCartItem(
    Product product,
    int qty,
    int lineTotal, {
    bool compact = false,
  }) {
    final r = context.responsive;

    final canAdd = qty < product.stock;

    final itemHeight = compact ? 42.0 : 48.0;

    return Container(
      height: itemHeight,
      margin: const EdgeInsets.only(bottom: 4),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 5 : 7,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 32 : 36,
            height: compact ? 32 : 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: product.imagePath != null && product.imagePath!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: Image.file(
                      File(product.imagePath!),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) {
                        return const Icon(
                          Icons.inventory_2_outlined,
                          size: 17,
                          color: AppColors.primary,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.inventory_2_outlined,
                    size: 17,
                    color: AppColors.primary,
                  ),
          ),

          const SizedBox(width: 5),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    fontSize: compact ? 8 : 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                Text(
                  '₦${_formatMoney(product.sellingPrice)} × $qty',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.small.copyWith(
                    fontSize: compact ? 7 : 8,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 3),

          Text(
            '₦${_formatMoney(lineTotal)}',
            style: AppTextStyles.body.copyWith(
              fontSize: compact ? 8 : 9,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(
            width: compact ? 22 : 25,
            height: compact ? 25 : 28,
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: compact ? 13 : 14,
              tooltip: 'Remove one',
              color: AppColors.danger,
              onPressed: () {
                _removeProductFromCart(product);
              },
              icon: const Icon(Icons.remove_circle_outline),
            ),
          ),

          SizedBox(
            width: 14,
            child: Text(
              '$qty',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                fontSize: compact ? 8 : 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          SizedBox(
            width: compact ? 22 : 25,
            height: compact ? 25 : 28,
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: compact ? 13 : 14,
              tooltip: canAdd ? 'Add one' : 'Maximum stock reached',
              color: canAdd ? AppColors.success : AppColors.textMuted,
              onPressed: canAdd
                  ? () {
                      _addProductToCart(product);
                    }
                  : null,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUBTOTAL
  // ============================================================

  Widget _buildSubtotalCard({bool compact = false}) {
    return Container(
      margin: const EdgeInsets.only(top: 2, bottom: 2),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : AppSpacing.md,
        vertical: compact ? 6 : AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Text(
            'Subtotal',
            style: AppTextStyles.body.copyWith(
              fontSize: compact ? 9 : 11,
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          Text(
            '₦${_formatMoney(total)}',
            style: AppTextStyles.body.copyWith(
              fontSize: compact ? 12 : 14,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ADD PRODUCT
  // ============================================================

  void _addProductToCart(Product product) {
    if (_processingSale) return;

    if (product.stock <= 0) {
      _showMessage('${product.name} is out of stock.', isError: true);
      return;
    }

    final currentQty = cart[product.id] ?? 0;

    if (currentQty >= product.stock) {
      _showMessage(
        'Only ${product.stock} units of '
        '${product.name} available.',
        isError: true,
      );
      return;
    }

    setState(() {
      cart[product.id] = currentQty + 1;
    });
  }

  // ============================================================
  // REMOVE PRODUCT
  // ============================================================

  void _removeProductFromCart(Product product) {
    if (_processingSale) return;

    final currentQty = cart[product.id] ?? 0;

    setState(() {
      if (currentQty <= 1) {
        cart.remove(product.id);
      } else {
        cart[product.id] = currentQty - 1;
      }
    });
  }

  // ============================================================
  // STOCK BADGE
  // ============================================================

  Widget _buildStockBadge(int stock) {
    final r = context.responsive;

    if (stock <= 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.dangerLight,
          borderRadius: BorderRadius.circular(AppRadius.round),
        ),
        child: Text(
          'OUT',
          style: AppTextStyles.small.copyWith(
            color: AppColors.danger,
            fontSize: r.isCompact ? 6 : 7,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    if (stock <= 5) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.warningLight,
          borderRadius: BorderRadius.circular(AppRadius.round),
        ),
        child: Text(
          '$stock',
          style: AppTextStyles.small.copyWith(
            color: AppColors.warning,
            fontSize: r.isCompact ? 6 : 7,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(AppRadius.round),
      ),
      child: Text(
        '$stock',
        style: AppTextStyles.small.copyWith(
          color: AppColors.success,
          fontSize: r.isCompact ? 6 : 7,
          fontWeight: FontWeight.w600,
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
