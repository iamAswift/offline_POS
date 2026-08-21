// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_delivery_item_dao.dart';

// ignore_for_file: type=lint
mixin _$SupplierDeliveryItemDaoMixin on DatabaseAccessor<AppDatabase> {
  $SuppliersTable get suppliers => attachedDatabase.suppliers;
  $SupplierDeliveriesTable get supplierDeliveries =>
      attachedDatabase.supplierDeliveries;
  $CategoriesTable get categories => attachedDatabase.categories;
  $ProductsTable get products => attachedDatabase.products;
  $SupplierDeliveryItemsTable get supplierDeliveryItems =>
      attachedDatabase.supplierDeliveryItems;
  SupplierDeliveryItemDaoManager get managers =>
      SupplierDeliveryItemDaoManager(this);
}

class SupplierDeliveryItemDaoManager {
  final _$SupplierDeliveryItemDaoMixin _db;
  SupplierDeliveryItemDaoManager(this._db);
  $$SuppliersTableTableManager get suppliers =>
      $$SuppliersTableTableManager(_db.attachedDatabase, _db.suppliers);
  $$SupplierDeliveriesTableTableManager get supplierDeliveries =>
      $$SupplierDeliveriesTableTableManager(
        _db.attachedDatabase,
        _db.supplierDeliveries,
      );
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db.attachedDatabase, _db.products);
  $$SupplierDeliveryItemsTableTableManager get supplierDeliveryItems =>
      $$SupplierDeliveryItemsTableTableManager(
        _db.attachedDatabase,
        _db.supplierDeliveryItems,
      );
}
