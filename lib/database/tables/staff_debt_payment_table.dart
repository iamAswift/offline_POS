//lib/database/tables/staff_debt_payment_table.dart

import 'package:drift/drift.dart';

import 'user_table.dart';

class StaffDebtPayments extends Table {
  // ============================================================
  // PRIMARY KEY
  // ============================================================

  IntColumn get id => integer().autoIncrement()();

  // ============================================================
  // STAFF
  // ============================================================

  IntColumn get staffId =>
      integer().references(Users, #id)();

  // ============================================================
  // PAYMENT
  // ============================================================

  RealColumn get amount => real()();

  // cash
  // payroll
  // transfer
  TextColumn get paymentMethod => text()();

  // ============================================================
  // DESCRIPTION
  // ============================================================

  TextColumn get note => text().nullable()();

  // ============================================================
  // WHO RECORDED IT
  // ============================================================

  IntColumn get recordedBy =>
      integer().references(Users, #id)();

  // ============================================================
  // DATE
  // ============================================================

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}