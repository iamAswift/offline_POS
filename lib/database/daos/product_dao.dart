// lib/database/daos/product_dao.dart

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/product_table.dart';
import '../tables/sales_table.dart';
import '../tables/stock_movement_table.dart';

import '../models/product_model.dart';


import '../../models/reconciliation_row.dart';

part 'product_dao.g.dart';

@DriftAccessor(
  tables: [
    Products,
    Sales,
    StockMovements,
  ],
)
class ProductDao extends DatabaseAccessor<AppDatabase>
    with _$ProductDaoMixin {
  ProductDao(super.db);

  Future<List<ProductModel>> getAllProductsForSnapshot() async {
    final rows = await select(products).get();

    return rows.map((row) => ProductModel(
          id: row.id,
          barcode: row.barcode,
          name: row.name,
          brand: row.brand,
          categoryId: row.categoryId,
          unit: row.unit,
          costPrice: row.costPrice,
          sellingPrice: row.sellingPrice,
          stock: row.stock,
          imagePath: row.imagePath,
          expiryDate: row.expiryDate,
        )).toList();
  }


  // ============================================================
  // BASIC PRODUCT OPERATIONS
  // ============================================================

  /// Insert a new product.
  Future<int> insertProduct(
    ProductsCompanion product,
  ) {
    return into(products).insert(product);
  }

  /// Get all products.
  Future<List<Product>> getAllProducts() {
    return (select(products)
          ..orderBy([
            (p) => OrderingTerm.asc(p.name),
          ]))
        .get();
  }

  /// Get a product by ID.
  Future<Product> getProductById(
    int id,
  ) {
    return (select(products)
          ..where(
            (p) => p.id.equals(id),
          ))
        .getSingle();
  }

  /// Find product by barcode.
  Future<Product?> findByBarcode(
    String barcode,
  ) {
    return (select(products)
          ..where(
            (p) => p.barcode.equals(barcode),
          ))
        .getSingleOrNull();
  }

  /// Update a product.
  Future<bool> updateProduct(
    Product product,
  ) {
    return update(products).replace(product);
  }

  /// Delete a product by ID.
  Future<int> deleteProduct(
    int id,
  ) {
    return (delete(products)
          ..where(
            (p) => p.id.equals(id),
          ))
        .go();
  }

  // ============================================================
  // STOCK
  // ============================================================

  /// Update the current stock quantity.
  Future<void> updateProductStock(
    int productId,
    int newStock,
  ) async {
    await (update(products)
          ..where(
            (p) => p.id.equals(productId),
          ))
        .write(
      ProductsCompanion(
        stock: Value(newStock),
      ),
    );
  }

  /// Products below the supplied stock threshold.
  Future<List<Product>> getLowStockProducts({
    int threshold = 10,
  }) {
    return (select(products)
          ..where(
            (p) => p.stock.isSmallerThanValue(
              threshold,
            ),
          )
          ..orderBy([
            (p) => OrderingTerm.asc(p.stock),
            (p) => OrderingTerm.asc(p.name),
          ]))
        .get();
  }

  /// Products with zero stock.
  Future<List<Product>> getOutOfStockProducts() {
    return (select(products)
          ..where(
            (p) => p.stock.equals(0),
          )
          ..orderBy([
            (p) => OrderingTerm.asc(p.name),
          ]))
        .get();
  }

  /// Get products belonging to a category.
  Future<List<Product>> getProductsByCategory(
    int categoryId,
  ) {
    return (select(products)
          ..where(
            (p) => p.categoryId.equals(categoryId),
          )
          ..orderBy([
            (p) => OrderingTerm.asc(p.name),
          ]))
        .get();
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
        ) AS total_stock_value
      FROM products
      ''',
      readsFrom: {
        products,
      },
    ).getSingle();

    return _readDouble(
      result.data['total_stock_value'],
    );
  }

  // ============================================================
  // TOTAL STOCK UNITS
  // ============================================================

  Future<int> getTotalStockUnits() async {
    final result = await customSelect(
      '''
      SELECT
        COALESCE(
          SUM(stock),
          0
        ) AS total_stock_units
      FROM products
      ''',
      readsFrom: {
        products,
      },
    ).getSingle();

    return _readInt(
      result.data['total_stock_units'],
    );
  }

  // ============================================================
  // PRODUCT COUNT WITH STOCK
  // ============================================================

  Future<int> getInventoryProductCount() async {
    final result = await customSelect(
      '''
      SELECT
        COUNT(*) AS product_count
      FROM products
      ''',
      readsFrom: {
        products,
      },
    ).getSingle();

    return _readInt(
      result.data['product_count'],
    );
  }

  // ============================================================
  // STOCK VALUE BY CATEGORY
  // ============================================================

  Future<List<StockValueCategoryRow>>
      getStockValueByCategory() async {
    final result = await customSelect(
      '''
      SELECT
        c.id AS category_id,
        c.name AS category_name,

        COALESCE(
          SUM(p.stock),
          0
        ) AS total_units,

        COALESCE(
          SUM(
            p.stock * p.cost_price
          ),
          0
        ) AS stock_value

      FROM products p

      LEFT JOIN categories c
        ON p.category_id = c.id

      GROUP BY
        c.id,
        c.name

      ORDER BY
        stock_value DESC
      ''',
      readsFrom: {
        products,
      },
    ).get();

    return result.map((row) {
      final categoryId =
          row.data['category_id'];

      return StockValueCategoryRow(
        categoryId: categoryId is num
            ? categoryId.toInt()
            : null,
        categoryName:
            row.data['category_name']
                    ?.toString() ??
                'Uncategorized',
        totalUnits: _readInt(
          row.data['total_units'],
        ),
        stockValue: _readDouble(
          row.data['stock_value'],
        ),
      );
    }).toList();
  }

  // ============================================================
  // PRODUCT STOCK VALUE
  // ============================================================

  Future<List<ProductStockValueRow>>
      getProductStockValues() async {
    final result = await customSelect(
      '''
      SELECT
        p.id AS product_id,
        p.name AS product_name,
        p.stock AS stock,
        p.cost_price AS cost_price,

        (
          p.stock * p.cost_price
        ) AS stock_value

      FROM products p

      ORDER BY
        stock_value DESC,
        p.name ASC
      ''',
      readsFrom: {
        products,
      },
    ).get();

    return result.map((row) {
      return ProductStockValueRow(
        productId: _readInt(
          row.data['product_id'],
        ),
        productName:
            row.data['product_name']
                    ?.toString() ??
                '',
        stock: _readInt(
          row.data['stock'],
        ),
        costPrice: _readDouble(
          row.data['cost_price'],
        ),
        stockValue: _readDouble(
          row.data['stock_value'],
        ),
      );
    }).toList();
  }

  // ============================================================
  // STOCK VALUE FOR ONE CATEGORY
  // ============================================================

  Future<double> getStockValueForCategory(
    int categoryId,
  ) async {
    final result = await customSelect(
      '''
      SELECT
        COALESCE(
          SUM(
            stock * cost_price
          ),
          0
        ) AS stock_value

      FROM products

      WHERE category_id = ?
      ''',
      variables: [
        Variable.withInt(categoryId),
      ],
      readsFrom: {
        products,
      },
    ).getSingle();

    return _readDouble(
      result.data['stock_value'],
    );
  }

  // ============================================================
  // STREAMS
  // ============================================================

  Stream<List<Product>> watchAllProducts() {
    return (select(products)
          ..orderBy([
            (p) => OrderingTerm.asc(p.name),
          ]))
        .watch();
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Future<List<Product>> searchProducts(
    String query,
  ) {
    final search = query.trim();

    if (search.isEmpty) {
      return (select(products)
            ..orderBy([
              (p) => OrderingTerm.asc(p.name),
            ]))
          .get();
    }

    final pattern =
        '%${search.toLowerCase()}%';

    return (select(products)
          ..where(
            (p) =>
                p.name.lower().like(pattern) |
                p.brand.lower().like(pattern),
          )
          ..orderBy([
            (p) => OrderingTerm.asc(p.name),
          ]))
        .get();
  }

  Stream<List<Product>> watchSearchProducts(
    String query,
  ) {
    final search = query.trim();

    if (search.isEmpty) {
      return (select(products)
            ..orderBy([
              (p) => OrderingTerm.asc(p.name),
            ]))
          .watch();
    }

    final pattern =
        '%${search.toLowerCase()}%';

    return (select(products)
          ..where(
            (p) =>
                p.name.lower().like(pattern) |
                p.brand.lower().like(pattern),
          )
          ..orderBy([
            (p) => OrderingTerm.asc(p.name),
          ]))
        .watch();
  }

  // ============================================================
  // PAGINATION
  // ============================================================

  Future<List<Product>> getProductsPaged(
    int limit,
    int offset,
  ) {
    return (select(products)
          ..orderBy([
            (p) => OrderingTerm.asc(p.name),
          ])
          ..limit(
            limit,
            offset: offset,
          ))
        .get();
  }

  Stream<List<Product>> watchProductsPaged(
    int limit,
    int offset,
  ) {
    return (select(products)
          ..orderBy([
            (p) => OrderingTerm.asc(p.name),
          ])
          ..limit(
            limit,
            offset: offset,
          ))
        .watch();
  }

  // ============================================================
  // PRODUCT COUNT
  // ============================================================

  Future<int> getProductCount() async {
    final countExpression =
        products.id.count();

    final query = selectOnly(products)
      ..addColumns([
        countExpression,
      ]);

    final row =
        await query.getSingle();

    return row.read(countExpression) ?? 0;
  }

  // ============================================================
  // FILTERED PRODUCTS
  // ============================================================

  Future<List<Product>> getProductsFiltered({
    String searchQuery = '',
    int? categoryId,
    String sortBy = 'Name',
    int limit = 20,
    int offset = 0,
  }) {
    final search =
        searchQuery.trim();

    final hasSearch =
        search.isNotEmpty;

    final pattern =
        '%${search.toLowerCase()}%';

    final query =
        select(products);

    if (hasSearch &&
        categoryId != null) {
      query.where(
        (p) =>
            (p.name.lower().like(pattern) |
                p.brand.lower().like(pattern)) &
            p.categoryId.equals(categoryId),
      );
    } else if (hasSearch) {
      query.where(
        (p) =>
            p.name.lower().like(pattern) |
            p.brand.lower().like(pattern),
      );
    } else if (categoryId != null) {
      query.where(
        (p) => p.categoryId.equals(categoryId),
      );
    }

    switch (sortBy) {
      case 'Price':
        query.orderBy([
          (p) => OrderingTerm.asc(
            p.sellingPrice,
          ),
          (p) => OrderingTerm.asc(
            p.name,
          ),
        ]);
        break;

      case 'Stock':
        query.orderBy([
          (p) => OrderingTerm.asc(
            p.stock,
          ),
          (p) => OrderingTerm.asc(
            p.name,
          ),
        ]);
        break;

      case 'Name':
      default:
        query.orderBy([
          (p) => OrderingTerm.asc(
            p.name,
          ),
        ]);
        break;
    }

    query.limit(
      limit,
      offset: offset,
    );

    return query.get();
  }

  Stream<List<Product>> watchProductsFiltered({
    String searchQuery = '',
    int? categoryId,
    String sortBy = 'Name',
    int limit = 20,
    int offset = 0,
  }) {
    final search =
        searchQuery.trim();

    final hasSearch =
        search.isNotEmpty;

    final pattern =
        '%${search.toLowerCase()}%';

    final query =
        select(products);

    if (hasSearch &&
        categoryId != null) {
      query.where(
        (p) =>
            (p.name.lower().like(pattern) |
                p.brand.lower().like(pattern)) &
            p.categoryId.equals(categoryId),
      );
    } else if (hasSearch) {
      query.where(
        (p) =>
            p.name.lower().like(pattern) |
            p.brand.lower().like(pattern),
      );
    } else if (categoryId != null) {
      query.where(
        (p) => p.categoryId.equals(categoryId),
      );
    }

    switch (sortBy) {
      case 'Price':
        query.orderBy([
          (p) => OrderingTerm.asc(
            p.sellingPrice,
          ),
          (p) => OrderingTerm.asc(
            p.name,
          ),
        ]);
        break;

      case 'Stock':
        query.orderBy([
          (p) => OrderingTerm.asc(
            p.stock,
          ),
          (p) => OrderingTerm.asc(
            p.name,
          ),
        ]);
        break;

      case 'Name':
      default:
        query.orderBy([
          (p) => OrderingTerm.asc(
            p.name,
          ),
        ]);
        break;
    }

    query.limit(
      limit,
      offset: offset,
    );

    return query.watch();
  }

  // ============================================================
  // EXPIRY
  // ============================================================

  Future<List<Product>> getExpiringProducts() async {
    final now = DateTime.now();

    final threeMonthsFromNow = DateTime(
      now.year,
      now.month + 3,
      now.day,
    );

    return (select(products)
          ..where(
            (p) =>
                p.expiryDate.isNotNull() &
                p.expiryDate.isBiggerOrEqualValue(now) &
                p.expiryDate.isSmallerOrEqualValue(
                  threeMonthsFromNow,
                ),
          )
          ..orderBy([
            (p) => OrderingTerm.asc(
              p.expiryDate,
            ),
          ]))
        .get();
  }

  Future<List<Product>> getExpiredProducts() async {
    final now = DateTime.now();

    return (select(products)
          ..where(
            (p) =>
                p.expiryDate.isNotNull() &
                p.expiryDate.isSmallerThanValue(now),
          )
          ..orderBy([
            (p) => OrderingTerm.asc(
              p.expiryDate,
            ),
          ]))
        .get();
  }

  // ============================================================
  // DAILY RECONCILIATION
  // ============================================================

  Future<List<ReconciliationRow>>
      getDailyReconciliation(
    DateTime date,
  ) async {
    final productList =
        await getAllProducts();

    final List<ReconciliationRow> rows = [];

    final startOfDay = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final endOfDay = startOfDay.add(
      const Duration(days: 1),
    );

    for (final product in productList) {
      // --------------------------------------------------------
      // RECEIVED
      // --------------------------------------------------------

      final stockMovementsToday =
          await (select(stockMovements)
                ..where(
                  (m) =>
                      m.productId.equals(product.id) &
                      m.date.isBiggerOrEqualValue(
                        startOfDay,
                      ) &
                      m.date.isSmallerThanValue(
                        endOfDay,
                      ),
                ))
              .get();

      int received = 0;

      for (final movement
          in stockMovementsToday) {
        final type =
            movement.type.trim().toLowerCase();

        if (type == 'purchase' ||
            type == 'return') {
          received +=
              movement.quantity.toInt();
        }
      }

      // --------------------------------------------------------
      // SOLD
      // --------------------------------------------------------

      final salesToday =
          await (select(sales)
                ..where(
                  (s) =>
                      s.productId.equals(product.id) &
                      s.createdAt.isBiggerOrEqualValue(
                        startOfDay,
                      ) &
                      s.createdAt.isSmallerThanValue(
                        endOfDay,
                      ),
                ))
              .get();

      int sold = 0;

      for (final sale in salesToday) {
        sold += sale.quantity.toInt();
      }

      // --------------------------------------------------------
      // STOCK CALCULATION
      // --------------------------------------------------------

      final int currentStock =
          product.stock;

      final int openingStock =
          currentStock +
              sold -
              received;

      final int expectedClosing =
          openingStock +
              received -
              sold;

      final int physicalCount =
          currentStock;

      final int difference =
          physicalCount -
              expectedClosing;

      rows.add(
        ReconciliationRow(
          productName: product.name,
          openingStock: openingStock,
          received: received,
          sold: sold,
          expectedClosing: expectedClosing,
          physicalCount: physicalCount,
          difference: difference,
        ),
      );
    }

    return rows;
  }

  // ============================================================
  // HELPERS
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

  int _readInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}

// ================================================================
// STOCK VALUE CATEGORY MODEL
// ================================================================

class StockValueCategoryRow {
  final int? categoryId;
  final String categoryName;
  final int totalUnits;
  final double stockValue;

  const StockValueCategoryRow({
    required this.categoryId,
    required this.categoryName,
    required this.totalUnits,
    required this.stockValue,
  });
}

// ================================================================
// PRODUCT STOCK VALUE MODEL
// ================================================================

class ProductStockValueRow {
  final int productId;
  final String productName;
  final int stock;
  final double costPrice;
  final double stockValue;

  const ProductStockValueRow({
    required this.productId,
    required this.productName,
    required this.stock,
    required this.costPrice,
    required this.stockValue,
  });
}