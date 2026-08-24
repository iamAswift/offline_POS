//lib/database/tables/supplier_delivery_table.dart

import 'package:drift/drift.dart';

import 'supplier_table.dart';

class SupplierDeliveries extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Supplier who made this delivery.
  IntColumn get supplierId =>
      integer().references(Suppliers, #id)();

  /// Date the goods were received.
  DateTimeColumn get deliveryDate =>
      dateTime().withDefault(currentDateAndTime)();

  /// Supplier invoice / delivery note number.
  TextColumn get invoiceNumber =>
      text().nullable()();

  /// Total value of this delivery.
  ///
  /// This is the supplier's purchase value, NOT the selling value.
  RealColumn get totalAmount =>
      real()();

  /// Optional notes about the delivery.
  TextColumn get notes =>
      text().nullable()();
}