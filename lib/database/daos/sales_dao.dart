// lib/database/daos/sales_dao.dart

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/product_table.dart';
import '../tables/sales_table.dart';
import '../tables/stock_movement_table.dart';
import '../tables/category_table.dart';

part 'sales_dao.g.dart';

@DriftAccessor(
  tables: [
    Sales,
    Products,
    StockMovements,
    Categories,
  ],
)
class SalesDao extends DatabaseAccessor<AppDatabase>
    with _$SalesDaoMixin {
  SalesDao(super.db);

  // ============================================================
  // INSERT SALE
  // ============================================================
  //
  // One transaction:
  //
  // 1. Validate sale
  // 2. Get product
  // 3. Check stock
  // 4. Capture cost price
  // 5. Insert sale
  // 6. Reduce product stock
  // 7. Insert stock movement
  //
  // If anything fails, EVERYTHING rolls back.
  //
  // ============================================================

  Future<int> insertSale(
    SalesCompanion sale,
  ) async {
    return transaction(() async {
      final productId = sale.productId.value;
      final quantity = sale.quantity.value;

      // ----------------------------------------------------------
      // VALIDATION
      // ----------------------------------------------------------

      if (productId <= 0) {
        throw Exception(
          'A valid product is required.',
        );
      }

      if (quantity <= 0) {
        throw Exception(
          'Sale quantity must be greater than zero.',
        );
      }

      // ----------------------------------------------------------
      // GET PRODUCT
      // ----------------------------------------------------------

      final product = await (select(products)
            ..where(
              (p) => p.id.equals(productId),
            ))
          .getSingle();

      // ----------------------------------------------------------
      // CHECK STOCK
      // ----------------------------------------------------------

      if (product.stock < quantity) {
        throw Exception(
          'Insufficient stock for ${product.name}. '
          'Available: ${product.stock}, '
          'requested: $quantity.',
        );
      }

      // ----------------------------------------------------------
      // CAPTURE COST PRICE
      // ----------------------------------------------------------
      //
      // This is important because product.costPrice can change
      // later. The sale keeps the cost price that existed
      // at the moment of sale.
      //
      // ----------------------------------------------------------

      final costPriceAtSale = product.costPrice;

      final saleWithCostPrice = sale.copyWith(
        costPriceAtSale: Value(costPriceAtSale),
      );

      // ----------------------------------------------------------
      // INSERT SALE
      // ----------------------------------------------------------

      final saleId = await into(sales).insert(
        saleWithCostPrice,
      );

      // ----------------------------------------------------------
      // UPDATE PRODUCT STOCK
      // ----------------------------------------------------------

      final newStock = product.stock - quantity;

      await (update(products)
            ..where(
              (p) => p.id.equals(productId),
            ))
          .write(
        ProductsCompanion(
          stock: Value(newStock),
        ),
      );

      // ----------------------------------------------------------
      // INSERT STOCK MOVEMENT
      // ----------------------------------------------------------
      //
      // Sales always create a POSITIVE quantity movement with
      // type = sale.
      //
      // StockMovementDao interprets:
      //
      // sale 5 = stock -5
      //
      // This keeps the ledger consistent.
      //
      // ----------------------------------------------------------

      await into(stockMovements).insert(
        StockMovementsCompanion(
          productId: Value(productId),
          supplierId: const Value(null),
          type: const Value('sale'),
          quantity: Value(quantity),
          unitPrice: Value(
            sale.unitPrice.value.toDouble(),
          ),
          date: Value(DateTime.now()),
        ),
      );

      return saleId;
    });
  }

  // ============================================================
  // ALL SALES
  // ============================================================

  Future<List<Sale>> getAllSales() {
    return (select(sales)
          ..orderBy([
            (s) => OrderingTerm(
                  expression: s.createdAt,
                  mode: OrderingMode.desc,
                ),
            (s) => OrderingTerm(
                  expression: s.id,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
  }

  // ============================================================
  // SALES TODAY
  // ============================================================

  Future<List<Sale>> getSalesToday() async {
    final today = DateTime.now();

    final start = DateTime(
      today.year,
      today.month,
      today.day,
    );

    final end = start.add(
      const Duration(days: 1),
    );

    return (select(sales)
          ..where(
            (s) => s.createdAt.isBetweenValues(
              start,
              end,
            ),
          )
          ..orderBy([
            (s) => OrderingTerm(
                  expression: s.createdAt,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
  }

  // ============================================================
  // TOTAL SALES TODAY
  // ============================================================

  Future<double> getTotalSalesToday() async {
    final rows = await getSalesToday();

    return rows.fold<double>(
      0.0,
      (sum, sale) =>
          sum + sale.totalPrice.toDouble(),
    );
  }

  // ============================================================
  // ITEMS SOLD TODAY
  // ============================================================

  Future<int> getItemsSoldToday() async {
    final rows = await getSalesToday();

    return rows.fold<int>(
      0,
      (sum, sale) =>
          sum + sale.quantity,
    );
  }

  // ============================================================
  // PROFIT TODAY
  // ============================================================

  Future<double> getProfitToday() async {
    final rows = await getSalesToday();

    return rows.fold<double>(
      0.0,
      (sum, sale) {
        final profitPerUnit =
            sale.unitPrice.toDouble() -
                sale.costPriceAtSale;

        return sum +
            (profitPerUnit * sale.quantity);
      },
    );
  }

  // ============================================================
  // PAYMENT BREAKDOWN TODAY
  // ============================================================
  //
  // For split payments we use:
  //
  // cashAmount
  // posAmount
  // transferAmount
  //
  // Instead of putting the entire sale under "split".
  //
  // ============================================================

  Future<Map<String, double>>
      getPaymentBreakdownToday() async {
    final rows = await getSalesToday();

    final breakdown = {
      'cash': 0.0,
      'pos': 0.0,
      'transfer': 0.0,
    };

    for (final sale in rows) {
      final method =
          sale.paymentMethod.toLowerCase();

      switch (method) {
        case 'cash':
          breakdown['cash'] =
              breakdown['cash']! +
                  sale.totalPrice.toDouble();
          break;

        case 'pos':
          breakdown['pos'] =
              breakdown['pos']! +
                  sale.totalPrice.toDouble();
          break;

        case 'transfer':
          breakdown['transfer'] =
              breakdown['transfer']! +
                  sale.totalPrice.toDouble();
          break;

        case 'split':
          breakdown['cash'] =
              breakdown['cash']! +
                  (sale.cashAmount ?? 0);

          breakdown['pos'] =
              breakdown['pos']! +
                  (sale.posAmount ?? 0);

          breakdown['transfer'] =
              breakdown['transfer']! +
                  (sale.transferAmount ?? 0);
          break;
      }
    }

    return breakdown;
  }

  // ============================================================
  // TOTAL SALES
  // ============================================================

  Future<double> getTotalSales(
    DateTime start,
    DateTime end,
  ) async {
    final rows = await (select(sales)
          ..where(
            (s) => s.createdAt.isBetweenValues(
              start,
              end,
            ),
          ))
        .get();

    return rows.fold<double>(
      0.0,
      (sum, sale) =>
          sum + sale.totalPrice.toDouble(),
    );
  }

  // ============================================================
  // ITEMS SOLD
  // ============================================================

  Future<int> getItemsSold(
    DateTime start,
    DateTime end,
  ) async {
    final rows = await (select(sales)
          ..where(
            (s) => s.createdAt.isBetweenValues(
              start,
              end,
            ),
          ))
        .get();

    return rows.fold<int>(
      0,
      (sum, sale) =>
          sum + sale.quantity,
    );
  }

  // ============================================================
  // PROFIT
  // ============================================================

  Future<double> getProfit(
    DateTime start,
    DateTime end,
  ) async {
    final rows = await (select(sales)
          ..where(
            (s) => s.createdAt.isBetweenValues(
              start,
              end,
            ),
          ))
        .get();

    return rows.fold<double>(
      0.0,
      (sum, sale) {
        final profitPerUnit =
            sale.unitPrice.toDouble() -
                sale.costPriceAtSale;

        return sum +
            (profitPerUnit * sale.quantity);
      },
    );
  }

  // ============================================================
  // PAYMENT BREAKDOWN
  // ============================================================

  Future<Map<String, double>>
      getPaymentBreakdown(
    DateTime start,
    DateTime end,
  ) async {
    final rows = await (select(sales)
          ..where(
            (s) => s.createdAt.isBetweenValues(
              start,
              end,
            ),
          ))
        .get();

    final breakdown = {
      'cash': 0.0,
      'pos': 0.0,
      'transfer': 0.0,
    };

    for (final sale in rows) {
      final method =
          sale.paymentMethod.toLowerCase();

      switch (method) {
        case 'cash':
          breakdown['cash'] =
              breakdown['cash']! +
                  sale.totalPrice.toDouble();
          break;

        case 'pos':
          breakdown['pos'] =
              breakdown['pos']! +
                  sale.totalPrice.toDouble();
          break;

        case 'transfer':
          breakdown['transfer'] =
              breakdown['transfer']! +
                  sale.totalPrice.toDouble();
          break;

        case 'split':
          breakdown['cash'] =
              breakdown['cash']! +
                  (sale.cashAmount ?? 0);

          breakdown['pos'] =
              breakdown['pos']! +
                  (sale.posAmount ?? 0);

          breakdown['transfer'] =
              breakdown['transfer']! +
                  (sale.transferAmount ?? 0);
          break;
      }
    }

    return breakdown;
  }

  // ============================================================
  // TOTAL REVENUE
  // ============================================================

  Future<double> getTotalRevenue() async {
    final result = await customSelect(
      '''
      SELECT SUM(total_price) AS total
      FROM sales
      ''',
      readsFrom: {sales},
    ).getSingle();

    return (result.data['total'] as num?)
            ?.toDouble() ??
        0.0;
  }

  // ============================================================
  // TOTAL PROFIT
  // ============================================================

  Future<double> getTotalProfit() async {
    final rows = await select(sales).get();

    return rows.fold<double>(
      0.0,
      (sum, sale) {
        final profitPerUnit =
            sale.unitPrice.toDouble() -
                sale.costPriceAtSale;

        return sum +
            (profitPerUnit * sale.quantity);
      },
    );
  }

  // ============================================================
  // TOTAL STOCK VALUE
  // ============================================================

  Future<double> getTotalStockValue() async {
    final result = await customSelect(
      '''
      SELECT
        COALESCE(
          SUM(stock * cost_price),
          0
        ) AS totalValue
      FROM products
      ''',
      readsFrom: {products},
    ).getSingle();

    return (result.data['totalValue'] as num?)
            ?.toDouble() ??
        0.0;
  }

  // ============================================================
  // GROSS REVENUE
  // ============================================================

  Future<double> getGrossRevenue(
    DateTime start,
    DateTime end,
  ) async {
    final result = await customSelect(
      '''
      SELECT
        COALESCE(
          SUM(total_price),
          0
        ) AS grossRevenue
      FROM sales
      WHERE created_at >= ?
        AND created_at < ?
      ''',
      variables: [
        Variable.withDateTime(start),
        Variable.withDateTime(end),
      ],
      readsFrom: {sales},
    ).getSingle();

    return (result.data['grossRevenue'] as num?)
            ?.toDouble() ??
        0.0;
  }

  // ============================================================
  // SALES TREND
  // ============================================================

  Future<List<Map<String, dynamic>>>
      getSalesTrend(
    DateTime start,
    DateTime end,
  ) async {
    final result = await customSelect(
      '''
      SELECT
        DATE(created_at) AS date,
        SUM(total_price) AS totalSales
      FROM sales
      WHERE created_at >= ?
        AND created_at < ?
      GROUP BY DATE(created_at)
      ORDER BY DATE(created_at)
      ''',
      variables: [
        Variable.withDateTime(start),
        Variable.withDateTime(end),
      ],
      readsFrom: {sales},
    ).get();

    return result.map((row) {
      return {
        'date': row.data['date'],
        'totalSales':
            (row.data['totalSales'] as num?)
                ?.toDouble() ??
            0.0,
      };
    }).toList();
  }

  
  // ============================================================
  // CATEGORY SUMMARY
  // ============================================================
  //
  // Returns:
  //
  // totalSales
  // itemsSold
  // profit
  // stockValue
  //
  // IMPORTANT:
  // stockValue is calculated independently from sales using a
  // correlated subquery. This prevents current inventory from
  // being multiplied by the number of historical sales.
  //
  // ============================================================

  Future<List<Map<String, dynamic>>> getCategorySummary(
    DateTime start,
    DateTime end,
  ) async {
    final result = await customSelect(
      '''
      SELECT
        c.id,
        c.name,

        -- ========================================================
        -- SALES
        -- ========================================================

        COALESCE(
          SUM(s.total_price),
          0
        ) AS totalSales,

        COALESCE(
          SUM(s.quantity),
          0
        ) AS itemsSold,

        COALESCE(
          SUM(
            (
              s.unit_price -
              s.cost_price_at_sale
            ) * s.quantity
          ),
          0
        ) AS profit,

        -- ========================================================
        -- CURRENT STOCK VALUE
        -- ========================================================
        --
        -- Calculated independently from sales.
        -- This prevents inventory value from being repeated
        -- for every sale belonging to the category.
        --

        COALESCE(
          (
            SELECT
              SUM(
                p2.stock * p2.cost_price
              )
            FROM products p2
            WHERE p2.category_id = c.id
          ),
          0
        ) AS stockValue

      FROM sales s

      JOIN products p
        ON s.product_id = p.id

      JOIN categories c
        ON p.category_id = c.id

      WHERE s.created_at >= ?
        AND s.created_at < ?

      GROUP BY
        c.id,
        c.name

      ORDER BY
        c.name
      ''',
      variables: [
        Variable.withDateTime(start),
        Variable.withDateTime(end),
      ],
      readsFrom: {
        sales,
        products,
        categories,
      },
    ).get();

    return result.map((row) {
      return {
        'categoryId':
            row.data['id'],

        'categoryName':
            row.data['name'],

        'totalSales':
            (row.data['totalSales'] as num?)
                ?.toDouble() ??
            0.0,

        'itemsSold':
            (row.data['itemsSold'] as num?)
                ?.toInt() ??
            0,

        'profit':
            (row.data['profit'] as num?)
                ?.toDouble() ??
            0.0,

        'stockValue':
            (row.data['stockValue'] as num?)
                ?.toDouble() ??
            0.0,
      };
    }).toList();
  }
}