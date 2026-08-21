import 'package:drift/drift.dart';

import 'supplier_table.dart';

class SupplierPayments extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Supplier receiving the payment.
  IntColumn get supplierId =>
      integer().references(Suppliers, #id)();

  /// Date the payment was made.
  DateTimeColumn get paymentDate =>
      dateTime().withDefault(currentDateAndTime)();

  /// Amount actually paid.
  RealColumn get amount => real()();

  /// cash / pos / transfer / etc.
  TextColumn get paymentMethod =>
      text().withDefault(const Constant('cash'))();

  /// Bank transfer / POS reference where applicable.
  TextColumn get reference =>
      text().nullable()();

  /// Optional payment notes.
  TextColumn get notes =>
      text().nullable()();
}