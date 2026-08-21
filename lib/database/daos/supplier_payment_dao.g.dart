// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_payment_dao.dart';

// ignore_for_file: type=lint
mixin _$SupplierPaymentDaoMixin on DatabaseAccessor<AppDatabase> {
  $SuppliersTable get suppliers => attachedDatabase.suppliers;
  $SupplierPaymentsTable get supplierPayments =>
      attachedDatabase.supplierPayments;
  SupplierPaymentDaoManager get managers => SupplierPaymentDaoManager(this);
}

class SupplierPaymentDaoManager {
  final _$SupplierPaymentDaoMixin _db;
  SupplierPaymentDaoManager(this._db);
  $$SuppliersTableTableManager get suppliers =>
      $$SuppliersTableTableManager(_db.attachedDatabase, _db.suppliers);
  $$SupplierPaymentsTableTableManager get supplierPayments =>
      $$SupplierPaymentsTableTableManager(
        _db.attachedDatabase,
        _db.supplierPayments,
      );
}
