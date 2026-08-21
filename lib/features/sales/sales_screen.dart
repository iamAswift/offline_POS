// lib/features/sales/sales_screen.dart

import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import 'package:supermarket_inventory/core/widgets/back_button.dart';

import '../../core/session.dart';
import '../../core/theme/styles.dart';
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

  /// Currently selected payment method.
  String paymentMethod = 'cash';

  /// Loaded POS settings.
  PosSettings? _posSettings;

  /// Prevent the POS screen from being used before
  /// settings have finished loading.
  bool _loadingPosSettings = true;

  bool _processingSale = false;

  String _searchQuery = '';

  /// null = all categories
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
      final service = PosSettingsService(
        settingsDao: settingsDao,
      );

      final settings = await service.load();

      if (!mounted) {
        return;
      }

      setState(() {
        _posSettings = settings;

        paymentMethod =
            settings.safeDefaultPaymentMethod;

        _loadingPosSettings = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      const fallbackSettings = PosSettings();

      setState(() {
        _posSettings = fallbackSettings;

        paymentMethod =
            fallbackSettings.safeDefaultPaymentMethod;

        _loadingPosSettings = false;
      });

      _showMessage(
        'Could not load POS settings. '
        'Using defaults.',
        isError: true,
      );
    }
  }

  // ============================================================
  // POS SETTINGS HELPERS
  // ============================================================

  bool _isPaymentMethodEnabled(
    String method,
  ) {
    final settings = _posSettings;

    if (settings == null) {
      return false;
    }

    return settings.isPaymentMethodEnabled(
      method,
    );
  }

  String _getSafePaymentMethod() {
    final settings = _posSettings;

    if (settings == null) {
      return 'cash';
    }

    return settings.safeDefaultPaymentMethod;
  }

  String _normalizePaymentMethod(
    String? value,
  ) {
    final method =
        value?.trim().toLowerCase() ?? '';

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

  String _formatPaymentMethodName(
    String value,
  ) {
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
    final list =
        await categoryDao.getAllCategories();

    if (!mounted) {
      return;
    }

    setState(() {
      categories = list;
    });
  }

  Future<void> _loadProducts() async {
    final list =
        await productDao.getAllProducts();

    if (!mounted) {
      return;
    }

    setState(() {
      products = list;
    });
  }

  // ============================================================
  // TOTALS
  // ============================================================

  int get total {
    return cart.entries.fold<int>(
      0,
      (sum, entry) {
        final product =
            _findProduct(entry.key);

        if (product == null) {
          return sum;
        }

        return sum +
            (entry.value *
                product.sellingPrice.toInt());
      },
    );
  }

  int get totalItems {
    return cart.values.fold<int>(
      0,
      (sum, quantity) =>
          sum + quantity,
    );
  }

  Product? _findProduct(
    int productId,
  ) {
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
    if (_processingSale) {
      return;
    }

    if (_loadingPosSettings ||
        _posSettings == null) {
      _showMessage(
        'POS settings are still loading.',
        isError: true,
      );
      return;
    }

    if (cart.isEmpty) {
      _showMessage(
        'Cart is empty.',
        isError: true,
      );
      return;
    }

    final currentUserEmail =
        Session.currentUserEmail;

    if (currentUserEmail == null ||
        currentUserEmail.trim().isEmpty) {
      _showMessage(
        'No logged-in staff found.',
        isError: true,
      );
      return;
    }

    // ==========================================================
    // VALIDATE PAYMENT METHOD
    // ==========================================================

    final normalizedPaymentMethod =
        _normalizePaymentMethod(
      paymentMethod,
    );

    if (!_isPaymentMethodEnabled(
      normalizedPaymentMethod,
    )) {
      _showMessage(
        '${_formatPaymentMethodName(normalizedPaymentMethod)} '
        'is disabled in POS settings.',
        isError: true,
      );

      setState(() {
        paymentMethod =
            _getSafePaymentMethod();
      });

      return;
    }

    // The current PaymentSelector supports:
    //
    // cash
    // pos
    // transfer
    // split
    //
    // We therefore do not allow unsupported methods
    // to reach the sales database.

    if (normalizedPaymentMethod != 'cash' &&
        normalizedPaymentMethod != 'pos' &&
        normalizedPaymentMethod != 'transfer' &&
        normalizedPaymentMethod != 'split') {
      _showMessage(
        '${_formatPaymentMethodName(normalizedPaymentMethod)} '
        'is not currently supported by the sales payment selector.',
        isError: true,
      );
      return;
    }

    setState(() {
      _processingSale = true;
    });

    try {
      // ========================================================
      // 1. GET CURRENT STAFF
      // ========================================================

      final staff =
          await getUserDao().getUserByEmail(
        currentUserEmail,
      );

      if (staff == null) {
        throw Exception(
          'No staff record found for the current session.',
        );
      }

      // ========================================================
      // 2. GET SALE TOTAL
      // ========================================================

      final cartTotal = total;

      if (cartTotal <= 0) {
        throw Exception(
          'Sale total must be greater than zero.',
        );
      }

      // ========================================================
      // 3. NORMALIZE PAYMENT AMOUNTS
      // ========================================================

      final receivedCash =
          cashAmount < 0
              ? 0.0
              : cashAmount;

      final receivedPos =
          posAmount < 0
              ? 0.0
              : posAmount;

      final receivedTransfer =
          transferAmount < 0
              ? 0.0
              : transferAmount;

      // ========================================================
      // 4. VALIDATE PAYMENT
      // ========================================================

      if (normalizedPaymentMethod ==
          'cash') {
        // Cash can be greater than the sale total.
        //
        // Example:
        //
        // Sale = ₦7,500
        // Cash = ₦10,000
        // Change = ₦2,500
        //
        // Only ₦7,500 is recorded against the sale.

        if (receivedCash < cartTotal) {
          throw Exception(
            'Cash amount is not enough.\n'
            'Sale total: ₦${_formatMoney(cartTotal)}\n'
            'Cash received: ₦${_formatMoney(receivedCash)}',
          );
        }
      } else if (normalizedPaymentMethod ==
          'pos') {
        if ((receivedPos - cartTotal)
                .abs() >
            0.01) {
          throw Exception(
            'POS amount does not match sale total.\n'
            'Sale total: ₦${_formatMoney(cartTotal)}\n'
            'POS received: ₦${_formatMoney(receivedPos)}',
          );
        }
      } else if (normalizedPaymentMethod ==
          'transfer') {
        if ((receivedTransfer -
                    cartTotal)
                .abs() >
            0.01) {
          throw Exception(
            'Transfer amount does not match sale total.\n'
            'Sale total: ₦${_formatMoney(cartTotal)}\n'
            'Transfer received: ₦${_formatMoney(receivedTransfer)}',
          );
        }
      } else if (normalizedPaymentMethod ==
          'split') {
        final paymentTotal =
            receivedCash +
            receivedPos +
            receivedTransfer;

        if ((paymentTotal - cartTotal)
                .abs() >
            0.01) {
          throw Exception(
            'Split payment must equal sale total.\n'
            'Sale total: ₦${_formatMoney(cartTotal)}\n'
            'Payment received: ₦${_formatMoney(paymentTotal)}',
          );
        }

        if (receivedCash > 0 &&
            !_isPaymentMethodEnabled(
              'cash',
            )) {
          throw Exception(
            'Cash is disabled in POS settings.',
          );
        }

        if (receivedPos > 0 &&
            !_isPaymentMethodEnabled(
              'pos',
            )) {
          throw Exception(
            'POS is disabled in POS settings.',
          );
        }

        if (receivedTransfer > 0 &&
            !_isPaymentMethodEnabled(
              'transfer',
            )) {
          throw Exception(
            'Transfer is disabled in POS settings.',
          );
        }
      }

      // ========================================================
      // 5. VALIDATE STOCK
      // ========================================================

      for (final entry in cart.entries) {
        final product =
            _findProduct(entry.key);

        if (product == null) {
          throw Exception(
            'Product ${entry.key} could not be found.',
          );
        }

        final requestedQty =
            entry.value;

        if (requestedQty <= 0) {
          continue;
        }

        if (requestedQty >
            product.stock) {
          throw Exception(
            'Only ${product.stock} units of '
            '${product.name} are available.',
          );
        }
      }

      // ========================================================
      // 6. PAYMENT AMOUNTS APPLIED
      // ========================================================

      double appliedCash = 0;
      double appliedPos = 0;
      double appliedTransfer = 0;

      if (normalizedPaymentMethod ==
          'cash') {
        appliedCash =
            cartTotal.toDouble();
      } else if (normalizedPaymentMethod ==
          'pos') {
        appliedPos =
            cartTotal.toDouble();
      } else if (normalizedPaymentMethod ==
          'transfer') {
        appliedTransfer =
            cartTotal.toDouble();
      } else if (normalizedPaymentMethod ==
          'split') {
        appliedCash =
            receivedCash;

        appliedPos =
            receivedPos;

        appliedTransfer =
            receivedTransfer;
      }

      // ========================================================
      // 7. INSERT SALES
      // ========================================================

      final List<Sale> completedSales =
          [];

      final entries =
          cart.entries
              .where(
                (entry) =>
                    entry.value > 0,
              )
              .toList();

      if (entries.isEmpty) {
        throw Exception(
          'No valid products were found in the cart.',
        );
      }

      double processedCash = 0;
      double processedPos = 0;
      double processedTransfer = 0;

      for (
        int index = 0;
        index < entries.length;
        index++
      ) {
        final entry =
            entries[index];

        final product =
            _findProduct(entry.key);

        if (product == null) {
          throw Exception(
            'Product ${entry.key} could not be found.',
          );
        }

        final qty =
            entry.value;

        if (qty <= 0) {
          continue;
        }

        // ======================================================
        // LINE TOTAL
        // ======================================================

        final lineTotal =
            qty *
            product.sellingPrice.toInt();

        // ======================================================
        // PAYMENT ALLOCATION
        // ======================================================

        final isLastItem =
            index ==
                entries.length - 1;

        double lineCash;
        double linePos;
        double lineTransfer;

        if (isLastItem) {
          lineCash =
              appliedCash -
                  processedCash;

          linePos =
              appliedPos -
                  processedPos;

          lineTransfer =
              appliedTransfer -
                  processedTransfer;
        } else {
          final ratio =
              lineTotal /
                  cartTotal;

          lineCash =
              appliedCash *
                  ratio;

          linePos =
              appliedPos *
                  ratio;

          lineTransfer =
              appliedTransfer *
                  ratio;
        }

        // ======================================================
        // FLOATING POINT PROTECTION
        // ======================================================

        if (lineCash.abs() <
            0.005) {
          lineCash = 0;
        }

        if (linePos.abs() <
            0.005) {
          linePos = 0;
        }

        if (lineTransfer.abs() <
            0.005) {
          lineTransfer = 0;
        }

        // ======================================================
        // INSERT SALE
        // ======================================================

        final saleId =
            await salesDao.insertSale(
          SalesCompanion.insert(
            productId:
                product.id,

            quantity:
                qty,

            unitPrice:
                product.sellingPrice
                    .toInt(),

            totalPrice:
                lineTotal,

            costPriceAtSale:
                Value(
              product.costPrice,
            ),

            paymentMethod:
                normalizedPaymentMethod,

            cashAmount:
                Value(lineCash),

            posAmount:
                Value(linePos),

            transferAmount:
                Value(lineTransfer),

            status:
                const Value('paid'),

            staffId:
                staff.id,
          ),
        );

        // ======================================================
        // FETCH SALE FOR RECEIPT
        // ======================================================

        final sale =
            await (
              salesDao.select(
                salesDao.sales,
              )
                ..where(
                  (s) =>
                      s.id.equals(
                    saleId,
                  ),
                )
            ).getSingle();

        completedSales.add(
          sale,
        );

        // ======================================================
        // PAYMENT TRACKING
        // ======================================================

        processedCash +=
            lineCash;

        processedPos +=
            linePos;

        processedTransfer +=
            lineTransfer;
      }

      // ========================================================
      // 8. CLEAR CART
      // ========================================================

      if (!mounted) {
        return;
      }

      setState(() {
        cart.clear();

        // Return to configured default.
        paymentMethod =
            _getSafePaymentMethod();
      });

      // ========================================================
      // 9. REFRESH PRODUCTS
      // ========================================================

      await _loadProducts();

      // ========================================================
      // 10. SHOW RECEIPT
      // ========================================================

      if (!mounted) {
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ReceiptWidget(
            sales:
                completedSales,

            cashier:
                staff,

            products:
                products,

            settingsDao:
                settingsDao,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
        isError: true,
      );
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

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(
          message,
          style:
              const TextStyle(
            fontFamily:
                'Poppins',
            fontSize: 13,
            fontWeight:
                FontWeight.w500,
          ),
        ),
        backgroundColor:
            isError
                ? AppColors.danger
                : AppColors.primary,
        behavior:
            SnackBarBehavior.floating,
        margin:
            const EdgeInsets.all(16),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            10,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUSINESS LOGO
  // ============================================================

  Widget _buildBusinessLogo() {
    return FutureBuilder<String?>(
      future:
          BusinessIdentity.getBusinessLogo(
        settingsDao,
      ),
      builder: (
        context,
        snapshot,
      ) {
        final logoPath =
            snapshot.data;

        if (logoPath == null ||
            logoPath.trim().isEmpty) {
          return const Icon(
            Icons.storefront_outlined,
            color: Colors.white,
            size: 23,
          );
        }

        final logoFile =
            File(logoPath);

        if (!logoFile.existsSync()) {
          return const Icon(
            Icons.storefront_outlined,
            color: Colors.white,
            size: 23,
          );
        }

        return ClipRRect(
          borderRadius:
              BorderRadius.circular(
            8,
          ),
          child:
              Image.file(
            logoFile,
            width: 34,
            height: 34,
            fit: BoxFit.contain,
            errorBuilder: (
              context,
              error,
              stackTrace,
            ) {
              return const Icon(
                Icons
                    .storefront_outlined,
                color: Colors.white,
                size: 23,
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
  Widget build(
    BuildContext context,
  ) {
    final email =
        Session.currentUserEmail ??
            'Unknown Staff';

    if (_loadingPosSettings) {
      return Scaffold(
        backgroundColor:
            AppColors.background,
        appBar:
            AppBar(
          leading:
              const CentralBackButton(),
          backgroundColor:
              AppColors.primary,
          foregroundColor:
              Colors.white,
          elevation: 0,
          title:
              const Text(
            'Point of Sale',
          ),
        ),
        body:
            const Center(
          child:
              CircularProgressIndicator(
            color:
                AppColors.primary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          AppColors.background,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar:
          AppBar(
        leading:
            const CentralBackButton(),

        backgroundColor:
            AppColors.primary,

        foregroundColor:
            Colors.white,

        elevation: 0,

        titleSpacing: 4,

        title:
            Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration:
                  BoxDecoration(
                color:
                    Colors.white
                        .withValues(
                  alpha: 0.12,
                ),
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
                border:
                    Border.all(
                  color:
                      Colors.white
                          .withValues(
                    alpha: 0.12,
                  ),
                ),
              ),
              child:
                  _buildBusinessLogo(),
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child:
                  Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Text(
                    'Point of Sale',
                    style:
                        AppTextStyles
                            .heading
                            .copyWith(
                      color:
                          Colors.white,
                      fontSize: 19,
                    ),
                  ),

                  const SizedBox(
                    height: 2,
                  ),

                  Text(
                    'Cashier: $email',
                    maxLines: 1,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        AppTextStyles
                            .body
                            .copyWith(
                      color:
                          Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            if (totalItems > 0)
              Container(
                margin:
                    const EdgeInsets
                        .only(
                  right: 12,
                ),
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.white
                          .withValues(
                    alpha: 0.14,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    20,
                  ),
                ),
                child:
                    Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons
                          .shopping_cart_outlined,
                      size: 18,
                      color:
                          Colors.white,
                    ),

                    const SizedBox(
                      width: 5,
                    ),

                    Text(
                      '$totalItems',
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body:
          SafeArea(
        top: false,
        child:
            LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final isWide =
                constraints.maxWidth >=
                    850;

            if (isWide) {
              return Row(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .stretch,
                children: [
                  Expanded(
                    flex: 7,
                    child:
                        _buildProductsPanel(),
                  ),

                  const VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color:
                        AppColors.border,
                  ),

                  Expanded(
                    flex: 3,
                    child:
                        _buildCurrentSalePanel(),
                  ),
                ],
              );
            }

            return Column(
              children: [
                Expanded(
                  child:
                      _buildProductsPanel(),
                ),

                const Divider(
                  height: 1,
                  thickness: 1,
                  color:
                      AppColors.border,
                ),

                SizedBox(
                  height:
                      constraints.maxHeight *
                          0.48,
                  child:
                      _buildCurrentSalePanel(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // PRODUCTS PANEL
  // ============================================================

  Widget _buildProductsPanel() {
    return Container(
      color:
          AppColors.background,
      child:
          Column(
        children: [
          _buildSearchBar(),

          _buildCategoryBar(),

          const Divider(
            height: 1,
            thickness: 1,
            color:
                AppColors.border,
          ),

          Expanded(
            child:
                _buildProductArea(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH BAR
  // ============================================================

  Widget _buildSearchBar() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        16,
        14,
        16,
        8,
      ),
      child:
          TextField(
        style:
            AppTextStyles.body
                .copyWith(
          fontSize: 14,
        ),
        decoration:
            InputDecoration(
          hintText:
              'Search products or scan barcode...',

          hintStyle:
              AppTextStyles
                  .bodySecondary
                  .copyWith(
            color:
                AppColors.textMuted,
          ),

          prefixIcon:
              const Icon(
            Icons.search,
            color:
                AppColors
                    .textSecondary,
          ),

          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                      tooltip:
                          'Clear search',
                      icon:
                          const Icon(
                        Icons.close,
                        size: 20,
                        color:
                            AppColors
                                .textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _searchQuery =
                              '';
                        });
                      },
                    )
                  : null,

          filled: true,

          fillColor:
              AppColors.surface,

          contentPadding:
              const EdgeInsets
                  .symmetric(
            vertical: 14,
            horizontal: 14,
          ),

          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),
            borderSide:
                const BorderSide(
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
                const BorderSide(
              color:
                  AppColors.border,
            ),
          ),

          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),
            borderSide:
                const BorderSide(
              color:
                  AppColors.primary,
              width: 1.5,
            ),
          ),
        ),
        onChanged: (query) {
          setState(() {
            _searchQuery =
                query.trim()
                    .toLowerCase();
          });
        },
      ),
    );
  }

  // ============================================================
  // CATEGORY BAR
  // ============================================================

  Widget _buildCategoryBar() {
    return SizedBox(
      height: 52,
      child:
          ListView(
        scrollDirection:
            Axis.horizontal,
        padding:
            const EdgeInsets
                .symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        children: [
          _buildCategoryChip(
            label: 'All',
            selected:
                _selectedCategoryId ==
                    null,
            onTap: () {
              setState(() {
                _selectedCategoryId =
                    null;
              });
            },
          ),

          for (final category
              in categories)
            _buildCategoryChip(
              label:
                  category.name,
              selected:
                  _selectedCategoryId ==
                      category.id,
              onTap: () {
                setState(() {
                  _selectedCategoryId =
                      category.id;
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
    return Padding(
      padding:
          const EdgeInsets.only(
        right: 8,
      ),
      child:
          Material(
        color:
            selected
                ? AppColors.primary
                : AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
        child:
            InkWell(
          borderRadius:
              BorderRadius.circular(
            20,
          ),
          onTap:
              onTap,
          child:
              Container(
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 15,
              vertical: 7,
            ),
            decoration:
                BoxDecoration(
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
              border:
                  Border.all(
                color:
                    selected
                        ? AppColors
                            .primary
                        : AppColors
                            .border,
              ),
            ),
            child:
                Text(
              label,
              style:
                  AppTextStyles
                      .small
                      .copyWith(
                color:
                    selected
                        ? Colors.white
                        : AppColors
                            .textSecondary,
                fontWeight:
                    FontWeight.w600,
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
    final search =
        _searchQuery
            .trim()
            .toLowerCase();

    List<Product>
        visibleProducts =
        products;

    if (search.isNotEmpty) {
      visibleProducts =
          visibleProducts
              .where(
        (product) {
          final name =
              product.name
                  .toLowerCase();

          final barcode =
              product.barcode
                      ?.toLowerCase() ??
                  '';

          return name.contains(
                search,
              ) ||
              barcode.contains(
                search,
              );
        },
      ).toList();
    }

    if (_selectedCategoryId !=
        null) {
      visibleProducts =
          visibleProducts
              .where(
        (product) {
          return product
                  .categoryId ==
              _selectedCategoryId;
        },
      ).toList();
    }

    if (visibleProducts
        .isEmpty) {
      return _buildNoProductsState();
    }

    return GridView.builder(
      padding:
          const EdgeInsets.all(
        14,
      ),
      gridDelegate:
          const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 210,
        mainAxisExtent: 205,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount:
          visibleProducts.length,
      itemBuilder:
          (context, index) {
        return _buildProductCard(
          visibleProducts[index],
        );
      },
    );
  }

  // ============================================================
  // NO PRODUCTS
  // ============================================================

  Widget _buildNoProductsState() {
    return Center(
      child:
          Padding(
        padding:
            const EdgeInsets.all(
          32,
        ),
        child:
            Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration:
                  const BoxDecoration(
                color:
                    AppColors
                        .surfaceSoft,
                shape:
                    BoxShape.circle,
              ),
              child:
                  const Icon(
                Icons
                    .inventory_2_outlined,
                size: 30,
                color:
                    AppColors
                        .textMuted,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              _searchQuery
                      .isNotEmpty
                  ? 'No products found'
                  : 'No products available',
              style:
                  AppTextStyles
                      .body
                      .copyWith(
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(
              height: 4,
            ),

            Text(
              _searchQuery
                      .isNotEmpty
                  ? 'Try another product name or barcode.'
                  : 'Add products to start selling.',
              textAlign:
                  TextAlign.center,
              style:
                  AppTextStyles.small,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PRODUCT CARD
  // ============================================================

  Widget _buildProductCard(
    Product product,
  ) {
    final qty =
        cart[product.id] ??
            0;

    final stock =
        product.stock;

    final isOutOfStock =
        stock <= 0;

    final canAdd =
        qty < stock;

    return Card(
      elevation: 0,
      margin:
          EdgeInsets.zero,
      color:
          AppColors.surface,
      clipBehavior:
          Clip.antiAlias,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          12,
        ),
        side:
            const BorderSide(
          color:
              AppColors.border,
        ),
      ),
      child:
          InkWell(
        onTap:
            isOutOfStock
                ? null
                : () {
                    _addProductToCart(
                      product,
                    );
                  },
        child:
            Padding(
          padding:
              const EdgeInsets.all(
            9,
          ),
          child:
              Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              SizedBox(
                height: 88,
                width:
                    double.infinity,
                child:
                    Container(
                  decoration:
                      BoxDecoration(
                    color:
                        AppColors
                            .surfaceSoft,
                    borderRadius:
                        BorderRadius
                            .circular(
                      9,
                    ),
                  ),
                  child:
                      Stack(
                    children: [
                      Positioned
                          .fill(
                        child:
                            ClipRRect(
                          borderRadius:
                              BorderRadius.circular(
                            9,
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
                                        return const Center(
                                          child:
                                              Icon(
                                            Icons
                                                .image_not_supported_outlined,
                                            size:
                                                28,
                                            color:
                                                AppColors
                                                    .textMuted,
                                          ),
                                        );
                                      },
                                    )
                                  : Center(
                                      child:
                                          Icon(
                                        Icons
                                            .inventory_2_outlined,
                                        size:
                                            32,
                                        color:
                                            isOutOfStock
                                                ? AppColors
                                                    .textMuted
                                                : AppColors
                                                    .primary,
                                      ),
                                    ),
                        ),
                      ),

                      Positioned(
                        top: 5,
                        right: 5,
                        child:
                            _buildStockBadge(
                          stock,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 7,
              ),

              Text(
                product.name,
                maxLines: 1,
                overflow:
                    TextOverflow
                        .ellipsis,
                style:
                    AppTextStyles
                        .body
                        .copyWith(
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(
                height: 2,
              ),

              Text(
                '₦${_formatMoney(product.sellingPrice)}',
                style:
                    AppTextStyles
                        .price
                        .copyWith(
                  fontSize: 14,
                  color:
                      AppColors
                          .primary,
                ),
              ),

              const Spacer(),

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
    );
  }

  // ============================================================
  // QUANTITY CONTROLS
  // ============================================================

  Widget _buildQuantityControls(
    Product product,
    int qty,
    bool canAdd,
  ) {
    return Container(
      height: 34,
      width:
          double.infinity,
      decoration:
          BoxDecoration(
        color:
            AppColors
                .surfaceSoft,
        borderRadius:
            BorderRadius.circular(
          8,
        ),
        border:
            Border.all(
          color:
              AppColors.border,
        ),
      ),
      child:
          Row(
        children: [
          SizedBox(
            width: 36,
            height: 34,
            child:
                IconButton(
              padding:
                  EdgeInsets.zero,
              iconSize: 17,
              tooltip:
                  'Remove',
              color:
                  qty > 0
                      ? AppColors
                          .danger
                      : AppColors
                          .textMuted,
              onPressed:
                  qty > 0
                      ? () {
                          _removeProductFromCart(
                            product,
                          );
                        }
                      : null,
              icon:
                  const Icon(
                Icons.remove,
              ),
            ),
          ),

          Expanded(
            child:
                Center(
              child:
                  Text(
                '$qty',
                style:
                    AppTextStyles
                        .body
                        .copyWith(
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          ),

          SizedBox(
            width: 36,
            height: 34,
            child:
                IconButton(
              padding:
                  EdgeInsets.zero,
              iconSize: 17,
              tooltip:
                  canAdd
                      ? 'Add'
                      : 'Maximum stock reached',
              color:
                  canAdd
                      ? AppColors
                          .primary
                      : AppColors
                          .textMuted,
              onPressed:
                  canAdd
                      ? () {
                          _addProductToCart(
                            product,
                          );
                        }
                      : null,
              icon:
                  const Icon(
                Icons.add,
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
      height: 34,
      width:
          double.infinity,
      decoration:
          BoxDecoration(
        color:
            AppColors
                .dangerLight,
        borderRadius:
            BorderRadius.circular(
          8,
        ),
      ),
      child:
          const Center(
        child:
            Text(
          'Out of stock',
          style:
              TextStyle(
            color:
                AppColors.danger,
            fontWeight:
                FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  

  // ============================================================
  // CURRENT SALE PANEL
  // ============================================================


  Widget _buildCurrentSalePanel() {
    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          // ======================================================
          // CART HEADER
          // ======================================================

          _buildCartHeader(),

          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.border,
          ),

          // ======================================================
          // CART
          //
          // Give the cart ALL remaining available space.
          // ======================================================

          Expanded(
            child: _buildCartSummary(),
          ),

          // ======================================================
          // PAYMENT
          // ======================================================

          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.border,
          ),

          // Compact payment section.
          //
          // The cart above remains Expanded, so it receives
          // everything that is not needed by this section.
          SizedBox(
            height: 180,
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: PaymentSelector(
                selectedMethod: paymentMethod,

                total: total,

                // ==================================================
                // POS SETTINGS
                //
                // Connects:
                //
                // POS Settings
                //      ↓
                // PosSettingsService.load()
                //      ↓
                // _posSettings
                //      ↓
                // PaymentSelector
                //
                // PaymentSelector can now determine which
                // payment buttons should be visible.
                // ==================================================

                posSettings: _posSettings ?? const PosSettings(),

                onMethodSelected: (method) {
                  if (!mounted) {
                    return;
                  }

                  final normalized =
                      _normalizePaymentMethod(method);

                  if (!_isPaymentMethodEnabled(
                    normalized,
                  )) {
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

                onPaymentConfirmed:
                    _completeSaleWithAmounts,
              ),
            ),
          ),

          // ======================================================
          // PROCESSING
          // ======================================================

          if (_processingSale)
            const LinearProgressIndicator(
              minHeight: 3,
              color: AppColors.success,
              backgroundColor: AppColors.successLight,
            ),
        ],
      ),
    );
  }



  // ============================================================
  // CART HEADER
  // ============================================================

  // ============================================================
  // CART HEADER
  // ============================================================

  Widget _buildCartHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        12,
        8,
        12,
        8,
      ),
      color: AppColors.surface,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 17,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Current Sale',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                Text(
                  totalItems == 0
                      ? 'No items added'
                      : '$totalItems item${totalItems == 1 ? '' : 's'}',
                  style: AppTextStyles.small.copyWith(
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          if (totalItems > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$totalItems',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
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

  Widget _buildCartSummary() {
    if (cart.isEmpty) {
      return Center(
        child:
            Padding(
          padding:
              const EdgeInsets.all(
            20,
          ),
          child:
              Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration:
                    const BoxDecoration(
                  color:
                      AppColors
                          .surfaceSoft,
                  shape:
                      BoxShape.circle,
                ),
                child:
                    const Icon(
                  Icons
                      .shopping_cart_outlined,
                  size: 27,
                  color:
                      AppColors
                          .textMuted,
                ),
              ),

              const SizedBox(
                height: 9,
              ),

              Text(
                'Cart is empty',
                style:
                    AppTextStyles
                        .body
                        .copyWith(
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(
                height: 3,
              ),

              Text(
                'Select products to begin a sale',
                textAlign:
                    TextAlign.center,
                style:
                    AppTextStyles.small,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding:
          const EdgeInsets.fromLTRB(
        12,
        10,
        12,
        10,
      ),
      itemCount:
          cart.length + 1,
      itemBuilder:
          (context, index) {
        if (index ==
            cart.length) {
          return _buildSubtotalCard();
        }

        final entry =
            cart.entries.elementAt(
          index,
        );

        final product =
            _findProduct(
          entry.key,
        );

        if (product == null) {
          return const SizedBox
              .shrink();
        }

        final qty =
            entry.value;

        final lineTotal =
            qty *
            product.sellingPrice
                .toInt();

        return _buildCartItem(
          product,
          qty,
          lineTotal,
        );
      },
    );
  }

  // ============================================================
  // CART ITEM
  // ============================================================

  Widget _buildCartItem(
    Product product,
    int qty,
    int lineTotal,
  ) {
    final canAdd =
        qty < product.stock;

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 7,
      ),
      padding:
          const EdgeInsets.all(
        8,
      ),
      decoration:
          BoxDecoration(
        color:
            AppColors.background,
        borderRadius:
            BorderRadius.circular(
          10,
        ),
        border:
            Border.all(
          color:
              AppColors.border,
        ),
      ),
      child:
          Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration:
                BoxDecoration(
              color:
                  AppColors
                      .surfaceSoft,
              borderRadius:
                  BorderRadius.circular(
                8,
              ),
            ),
            child:
                product.imagePath !=
                            null &&
                        product
                            .imagePath!
                            .isNotEmpty
                    ? ClipRRect(
                        borderRadius:
                            BorderRadius
                                .circular(
                          8,
                        ),
                        child:
                            Image.file(
                          File(
                            product
                                .imagePath!,
                          ),
                          fit:
                              BoxFit
                                  .contain,
                          errorBuilder:
                              (
                            _,
                            __,
                            ___,
                          ) {
                            return const Icon(
                              Icons
                                  .inventory_2_outlined,
                              size:
                                  20,
                              color:
                                  AppColors
                                      .primary,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons
                            .inventory_2_outlined,
                        size: 20,
                        color:
                            AppColors
                                .primary,
                      ),
          ),

          const SizedBox(
            width: 9,
          ),

          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      AppTextStyles
                          .body
                          .copyWith(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const SizedBox(
                  height: 2,
                ),

                Text(
                  '₦${_formatMoney(product.sellingPrice)} × $qty',
                  style:
                      AppTextStyles
                          .small
                          .copyWith(
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          Text(
            '₦${_formatMoney(lineTotal)}',
            style:
                AppTextStyles
                    .body
                    .copyWith(
              fontSize: 12,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(
            width: 3,
          ),

          SizedBox(
            width: 30,
            height: 30,
            child:
                IconButton(
              padding:
                  EdgeInsets.zero,
              iconSize: 17,
              tooltip:
                  'Remove one',
              color:
                  AppColors
                      .danger,
              onPressed: () {
                _removeProductFromCart(
                  product,
                );
              },
              icon:
                  const Icon(
                Icons
                    .remove_circle_outline,
              ),
            ),
          ),

          SizedBox(
            width: 20,
            child:
                Text(
              '$qty',
              textAlign:
                  TextAlign.center,
              style:
                  AppTextStyles
                      .body
                      .copyWith(
                fontSize: 12,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),

          SizedBox(
            width: 30,
            height: 30,
            child:
                IconButton(
              padding:
                  EdgeInsets.zero,
              iconSize: 17,
              tooltip:
                  canAdd
                      ? 'Add one'
                      : 'Maximum stock reached',
              color:
                  canAdd
                      ? AppColors
                          .success
                      : AppColors
                          .textMuted,
              onPressed:
                  canAdd
                      ? () {
                          _addProductToCart(
                            product,
                          );
                        }
                      : null,
              icon:
                  const Icon(
                Icons
                    .add_circle_outline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUBTOTAL
  // ============================================================

  Widget _buildSubtotalCard() {
    return Container(
      margin:
          const EdgeInsets.only(
        top: 4,
        bottom: 4,
      ),
      padding:
          const EdgeInsets
              .symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      decoration:
          BoxDecoration(
        color:
            AppColors
                .primaryLight,
        borderRadius:
            BorderRadius.circular(
          10,
        ),
      ),
      child:
          Row(
        children: [
          Text(
            'Subtotal',
            style:
                AppTextStyles
                    .body
                    .copyWith(
              fontSize: 13,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const Spacer(),

          Text(
            '₦${_formatMoney(total)}',
            style:
                AppTextStyles
                    .body
                    .copyWith(
              fontSize: 16,
              fontWeight:
                  FontWeight.w800,
              color:
                  AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ADD PRODUCT
  // ============================================================

  void _addProductToCart(
    Product product,
  ) {
    if (_processingSale) {
      return;
    }

    if (product.stock <= 0) {
      _showMessage(
        '${product.name} is out of stock.',
        isError: true,
      );
      return;
    }

    final currentQty =
        cart[product.id] ??
            0;

    if (currentQty >=
        product.stock) {
      _showMessage(
        'Only ${product.stock} units of '
        '${product.name} available.',
        isError: true,
      );
      return;
    }

    setState(() {
      cart[product.id] =
          currentQty + 1;
    });
  }

  // ============================================================
  // REMOVE PRODUCT
  // ============================================================

  void _removeProductFromCart(
    Product product,
  ) {
    if (_processingSale) {
      return;
    }

    final currentQty =
        cart[product.id] ??
            0;

    setState(() {
      if (currentQty <= 1) {
        cart.remove(
          product.id,
        );
      } else {
        cart[product.id] =
            currentQty - 1;
      }
    });
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
            const EdgeInsets
                .symmetric(
          horizontal: 6,
          vertical: 3,
        ),
        decoration:
            BoxDecoration(
          color:
              AppColors
                  .dangerLight,
          borderRadius:
              BorderRadius.circular(
            20,
          ),
        ),
        child:
            const Text(
          'OUT',
          style:
              TextStyle(
            color:
                AppColors.danger,
            fontSize: 9,
            fontWeight:
                FontWeight.w700,
          ),
        ),
      );
    }

    if (stock <= 5) {
      return Container(
        padding:
            const EdgeInsets
                .symmetric(
          horizontal: 6,
          vertical: 3,
        ),
        decoration:
            BoxDecoration(
          color:
              AppColors
                  .warningLight,
          borderRadius:
              BorderRadius.circular(
            20,
          ),
        ),
        child:
            Text(
          '$stock left',
          style:
              const TextStyle(
            color:
                AppColors.warning,
            fontSize: 9,
            fontWeight:
                FontWeight.w700,
          ),
        ),
      );
    }

    return Container(
      padding:
          const EdgeInsets
              .symmetric(
        horizontal: 6,
        vertical: 3,
      ),
      decoration:
          BoxDecoration(
        color:
            AppColors
                .successLight,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child:
          Text(
        '$stock',
        style:
            const TextStyle(
          color:
              AppColors.success,
          fontSize: 9,
          fontWeight:
              FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================================
  // MONEY
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