//lib/features/products/product_history_screen.dart
import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/styles.dart';
import '../../core/widgets/back_button.dart';
import '../../core/widgets/inventory_widgets.dart';
import '../../database/app_database.dart';
import '../../database/daos/product_dao.dart';
import '../../database/daos/stock_movement_dao.dart';

class ProductHistoryScreen extends StatefulWidget {
  final int productId;
  final String productName;

  const ProductHistoryScreen({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  State<ProductHistoryScreen> createState() =>
      _ProductHistoryScreenState();
}

class _ProductHistoryScreenState
    extends State<ProductHistoryScreen> {
  late final StockMovementDao stockDao;
  late final ProductDao productDao;

  String _filter = 'All';

  @override
  void initState() {
    super.initState();

    final db = getDatabase();

    stockDao = StockMovementDao(db);
    productDao = ProductDao(db);
  }

  // ============================================================
  // RESPONSIVE HELPERS
  // ============================================================

  double _pagePadding(BuildContext context) {
    final responsive = context.responsive;

    if (responsive.isCompact) {
      return 12;
    }

    if (responsive.isTablet) {
      return 16;
    }

    return 20;
  }

  double _sectionSpacing(BuildContext context) {
    final responsive = context.responsive;

    if (responsive.isCompact) {
      return 16;
    }

    if (responsive.isTablet) {
      return 20;
    }

    return 24;
  }

  double _cardPadding(BuildContext context) {
    final responsive = context.responsive;

    if (responsive.isCompact) {
      return 12;
    }

    if (responsive.isTablet) {
      return 14;
    }

    return 16;
  }

  double _iconBoxSize(BuildContext context) {
    final responsive = context.responsive;

    if (responsive.isCompact) {
      return 42;
    }

    if (responsive.isTablet) {
      return 46;
    }

    return 50;
  }

  double _movementIconSize(BuildContext context) {
    final responsive = context.responsive;

    if (responsive.isCompact) {
      return 38;
    }

    if (responsive.isTablet) {
      return 42;
    }

    return 44;
  }

  // ============================================================
  // LOAD HISTORY
  // ============================================================

  Future<_HistoryData> _loadHistory() async {
    final product =
        await productDao.getProductById(
      widget.productId,
    );

    final movements =
        await stockDao.getProductLedger(
      widget.productId,
    );

    int received = 0;
    int sold = 0;
    int adjustments = 0;

    for (final item in movements) {
      final type =
          item.movement.type.toLowerCase();

      if (type == 'purchase' ||
          type == 'return') {
        received += item.movement.quantity;
      } else if (type == 'sale') {
        sold += item.movement.quantity;
      } else if (type == 'adjustment') {
        adjustments += item.movement.quantity;
      }
    }

    return _HistoryData(
      product: product,
      movements: movements,
      received: received,
      sold: sold,
      adjustments: adjustments,
    );
  }

  // ============================================================
  // FILTER
  // ============================================================

  List<StockMovementLedgerRow> _applyFilter(
    List<StockMovementLedgerRow> movements,
  ) {
    switch (_filter) {
      case 'Received':
        return movements.where((item) {
          final type =
              item.movement.type.toLowerCase();

          return type == 'purchase' ||
              type == 'return';
        }).toList();

      case 'Sold':
        return movements.where((item) {
          return item.movement.type.toLowerCase() ==
              'sale';
        }).toList();

      case 'Adjustments':
        return movements.where((item) {
          return item.movement.type.toLowerCase() ==
              'adjustment';
        }).toList();

      default:
        return movements;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: AppColors.background,

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        leading: const CentralBackButton(),
        title: Text(
          widget.productName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.heading.copyWith(
            fontSize: responsive.isCompact ? 17 : 20,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.filter_list,
            ),
            onSelected: (value) {
              setState(() {
                _filter = value;
              });
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'All',
                child: Text('All Movements'),
              ),
              PopupMenuItem(
                value: 'Received',
                child: Text('Stock Received'),
              ),
              PopupMenuItem(
                value: 'Sold',
                child: Text('Sales'),
              ),
              PopupMenuItem(
                value: 'Adjustments',
                child: Text('Adjustments'),
              ),
            ],
          ),
        ],
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: FutureBuilder<_HistoryData>(
        future: _loadHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return InventoryEmptyState(
              icon: Icons.error_outline,
              title: 'Unable to load history',
              message:
                  'There was a problem loading this product ledger.',
              action: ElevatedButton.icon(
                onPressed: () {
                  setState(() {});
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const InventoryEmptyState(
              icon: Icons.history,
              title: 'No history available',
              message:
                  'Inventory movements will appear here.',
            );
          }

          final data = snapshot.data!;
          final movements =
              _applyFilter(data.movements);

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
              await _loadHistory();
            },
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                _pagePadding(context),
                responsive.isCompact ? 12 : 16,
                _pagePadding(context),
                responsive.isCompact ? 24 : 32,
              ),
              children: [
                _buildProductSummary(data),

                SizedBox(
                  height: _sectionSpacing(context),
                ),

                InventorySectionTitle(
                  title: 'Stock Ledger',
                  subtitle:
                      'Every inventory movement for this product.',
                  trailing: InventoryStatusChip(
                    label: _filter,
                    color: AppColors.primary,
                    icon: Icons.filter_list,
                  ),
                ),

                const SizedBox(height: 10),

                if (movements.isEmpty)
                  const InventoryEmptyState(
                    icon: Icons.history,
                    title: 'No movements found',
                    message:
                        'There are no movements matching this filter.',
                  )
                else
                  _buildMovementList(movements),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // PRODUCT SUMMARY
  // ============================================================

  Widget _buildProductSummary(
    _HistoryData data,
  ) {
    final responsive = context.responsive;
    final iconSize = _iconBoxSize(context);
    final cardPadding = _cardPadding(context);

    return InventoryCard(
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ======================================================
            // PRODUCT HEADER
            // ======================================================

            Row(
              children: [
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius:
                        BorderRadius.circular(
                      responsive.isCompact ? 10 : 12,
                    ),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.primary,
                    size:
                        responsive.isCompact ? 22 : 25,
                  ),
                ),

                SizedBox(
                  width:
                      responsive.isCompact ? 10 : 12,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.productName,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            AppTextStyles.title.copyWith(
                          fontSize:
                              responsive.isCompact
                                  ? 14
                                  : 16,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        'Inventory activity',
                        style:
                            AppTextStyles.small.copyWith(
                          fontSize:
                              responsive.isCompact
                                  ? 10
                                  : 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(
              height:
                  responsive.isCompact ? 14 : 18,
            ),

            // ======================================================
            // CURRENT STOCK
            // ======================================================

            Container(
              padding: EdgeInsets.symmetric(
                horizontal:
                    responsive.isCompact ? 10 : 12,
                vertical:
                    responsive.isCompact ? 9 : 11,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius:
                    BorderRadius.circular(
                  responsive.isCompact ? 9 : 10,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.primary,
                    size:
                        responsive.isCompact ? 18 : 20,
                  ),

                  SizedBox(
                    width:
                        responsive.isCompact ? 7 : 9,
                  ),

                  Expanded(
                    child: Text(
                      'Current Stock',
                      style:
                          AppTextStyles.bodySecondary.copyWith(
                        fontSize:
                            responsive.isCompact
                                ? 11
                                : 12,
                      ),
                    ),
                  ),

                  Text(
                    '${data.product.stock}',
                    style:
                        AppTextStyles.price.copyWith(
                      fontSize:
                          responsive.isCompact
                              ? 15
                              : 17,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height:
                  responsive.isCompact ? 14 : 16,
            ),

            // ======================================================
            // SUMMARY STATS
            // ======================================================

            Row(
              children: [
                Expanded(
                  child: _summaryItem(
                    'Received',
                    '+${data.received}',
                    Icons.south_west,
                    AppColors.success,
                  ),
                ),

                Expanded(
                  child: _summaryItem(
                    'Sold',
                    '-${data.sold}',
                    Icons.north_east,
                    AppColors.danger,
                  ),
                ),

                Expanded(
                  child: _summaryItem(
                    'Adjustments',
                    '${data.adjustments}',
                    Icons.sync_alt,
                    AppColors.warning,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY ITEM
  // ============================================================

  Widget _summaryItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final responsive = context.responsive;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: color,
          size:
              responsive.isCompact ? 16 : 18,
        ),

        SizedBox(
          height:
              responsive.isCompact ? 4 : 5,
        ),

        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style:
              AppTextStyles.title.copyWith(
            color: color,
            fontSize:
                responsive.isCompact ? 13 : 15,
          ),
        ),

        const SizedBox(height: 1),

        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style:
              AppTextStyles.small.copyWith(
            fontSize:
                responsive.isCompact ? 9 : 10,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MOVEMENT LIST
  // ============================================================

  Widget _buildMovementList(
    List<StockMovementLedgerRow> movements,
  ) {
    return Column(
      children: movements.map(
        _buildMovementCard,
      ).toList(),
    );
  }

  // ============================================================
  // MOVEMENT CARD
  // ============================================================

  Widget _buildMovementCard(
    StockMovementLedgerRow item,
  ) {
    final responsive = context.responsive;
    final cardPadding = _cardPadding(context);

    final movement = item.movement;
    final type = movement.type.toLowerCase();

    final isIncoming =
        type == 'purchase' || type == 'return';

    final isSale = type == 'sale';

    final isAdjustment =
        type == 'adjustment';

    late final Color movementColor;
    late final IconData movementIcon;
    late final String movementTitle;
    late final String quantityText;

    if (isIncoming) {
      movementColor = AppColors.success;
      movementIcon = Icons.south_west;

      movementTitle = type == 'return'
          ? 'Stock Returned'
          : 'Stock Received';

      quantityText =
          '+${movement.quantity}';
    } else if (isSale) {
      movementColor = AppColors.danger;
      movementIcon =
          Icons.shopping_cart_outlined;

      movementTitle = 'Sale';

      quantityText =
          '-${movement.quantity}';
    } else if (isAdjustment) {
      movementColor = AppColors.warning;
      movementIcon = Icons.sync_alt;

      movementTitle = 'Stock Adjustment';

      quantityText =
          '${movement.quantity}';
    } else {
      movementColor =
          AppColors.textSecondary;

      movementIcon =
          Icons.swap_horiz;

      movementTitle =
          movement.type.toUpperCase();

      quantityText =
          '${movement.quantity}';
    }

    final supplierName =
        item.supplier?.name ?? 'N/A';

    final date =
        movement.date.toLocal();

    final dateText =
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';

    final timeText =
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: EdgeInsets.only(
        bottom:
            responsive.isCompact ? 8 : 10,
      ),
      child: InventoryCard(
        child: Padding(
          padding: EdgeInsets.all(cardPadding),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ======================================================
              // MOVEMENT ICON
              // ======================================================

              Container(
                width:
                    _movementIconSize(context),
                height:
                    _movementIconSize(context),
                decoration: BoxDecoration(
                  color:
                      movementColor.withValues(
                    alpha: 0.10,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  movementIcon,
                  color: movementColor,
                  size:
                      responsive.isCompact
                          ? 18
                          : 20,
                ),
              ),

              SizedBox(
                width:
                    responsive.isCompact
                        ? 9
                        : 12,
              ),

              // ======================================================
              // MOVEMENT CONTENT
              // ======================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // TITLE + QUANTITY
                    // ==================================================

                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            movementTitle,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style:
                                AppTextStyles.title.copyWith(
                              fontSize:
                                  responsive.isCompact
                                      ? 12
                                      : 14,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Text(
                          quantityText,
                          style:
                              AppTextStyles.price.copyWith(
                            fontSize:
                                responsive.isCompact
                                    ? 14
                                    : 16,
                            color: movementColor,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                      height:
                          responsive.isCompact
                              ? 3
                              : 4,
                    ),

                    // ==================================================
                    // DATE
                    // ==================================================

                    Text(
                      '$dateText • $timeText',
                      style:
                          AppTextStyles.small.copyWith(
                        fontSize:
                            responsive.isCompact
                                ? 9
                                : 10,
                      ),
                    ),

                    SizedBox(
                      height:
                          responsive.isCompact
                              ? 8
                              : 10,
                    ),

                    // ==================================================
                    // BEFORE / AFTER
                    // ==================================================

                    Row(
                      children: [
                        Expanded(
                          child: _balanceBox(
                            'Before',
                            '${item.balanceBefore}',
                          ),
                        ),

                        SizedBox(
                          width:
                              responsive.isCompact
                                  ? 6
                                  : 8,
                        ),

                        Expanded(
                          child: _balanceBox(
                            'After',
                            '${item.balanceAfter}',
                          ),
                        ),
                      ],
                    ),

                    // ==================================================
                    // SUPPLIER
                    // ==================================================

                    if (isIncoming) ...[
                      SizedBox(
                        height:
                            responsive.isCompact
                                ? 8
                                : 10,
                      ),

                      Row(
                        children: [
                          Icon(
                            Icons
                                .local_shipping_outlined,
                            size:
                                responsive.isCompact
                                    ? 14
                                    : 15,
                            color:
                                AppColors.textSecondary,
                          ),

                          const SizedBox(width: 5),

                          Expanded(
                            child: Text(
                              supplierName,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style:
                                  AppTextStyles.bodySecondary
                                      .copyWith(
                                fontSize:
                                    responsive.isCompact
                                        ? 10
                                        : 11,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 3),

                      Text(
                        'Unit cost: ₦'
                        '${movement.unitPrice.toStringAsFixed(2)}',
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            AppTextStyles.small.copyWith(
                          fontSize:
                              responsive.isCompact
                                  ? 9
                                  : 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BALANCE BOX
  // ============================================================

  Widget _balanceBox(
    String label,
    String value,
  ) {
    final responsive = context.responsive;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal:
            responsive.isCompact ? 7 : 9,
        vertical:
            responsive.isCompact ? 6 : 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius:
            BorderRadius.circular(
          responsive.isCompact ? 6 : 8,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style:
                  AppTextStyles.small.copyWith(
                fontSize:
                    responsive.isCompact
                        ? 9
                        : 10,
              ),
            ),
          ),

          const SizedBox(width: 4),

          Text(
            value,
            style:
                AppTextStyles.body.copyWith(
              fontSize:
                  responsive.isCompact
                      ? 10
                      : 11,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// HISTORY DATA
// ================================================================

class _HistoryData {
  final Product product;
  final List<StockMovementLedgerRow> movements;
  final int received;
  final int sold;
  final int adjustments;

  _HistoryData({
    required this.product,
    required this.movements,
    required this.received,
    required this.sold,
    required this.adjustments,
  });
}