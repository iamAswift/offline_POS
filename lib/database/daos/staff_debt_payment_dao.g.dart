// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_debt_payment_dao.dart';

// ignore_for_file: type=lint
mixin _$StaffDebtPaymentDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsersTable get users => attachedDatabase.users;
  $StaffDebtPaymentsTable get staffDebtPayments =>
      attachedDatabase.staffDebtPayments;
  $CategoriesTable get categories => attachedDatabase.categories;
  $ProductsTable get products => attachedDatabase.products;
  $SalesTable get sales => attachedDatabase.sales;
  $StaffPurchasesTable get staffPurchases => attachedDatabase.staffPurchases;
  StaffDebtPaymentDaoManager get managers => StaffDebtPaymentDaoManager(this);
}

class StaffDebtPaymentDaoManager {
  final _$StaffDebtPaymentDaoMixin _db;
  StaffDebtPaymentDaoManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$StaffDebtPaymentsTableTableManager get staffDebtPayments =>
      $$StaffDebtPaymentsTableTableManager(
        _db.attachedDatabase,
        _db.staffDebtPayments,
      );
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
}
