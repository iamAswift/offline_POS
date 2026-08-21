//lib/features/products/product_history_screen.dart
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const CentralBackButton(),
        title: Text(
          widget.productName,
          style: AppTextStyles.heading,
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
              padding: const EdgeInsets.fromLTRB(
                16,
                18,
                16,
                40,
              ),
              children: [
                _buildProductSummary(data),

                const SizedBox(height: 24),

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

                const SizedBox(height: 14),

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

  Widget _buildProductSummary(
    _HistoryData data,
  ) {
    return InventoryCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.primary,
                  size: 27,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.productName,
                      style: AppTextStyles.title,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Inventory activity',
                      style:
                          AppTextStyles.bodySecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Current Stock',
                    style: AppTextStyles.bodySecondary,
                  ),
                ),
                Text(
                  '${data.product.stock}',
                  style: AppTextStyles.price.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

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
    );
  }

  Widget _summaryItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: color,
          size: 19,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTextStyles.title.copyWith(
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: AppTextStyles.small,
        ),
      ],
    );
  }

  Widget _buildMovementList(
    List<StockMovementLedgerRow> movements,
  ) {
    return Column(
      children: movements.map(
        _buildMovementCard,
      ).toList(),
    );
  }

  Widget _buildMovementCard(
    StockMovementLedgerRow item,
  ) {
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
      movementIcon =
          Icons.south_west;

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
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: InventoryCard(
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
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
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          movementTitle,
                          style:
                              AppTextStyles.title.copyWith(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        quantityText,
                        style:
                            AppTextStyles.price.copyWith(
                          fontSize: 16,
                          color: movementColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Text(
                    '$dateText • $timeText',
                    style:
                        AppTextStyles.small,
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child:
                            _balanceBox(
                          'Before',
                          '${item.balanceBefore}',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child:
                            _balanceBox(
                          'After',
                          '${item.balanceAfter}',
                        ),
                      ),
                    ],
                  ),

                  if (isIncoming) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.local_shipping_outlined,
                          size: 16,
                          color:
                              AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            supplierName,
                            style:
                                AppTextStyles.bodySecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Unit cost: ₦'
                      '${movement.unitPrice.toStringAsFixed(2)}',
                      style:
                          AppTextStyles.small,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _balanceBox(
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.small,
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

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