// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_movement_dao.dart';

// ignore_for_file: type=lint
mixin _$StockMovementDaoMixin on DatabaseAccessor<AppDatabase> {
  $CategoriesTable get categories => attachedDatabase.categories;
  $ProductsTable get products => attachedDatabase.products;
  $SuppliersTable get suppliers => attachedDatabase.suppliers;
  $SupplierDeliveriesTable get supplierDeliveries =>
      attachedDatabase.supplierDeliveries;
  $StockMovementsTable get stockMovements => attachedDatabase.stockMovements;
  StockMovementDaoManager get managers => StockMovementDaoManager(this);
}

class StockMovementDaoManager {
  final _$StockMovementDaoMixin _db;
  StockMovementDaoManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db.attachedDatabase, _db.products);
  $$SuppliersTableTableManager get suppliers =>
      $$SuppliersTableTableManager(_db.attachedDatabase, _db.suppliers);
  $$SupplierDeliveriesTableTableManager get supplierDeliveries =>
      $$SupplierDeliveriesTableTableManager(
        _db.attachedDatabase,
        _db.supplierDeliveries,
      );
  $$StockMovementsTableTableManager get stockMovements =>
      $$StockMovementsTableTableManager(
        _db.attachedDatabase,
        _db.stockMovements,
      );
}
