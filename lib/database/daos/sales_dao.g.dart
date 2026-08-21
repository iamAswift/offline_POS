// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_dao.dart';

// ignore_for_file: type=lint
mixin _$SalesDaoMixin on DatabaseAccessor<AppDatabase> {
  $CategoriesTable get categories => attachedDatabase.categories;
  $ProductsTable get products => attachedDatabase.products;
  $UsersTable get users => attachedDatabase.users;
  $SalesTable get sales => attachedDatabase.sales;
  $SuppliersTable get suppliers => attachedDatabase.suppliers;
  $SupplierDeliveriesTable get supplierDeliveries =>
      attachedDatabase.supplierDeliveries;
  $StockMovementsTable get stockMovements => attachedDatabase.stockMovements;
  SalesDaoManager get managers => SalesDaoManager(this);
}

class SalesDaoManager {
  final _$SalesDaoMixin _db;
  SalesDaoManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db.attachedDatabase, _db.products);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$SalesTableTableManager get sales =>
      $$SalesTableTableManager(_db.attachedDatabase, _db.sales);
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
