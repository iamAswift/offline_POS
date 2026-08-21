// lib/database/sales.dart
import 'package:drift/drift.dart';
import 'product_table.dart';
import 'user_table.dart'; // ✅ import users table

class Sales extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().references(Products, #id)();
  IntColumn get quantity => integer()();
  IntColumn get unitPrice => integer()(); // store in Naira
  RealColumn get costPriceAtSale =>
      real().withDefault(const Constant(0.0))();

  IntColumn get totalPrice => integer()();

  // Payment details
  TextColumn get paymentMethod => text()(); // "cash", "pos", "transfer", "split"
  RealColumn get cashAmount => real().nullable()();
  RealColumn get posAmount => real().nullable()();
  RealColumn get transferAmount => real().nullable()();

  // Status tracking
  TextColumn get status =>
      text().withDefault(const Constant("pending"))();

  // ✅ Assign sale to staff
  IntColumn get staffId => integer().references(Users, #id)();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

