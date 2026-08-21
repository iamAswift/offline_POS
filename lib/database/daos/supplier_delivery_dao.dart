// lib/database/daos/supplier_delivery_dao.dart

import 'package:drift/drift.dart';

import '../app_database.dart';

import '../tables/supplier_delivery_table.dart';
import '../tables/supplier_delivery_item_table.dart';
import '../tables/supplier_table.dart';
import '../tables/product_table.dart';
import '../tables/stock_movement_table.dart';

part 'supplier_delivery_dao.g.dart';

@DriftAccessor(
  tables: [
    SupplierDeliveries,
    SupplierDeliveryItems,
    Suppliers,
    Products,
    StockMovements,
  ],
)
class SupplierDeliveryDao extends DatabaseAccessor<AppDatabase>
    with _$SupplierDeliveryDaoMixin {
  SupplierDeliveryDao(super.db);

  // ============================================================
  // CREATE DELIVERY HEADER
  // ============================================================

  Future<int> insertDelivery(
    SupplierDeliveriesCompanion delivery,
  ) {
    return into(supplierDeliveries).insert(delivery);
  }

  // ============================================================
  // GET DELIVERY BY ID
  // ============================================================

  Future<SupplierDelivery?> getDeliveryById(int id) {
    return (select(supplierDeliveries)
          ..where((d) => d.id.equals(id)))
        .getSingleOrNull();
  }

  // ============================================================
  // GET ALL DELIVERIES
  // ============================================================

  Future<List<SupplierDelivery>> getAllDeliveries() {
    return (select(supplierDeliveries)
          ..orderBy([
            (d) => OrderingTerm(
                  expression: d.deliveryDate,
                  mode: OrderingMode.desc,
                ),
            (d) => OrderingTerm(
                  expression: d.id,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
  }

  // ============================================================
  // GET DELIVERIES FOR SUPPLIER
  // ============================================================

  Future<List<SupplierDelivery>> getDeliveriesForSupplier(
    int supplierId,
  ) {
    return (select(supplierDeliveries)
          ..where((d) => d.supplierId.equals(supplierId))
          ..orderBy([
            (d) => OrderingTerm(
                  expression: d.deliveryDate,
                  mode: OrderingMode.desc,
                ),
            (d) => OrderingTerm(
                  expression: d.id,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
  }

  // ============================================================
  // GET DELIVERIES WITH SUPPLIER
  // ============================================================

  Future<List<SupplierDeliveryWithSupplier>>
      getDeliveriesWithSuppliers() {
    final query = select(supplierDeliveries).join([
      innerJoin(
        suppliers,
        suppliers.id.equalsExp(
          supplierDeliveries.supplierId,
        ),
      ),
    ])
      ..orderBy([
        OrderingTerm(
          expression: supplierDeliveries.deliveryDate,
          mode: OrderingMode.desc,
        ),
        OrderingTerm(
          expression: supplierDeliveries.id,
          mode: OrderingMode.desc,
        ),
      ]);

    return query.map((row) {
      return SupplierDeliveryWithSupplier(
        delivery: row.readTable(supplierDeliveries),
        supplier: row.readTable(suppliers),
      );
    }).get();
  }

  // ============================================================
  // UPDATE DELIVERY
  // ============================================================

  Future<bool> updateDelivery(
    SupplierDelivery delivery,
  ) {
    return update(supplierDeliveries).replace(delivery);
  }

  // ============================================================
  // DELETE DELIVERY
  // ============================================================

  Future<int> deleteDelivery(int id) async {
    return transaction(() async {
      // ==========================================================
      // VERIFY DELIVERY EXISTS
      // ==========================================================

      final delivery = await (select(supplierDeliveries)
            ..where((d) => d.id.equals(id)))
          .getSingleOrNull();

      if (delivery == null) {
        throw Exception(
          'Supplier delivery with ID $id was not found.',
        );
      }

      // ==========================================================
      // DELETE PAYMENT ALLOCATIONS
      // ==========================================================

      await customStatement(
        '''
        DELETE FROM supplier_payment_allocations
        WHERE delivery_id = ?
        ''',
        [id],
      );

      // ==========================================================
      // DELETE STOCK MOVEMENTS
      //
      // These are now safely identifiable through deliveryId.
      //
      // IMPORTANT:
      // This does NOT restore product stock.
      //
      // Therefore this method must only be used for deliveries
      // that have NOT been posted/received into stock.
      // ==========================================================

      await (delete(stockMovements)
            ..where((m) => m.deliveryId.equals(id)))
          .go();

      // ==========================================================
      // DELETE DELIVERY ITEMS
      // ==========================================================

      await (delete(supplierDeliveryItems)
            ..where((i) => i.deliveryId.equals(id)))
          .go();

      // ==========================================================
      // DELETE DELIVERY HEADER
      // ==========================================================

      return (delete(supplierDeliveries)
            ..where((d) => d.id.equals(id)))
          .go();
    });
  }

  // ============================================================
  // ADD DELIVERY ITEM
  // ============================================================

  Future<int> insertDeliveryItem(
    SupplierDeliveryItemsCompanion item,
  ) {
    return into(supplierDeliveryItems).insert(item);
  }

  // ============================================================
  // GET DELIVERY ITEMS
  // ============================================================

  Future<List<SupplierDeliveryItem>> getDeliveryItems(
    int deliveryId,
  ) {
    return (select(supplierDeliveryItems)
          ..where((i) => i.deliveryId.equals(deliveryId))
          ..orderBy([
            (i) => OrderingTerm.asc(i.id),
          ]))
        .get();
  }

  // ============================================================
  // GET DELIVERY ITEMS WITH PRODUCTS
  // ============================================================

  Future<List<SupplierDeliveryItemWithProduct>>
      getDeliveryItemsWithProducts(
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
      return SupplierDeliveryItemWithProduct(
        item: row.readTable(supplierDeliveryItems),
        product: row.readTable(products),
      );
    }).get();
  }

  // ============================================================
  // DELETE DELIVERY ITEM
  // ============================================================

  Future<int> deleteDeliveryItem(
    int itemId,
  ) {
    return (delete(supplierDeliveryItems)
          ..where((i) => i.id.equals(itemId)))
        .go();
  }

  // ============================================================
  // SUPPLIER PURCHASE TOTAL
  // ============================================================

  Future<double> getSupplierPurchaseTotal(
    int supplierId,
  ) async {
    final result = await customSelect(
      '''
      SELECT
        COALESCE(SUM(total_amount), 0)
        AS total_purchases
      FROM supplier_deliveries
      WHERE supplier_id = ?
      ''',
      variables: [
        Variable.withInt(supplierId),
      ],
      readsFrom: {
        supplierDeliveries,
      },
    ).getSingle();

    return _readDouble(
      result.data['total_purchases'],
    );
  }

  // ============================================================
  // ALL SUPPLIER PURCHASE TOTAL
  // ============================================================

  Future<double> getAllPurchaseTotal() async {
    final result = await customSelect(
      '''
      SELECT
        COALESCE(SUM(total_amount), 0)
        AS total_purchases
      FROM supplier_deliveries
      ''',
      readsFrom: {
        supplierDeliveries,
      },
    ).getSingle();

    return _readDouble(
      result.data['total_purchases'],
    );
  }

  // ============================================================
  // DELIVERY COUNT
  // ============================================================

  Future<int> getDeliveryCount(
    int supplierId,
  ) async {
    final expression =
        supplierDeliveries.id.count();

    final query = selectOnly(supplierDeliveries)
      ..addColumns([expression])
      ..where(
        supplierDeliveries.supplierId.equals(
          supplierId,
        ),
      );

    final row = await query.getSingle();

    return row.read(expression) ?? 0;
  }

  // ============================================================
  // TOTAL ITEMS IN DELIVERY
  // ============================================================

  Future<int> getDeliveryItemCount(
    int deliveryId,
  ) async {
    final expression =
        supplierDeliveryItems.id.count();

    final query = selectOnly(supplierDeliveryItems)
      ..addColumns([expression])
      ..where(
        supplierDeliveryItems.deliveryId.equals(
          deliveryId,
        ),
      );

    final row = await query.getSingle();

    return row.read(expression) ?? 0;
  }

  // ============================================================
  // COMPLETE DELIVERY
  // ============================================================
  //
  // This is the main receiving operation.
  //
  // ONE transaction performs:
  //
  // 1. Delivery header
  // 2. Delivery items
  // 3. Stock movements
  // 4. Product stock updates
  // 5. Product cost-price updates
  // 6. Product expiry-date updates
  //
  // If anything fails, the entire operation rolls back.
  //
  // ============================================================

  Future<int> receiveDelivery({
    required SupplierDeliveriesCompanion delivery,
    required List<SupplierDeliveryItemsCompanion> items,
  }) async {
    // ------------------------------------------------------------
    // BASIC VALIDATION
    // ------------------------------------------------------------

    if (!delivery.supplierId.present) {
      throw Exception(
        'A supplier is required for the delivery.',
      );
    }

    if (delivery.supplierId.value <= 0) {
      throw Exception(
        'Invalid supplier selected.',
      );
    }

    if (items.isEmpty) {
      throw Exception(
        'A delivery must contain at least one item.',
      );
    }

    // ------------------------------------------------------------
    // VALIDATE DELIVERY TOTAL
    // ------------------------------------------------------------

    final calculatedTotal =
        calculateDeliveryTotal(items);

    if (calculatedTotal < 0) {
      throw Exception(
        'Delivery total cannot be negative.',
      );
    }

    // ------------------------------------------------------------
    // TRANSACTION
    // ------------------------------------------------------------

    return transaction(() async {
      // ==========================================================
      // VERIFY SUPPLIER
      // ==========================================================

      final supplier = await (select(suppliers)
            ..where(
              (s) => s.id.equals(
                delivery.supplierId.value,
              ),
            ))
          .getSingleOrNull();

      if (supplier == null) {
        throw Exception(
          'Supplier with ID '
          '${delivery.supplierId.value} '
          'was not found.',
        );
      }

      // ==========================================================
      // CREATE DELIVERY HEADER
      // ==========================================================

      final deliveryId =
          await into(supplierDeliveries).insert(
        delivery,
      );

      // ==========================================================
      // PROCESS DELIVERY ITEMS
      // ==========================================================

      for (final originalItem in items) {
        // --------------------------------------------------------
        // REQUIRED VALUES
        // --------------------------------------------------------

        if (!originalItem.productId.present) {
          throw Exception(
            'A product is required for every delivery item.',
          );
        }

        if (!originalItem.quantity.present) {
          throw Exception(
            'Quantity is required for every delivery item.',
          );
        }

        if (!originalItem.unitCost.present) {
          throw Exception(
            'Unit cost is required for every delivery item.',
          );
        }

        if (!originalItem.totalCost.present) {
          throw Exception(
            'Total cost is required for every delivery item.',
          );
        }

        // --------------------------------------------------------
        // READ VALUES
        // --------------------------------------------------------

        final productId =
            originalItem.productId.value;

        final quantity =
            originalItem.quantity.value;

        final unitCost =
            originalItem.unitCost.value;

        final totalCost =
            originalItem.totalCost.value;

        final expiryDate =
            originalItem.expiryDate.value;

        // --------------------------------------------------------
        // VALIDATE PRODUCT
        // --------------------------------------------------------

        if (productId <= 0) {
          throw Exception(
            'Invalid product selected.',
          );
        }

        // --------------------------------------------------------
        // VALIDATE QUANTITY
        // --------------------------------------------------------

        if (quantity <= 0) {
          throw Exception(
            'Delivery quantity must be greater than zero.',
          );
        }

        // --------------------------------------------------------
        // VALIDATE COST
        // --------------------------------------------------------

        if (unitCost < 0) {
          throw Exception(
            'Unit cost cannot be negative.',
          );
        }

        if (totalCost < 0) {
          throw Exception(
            'Total cost cannot be negative.',
          );
        }

        // --------------------------------------------------------
        // VERIFY TOTAL COST
        //
        // Use a small tolerance for floating-point arithmetic.
        // --------------------------------------------------------

        final expectedTotal =
            quantity * unitCost;

        if ((totalCost - expectedTotal).abs() >
            0.000001) {
          throw Exception(
            'Invalid total cost for product ID '
            '$productId. '
            'Expected ${expectedTotal.toStringAsFixed(2)}, '
            'received ${totalCost.toStringAsFixed(2)}.',
          );
        }

        // --------------------------------------------------------
        // LOAD PRODUCT
        // --------------------------------------------------------

        final product = await (select(products)
              ..where(
                (p) => p.id.equals(productId),
              ))
            .getSingleOrNull();

        if (product == null) {
          throw Exception(
            'Product with ID $productId '
            'was not found.',
          );
        }

        // ========================================================
        // INSERT DELIVERY ITEM
        // ========================================================

        final item =
            originalItem.copyWith(
          deliveryId: Value(deliveryId),
        );

        await into(
          supplierDeliveryItems,
        ).insert(item);

        // ========================================================
        // CREATE STOCK MOVEMENT
        // ========================================================

        await into(stockMovements).insert(
          StockMovementsCompanion(
            productId: Value(productId),
            supplierId: Value(
              delivery.supplierId.value,
            ),
            deliveryId: Value(deliveryId),
            type: const Value('purchase'),
            quantity: Value(quantity),
            unitPrice: Value(unitCost),
            date: delivery.deliveryDate,
          ),
        );

        // ========================================================
        // UPDATE PRODUCT STOCK
        // ========================================================

        final newStock =
            product.stock + quantity;

        if (newStock < 0) {
          throw Exception(
            'Stock cannot become negative for '
            '${product.name}.',
          );
        }

        // ========================================================
        // UPDATE PRODUCT
        // ========================================================

        await (update(products)
              ..where(
                (p) => p.id.equals(productId),
              ))
            .write(
          ProductsCompanion(
            stock: Value(newStock),

            // Latest supplier purchase price.
            costPrice: Value(unitCost),

            // Preserve expiry only when supplied.
            expiryDate: expiryDate != null
                ? Value(expiryDate)
                : const Value.absent(),
          ),
        );
      }

      // ==========================================================
      // RETURN DELIVERY ID
      // ==========================================================

      return deliveryId;
    });
  }

  // ============================================================
  // CALCULATE DELIVERY TOTAL FROM ITEMS
  // ============================================================

  double calculateDeliveryTotal(
    List<SupplierDeliveryItemsCompanion> items,
  ) {
    double total = 0;

    for (final item in items) {
      if (!item.totalCost.present) {
        throw Exception(
          'Every delivery item must have a total cost.',
        );
      }

      total += item.totalCost.value;
    }

    return total;
  }

  // ============================================================
  // HELPER
  // ============================================================

  double _readDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}

// ================================================================
// DELIVERY + SUPPLIER
// ================================================================

class SupplierDeliveryWithSupplier {
  final SupplierDelivery delivery;
  final Supplier supplier;

  const SupplierDeliveryWithSupplier({
    required this.delivery,
    required this.supplier,
  });
}

// ================================================================
// DELIVERY ITEM + PRODUCT
// ================================================================

class SupplierDeliveryItemWithProduct {
  final SupplierDeliveryItem item;
  final Product product;

  const SupplierDeliveryItemWithProduct({
    required this.item,
    required this.product,
  });
}