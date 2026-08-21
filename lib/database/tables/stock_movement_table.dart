//lib/database/tables/stock_movement_table.dart
import 'package:drift/drift.dart';
import 'product_table.dart';
import 'supplier_table.dart';
import 'supplier_delivery_table.dart';

class StockMovements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId =>
      integer().references(Products, #id)(); // foreign key to Products
  IntColumn get supplierId =>
      integer().nullable().references(Suppliers, #id)(); // foreign key to Suppliers, nullable for non-supplier movements
  TextColumn get type =>
      text()(); // e.g. "purchase", "sale", "return", "adjustment"

  // Supplier delivery that caused this stock movement.
  // NULL for movements that did not originate from a supplier delivery.
  IntColumn get deliveryId =>
      integer()
          .nullable()
          .references(SupplierDeliveries, #id)();


  IntColumn get quantity => integer()();
  RealColumn get unitPrice => real()(); // price per unit for this movement
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
}
