// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_purchase_dao.dart';

// ignore_for_file: type=lint
mixin _$StaffPurchaseDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsersTable get users => attachedDatabase.users;
  $CategoriesTable get categories => attachedDatabase.categories;
  $ProductsTable get products => attachedDatabase.products;
  $SalesTable get sales => attachedDatabase.sales;
  $StaffPurchasesTable get staffPurchases => attachedDatabase.staffPurchases;
  $SuppliersTable get suppliers => attachedDatabase.suppliers;
  $SupplierDeliveriesTable get supplierDeliveries =>
      attachedDatabase.supplierDeliveries;
  $StockMovementsTable get stockMovements => attachedDatabase.stockMovements;
  $SettingsTable get settings => attachedDatabase.settings;
  $StaffDebtPaymentsTable get staffDebtPayments =>
      attachedDatabase.staffDebtPayments;
  StaffPurchaseDaoManager get managers => StaffPurchaseDaoManager(this);
}

class StaffPurchaseDaoManager {
  final _$StaffPurchaseDaoMixin _db;
  StaffPurchaseDaoManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db.attachedDatabase, _db.products);
  $$SalesTableTableManager get sales =>
      $$SalesTableTableManager(_db.attachedDatabase, _db.sales);
  $$StaffPurchasesTableTableManager get staffPurchases =>
      $$StaffPurchasesTableTableManager(
        _db.attachedDatabase,
        _db.staffPurchases,
      );
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
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db.attachedDatabase, _db.settings);
  $$StaffDebtPaymentsTableTableManager get staffDebtPayments =>
      $$StaffDebtPaymentsTableTableManager(
        _db.attachedDatabase,
        _db.staffDebtPayments,
      );
}
