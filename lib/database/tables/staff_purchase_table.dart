//lib/database/tables/staff_purchase_table.dart

import 'package:drift/drift.dart';

import 'user_table.dart';
import 'product_table.dart';
import 'sales_table.dart';

class StaffPurchases extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Staff member who made the purchase
  IntColumn get staffId =>
      integer().references(Users, #id)();

  // Product purchased
  IntColumn get productId =>
      integer().references(Products, #id)();

  // Quantity purchased
  IntColumn get quantity =>
      integer()();

  // Selling price per unit
  // Stored at the time of purchase.
  RealColumn get unitPrice =>
      real()();

  // Total value of the purchase
  RealColumn get totalAmount =>
      real()();

  // cash or credit
  TextColumn get paymentType =>
      text()();

  // Amount paid immediately
  RealColumn get amountPaid =>
      real().withDefault(const Constant(0.0))();

  // Amount added to staff debt
  RealColumn get debtAmount =>
      real().withDefault(const Constant(0.0))();

  // Link to the corresponding Sales record
  IntColumn get saleId =>
      integer()
          .nullable()
          .references(Sales, #id)();

  // Optional note
  TextColumn get note =>
      text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}
