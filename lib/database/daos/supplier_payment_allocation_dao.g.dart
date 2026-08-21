// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_payment_allocation_dao.dart';

// ignore_for_file: type=lint
mixin _$SupplierPaymentAllocationDaoMixin on DatabaseAccessor<AppDatabase> {
  $SuppliersTable get suppliers => attachedDatabase.suppliers;
  $SupplierPaymentsTable get supplierPayments =>
      attachedDatabase.supplierPayments;
  $SupplierDeliveriesTable get supplierDeliveries =>
      attachedDatabase.supplierDeliveries;
  $SupplierPaymentAllocationsTable get supplierPaymentAllocations =>
      attachedDatabase.supplierPaymentAllocations;
  SupplierPaymentAllocationDaoManager get managers =>
      SupplierPaymentAllocationDaoManager(this);
}

class SupplierPaymentAllocationDaoManager {
  final _$SupplierPaymentAllocationDaoMixin _db;
  SupplierPaymentAllocationDaoManager(this._db);
  $$SuppliersTableTableManager get suppliers =>
      $$SuppliersTableTableManager(_db.attachedDatabase, _db.suppliers);
  $$SupplierPaymentsTableTableManager get supplierPayments =>
      $$SupplierPaymentsTableTableManager(
        _db.attachedDatabase,
        _db.supplierPayments,
      );
  $$SupplierDeliveriesTableTableManager get supplierDeliveries =>
      $$SupplierDeliveriesTableTableManager(
        _db.attachedDatabase,
        _db.supplierDeliveries,
      );
  $$SupplierPaymentAllocationsTableTableManager
  get supplierPaymentAllocations =>
      $$SupplierPaymentAllocationsTableTableManager(
        _db.attachedDatabase,
        _db.supplierPaymentAllocations,
      );
}
