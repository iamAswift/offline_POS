// lib/database/daos/stock_movement_dao.dart

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/stock_movement_table.dart';
import '../tables/product_table.dart';
import '../tables/supplier_table.dart';

part 'stock_movement_dao.g.dart';

@DriftAccessor(
  tables: [
    StockMovements,
    Products,
    Suppliers,
  ],
)
class StockMovementDao extends DatabaseAccessor<AppDatabase>
    with _$StockMovementDaoMixin {
  StockMovementDao(super.db);

  // ============================================================
  // STOCK UPDATE
  // ============================================================

  Future<void> _updateStock(
    int productId,
    int delta,
  ) async {
    final product = await (select(products)
          ..where((p) => p.id.equals(productId)))
        .getSingle();

    final newStock = product.stock + delta;

    if (newStock < 0) {
      throw Exception(
        'Stock cannot become negative for ${product.name}.',
      );
    }

    await (update(products)
          ..where((p) => p.id.equals(productId)))
        .write(
      ProductsCompanion(
        stock: Value(newStock),
      ),
    );
  }

  // ============================================================
  // CALCULATE STOCK DELTA
  // ============================================================

  int _calculateDelta(
    String type,
    int quantity,
  ) {
    switch (type) {
      case 'purchase':
      case 'return':
        return quantity;

      case 'sale':
        return -quantity;

      case 'adjustment':
        // Adjustment quantity is signed.
        //
        // +5 = increase stock by 5
        // -5 = decrease stock by 5
        return quantity;

      default:
        throw Exception(
          'Unsupported stock movement type: $type',
        );
    }
  }

  // ============================================================
  // INSERT STOCK MOVEMENT
  // ============================================================

  Future<int> insertMovement(
    StockMovementsCompanion movement,
  ) async {
    final productId = movement.productId.value;
    final quantity = movement.quantity.value;
    final type = movement.type.value.toLowerCase().trim();

    // ----------------------------------------------------------
    // VALIDATION
    // ----------------------------------------------------------

    if (productId <= 0) {
      throw Exception(
        'A valid product is required.',
      );
    }

    const allowedTypes = {
      'purchase',
      'return',
      'sale',
      'adjustment',
    };

    if (!allowedTypes.contains(type)) {
      throw Exception(
        'Invalid stock movement type: $type',
      );
    }

    // ----------------------------------------------------------
    // QUANTITY VALIDATION
    // ----------------------------------------------------------
    //
    // Purchase, return and sale must always have a
    // positive quantity.
    //
    // Adjustment can be positive OR negative.
    //
    // Example:
    //
    // purchase  +5
    // return    +5
    // sale      +5
    // adjustment +5
    // adjustment -5
    //
    // ----------------------------------------------------------

    if (type == 'adjustment') {
      if (quantity == 0) {
        throw Exception(
          'Adjustment quantity cannot be zero.',
        );
      }
    } else {
      if (quantity <= 0) {
        throw Exception(
          'Stock movement quantity must be greater than zero.',
        );
      }
    }

    // ----------------------------------------------------------
    // CALCULATE STOCK CHANGE
    // ----------------------------------------------------------

    final delta = _calculateDelta(
      type,
      quantity,
    );

    // ----------------------------------------------------------
    // ATOMIC MOVEMENT + STOCK UPDATE
    // ----------------------------------------------------------
    //
    // The movement and product stock update happen inside
    // one transaction.
    //
    // If the stock update fails, the movement is also rolled
    // back.
    //
    // ----------------------------------------------------------

    return transaction(() async {
      final movementId =
          await into(stockMovements).insert(movement);

      await _updateStock(
        productId,
        delta,
      );

      return movementId;
    });
  }

  // ============================================================
  // ALL MOVEMENTS FOR ONE PRODUCT
  // ============================================================

  Future<List<StockMovement>> getMovementsForProduct(
    int productId,
  ) {
    return (select(stockMovements)
          ..where(
            (m) => m.productId.equals(productId),
          )
          ..orderBy([
            (m) => OrderingTerm(
                  expression: m.date,
                  mode: OrderingMode.desc,
                ),
            (m) => OrderingTerm(
                  expression: m.id,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
  }

  // ============================================================
  // PRODUCT MOVEMENTS + SUPPLIER
  // ============================================================

  Future<List<StockMovementWithSupplier>>
      getMovementsForProductWithSuppliers(
    int productId,
  ) {
    final query = select(stockMovements).join([
      leftOuterJoin(
        suppliers,
        suppliers.id.equalsExp(
          stockMovements.supplierId,
        ),
      ),
    ])
      ..where(
        stockMovements.productId.equals(productId),
      )
      ..orderBy([
        OrderingTerm(
          expression: stockMovements.date,
          mode: OrderingMode.desc,
        ),
        OrderingTerm(
          expression: stockMovements.id,
          mode: OrderingMode.desc,
        ),
      ]);

    return query.map((row) {
      final movement =
          row.readTable(stockMovements);

      final supplier =
          row.readTableOrNull(suppliers);

      return StockMovementWithSupplier(
        movement,
        supplier,
      );
    }).get();
  }

  // ============================================================
  // ALL MOVEMENTS
  // ============================================================

  Future<List<StockMovement>> getAllMovements() {
    return (select(stockMovements)
          ..orderBy([
            (m) => OrderingTerm(
                  expression: m.date,
                  mode: OrderingMode.desc,
                ),
            (m) => OrderingTerm(
                  expression: m.id,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
  }

  // ============================================================
  // ALL MOVEMENTS WITH SUPPLIERS
  // ============================================================

  Future<List<StockMovementWithSupplier>>
      getMovementsWithSuppliers() {
    final query = select(stockMovements).join([
      leftOuterJoin(
        suppliers,
        suppliers.id.equalsExp(
          stockMovements.supplierId,
        ),
      ),
    ])
      ..orderBy([
        OrderingTerm(
          expression: stockMovements.date,
          mode: OrderingMode.desc,
        ),
        OrderingTerm(
          expression: stockMovements.id,
          mode: OrderingMode.desc,
        ),
      ]);

    return query.map((row) {
      final movement =
          row.readTable(stockMovements);

      final supplier =
          row.readTableOrNull(suppliers);

      return StockMovementWithSupplier(
        movement,
        supplier,
      );
    }).get();
  }

  // ============================================================
  // CURRENT STOCK FROM MOVEMENTS
  // ============================================================

  Future<int> getCurrentStock(
    int productId,
  ) async {
    final movements =
        await getMovementsForProduct(productId);

    int total = 0;

    for (final movement in movements) {
      final type =
          movement.type.toLowerCase().trim();

      final quantity =
          movement.quantity;

      switch (type) {
        case 'purchase':
        case 'return':
          total += quantity;
          break;

        case 'sale':
          total -= quantity;
          break;

        case 'adjustment':
          // Adjustment quantity is already signed.
          total += quantity;
          break;
      }
    }

    return total;
  }

  // ============================================================
  // PRODUCT LEDGER
  // ============================================================
  //
  // Example:
  //
  // Purchase +100
  // Balance after = 100
  //
  // Sale 2
  // Balance after = 98
  //
  // Adjustment +5
  // Balance after = 103
  //
  // Adjustment -3
  // Balance after = 100
  //
  // The database returns movements newest-first.
  // We reconstruct the historical balance backwards from
  // the product's current stock.
  //
  // ============================================================

  Future<List<StockMovementLedgerRow>>
      getProductLedger(
    int productId,
  ) async {
    final movements =
        await getMovementsForProductWithSuppliers(
      productId,
    );

    final product = await (select(products)
          ..where((p) => p.id.equals(productId)))
        .getSingle();

    // This is the balance AFTER the newest movement.
    int balanceAfter = product.stock;

    final rows =
        <StockMovementLedgerRow>[];

    // Newest -> oldest.
    for (final item in movements) {
      final movement = item.movement;

      final type =
          movement.type.toLowerCase().trim();

      final quantity =
          movement.quantity;

      final delta =
          _calculateDelta(type, quantity);

      // Current balance is AFTER this movement.
      //
      // Reverse the movement to determine the
      // balance BEFORE it.
      final balanceBefore =
          balanceAfter - delta;

      rows.add(
        StockMovementLedgerRow(
          movement: movement,
          supplier: item.supplier,
          balanceAfter: balanceAfter,
          balanceBefore: balanceBefore,
        ),
      );

      balanceAfter = balanceBefore;
    }

    // Newest -> oldest, which is what the UI normally wants.
    return rows;
  }
}

// ============================================================
// MOVEMENT + SUPPLIER
// ============================================================

class StockMovementWithSupplier {
  final StockMovement movement;
  final Supplier? supplier;

  StockMovementWithSupplier(
    this.movement,
    this.supplier,
  );
}

// ============================================================
// LEDGER ROW
// ============================================================

class StockMovementLedgerRow {
  final StockMovement movement;
  final Supplier? supplier;

  /// Stock immediately AFTER this movement.
  final int balanceAfter;

  /// Stock immediately BEFORE this movement.
  final int balanceBefore;

  StockMovementLedgerRow({
    required this.movement,
    required this.supplier,
    required this.balanceAfter,
    required this.balanceBefore,
  });
}
