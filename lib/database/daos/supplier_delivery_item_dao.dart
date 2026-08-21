//lib/database/daos/supplier_delivery_item_dao.dart


import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/supplier_delivery_item_table.dart';
import '../tables/supplier_delivery_table.dart';
import '../tables/product_table.dart';

part 'supplier_delivery_item_dao.g.dart';

@DriftAccessor(
  tables: [
    SupplierDeliveryItems,
    SupplierDeliveries,
    Products,
  ],
)
class SupplierDeliveryItemDao
    extends DatabaseAccessor<AppDatabase>
    with _$SupplierDeliveryItemDaoMixin {
  SupplierDeliveryItemDao(super.db);

  // ============================================================
  // INSERT
  // ============================================================

  Future<int> insertItem(
    SupplierDeliveryItemsCompanion item,
  ) {
    return into(supplierDeliveryItems).insert(item);
  }

  // ============================================================
  // GET BY ID
  // ============================================================

  Future<SupplierDeliveryItem?> getItemById(
    int id,
  ) {
    return (select(supplierDeliveryItems)
          ..where((i) => i.id.equals(id)))
        .getSingleOrNull();
  }

  // ============================================================
  // GET ALL ITEMS FOR DELIVERY
  // ============================================================

  Future<List<SupplierDeliveryItem>> getItemsForDelivery(
    int deliveryId,
  ) {
    return (select(supplierDeliveryItems)
          ..where(
            (i) => i.deliveryId.equals(deliveryId),
          )
          ..orderBy([
            (i) => OrderingTerm.asc(i.id),
          ]))
        .get();
  }

  // ============================================================
  // GET DELIVERY ITEMS WITH PRODUCT
  // ============================================================

  Future<List<SupplierDeliveryItemWithProduct>>
      getItemsForDeliveryWithProducts(
    int deliveryId,
  ) {
    final query = select(supplierDeliveryItems).join([
      innerJoin(
        products,
        products.id.equalsExp(
          supplierDeliveryItems.productId,
        ),
      ),
    ])
      ..where(
        supplierDeliveryItems.deliveryId.equals(
          deliveryId,
        ),
      )
      ..orderBy([
        OrderingTerm.asc(
          supplierDeliveryItems.id,
        ),
      ]);

    return query.map((row) {
      final item = row.readTable(
        supplierDeliveryItems,
      );

      final product = row.readTable(
        products,
      );

      return SupplierDeliveryItemWithProduct(
        item: item,
        product: product,
      );
    }).get();
  }

  // ============================================================
  // UPDATE
  // ============================================================

  Future<bool> updateItem(
    SupplierDeliveryItem item,
  ) {
    return update(
      supplierDeliveryItems,
    ).replace(item);
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<int> deleteItem(
    int id,
  ) {
    return (delete(supplierDeliveryItems)
          ..where((i) => i.id.equals(id)))
        .go();
  }

  // ============================================================
  // DELETE ALL ITEMS FOR DELIVERY
  // ============================================================

  Future<int> deleteItemsForDelivery(
    int deliveryId,
  ) {
    return (delete(supplierDeliveryItems)
          ..where(
            (i) => i.deliveryId.equals(deliveryId),
          ))
        .go();
  }

  // ============================================================
  // TOTAL DELIVERY COST
  // ============================================================

  Future<double> getDeliveryTotal(
    int deliveryId,
  ) async {
    final result = await customSelect(
      '''
      SELECT
        COALESCE(SUM(total_cost), 0) AS total_cost
      FROM supplier_delivery_items
      WHERE delivery_id = ?
      ''',
      variables: [
        Variable.withInt(deliveryId),
      ],
      readsFrom: {
        supplierDeliveryItems,
      },
    ).getSingle();

    final value = result.data['total_cost'];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  // ============================================================
  // TOTAL QUANTITY FOR DELIVERY
  // ============================================================

  Future<int> getDeliveryTotalQuantity(
    int deliveryId,
  ) async {
    final result = await customSelect(
      '''
      SELECT
        COALESCE(SUM(quantity), 0) AS total_quantity
      FROM supplier_delivery_items
      WHERE delivery_id = ?
      ''',
      variables: [
        Variable.withInt(deliveryId),
      ],
      readsFrom: {
        supplierDeliveryItems,
      },
    ).getSingle();

    final value =
        result.data['total_quantity'];

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  // ============================================================
  // PRODUCT DELIVERY HISTORY
  // ============================================================

  Future<List<SupplierDeliveryItem>>
      getItemsForProduct(
    int productId,
  ) {
    return (select(supplierDeliveryItems)
          ..where(
            (i) => i.productId.equals(productId),
          )
          ..orderBy([
            (i) => OrderingTerm(
                  expression: i.id,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
  }
}

// ============================================================
// ITEM + PRODUCT
// ============================================================

class SupplierDeliveryItemWithProduct {
  final SupplierDeliveryItem item;
  final Product product;

  const SupplierDeliveryItemWithProduct({
    required this.item,
    required this.product,
  });
}