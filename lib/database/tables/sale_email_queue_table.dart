// lib/database/tables/sale_email_queue_table.dart

import 'package:drift/drift.dart';

class SaleEmailQueues extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// The sale this notification belongs to.
  IntColumn get saleId => integer()();

  /// Owner/recipient email address.
  TextColumn get recipient => text()();

  /// Email subject.
  TextColumn get subject => text()();

  /// Email body.
  TextColumn get body => text()();

  /// Queue lifecycle:
  /// pending -> sending -> sent
  /// sending -> failed -> pending
  TextColumn get status =>
      text().withDefault(const Constant('pending'))();

  /// Number of delivery attempts.
  IntColumn get attempts =>
      integer().withDefault(const Constant(0))();

  /// When this job was created.
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  /// Last time delivery was attempted.
  DateTimeColumn get lastAttemptAt =>
      dateTime().nullable()();

  /// When the email was successfully sent.
  DateTimeColumn get sentAt =>
      dateTime().nullable()();

  /// Last delivery error, if any.
  TextColumn get lastError =>
      text().nullable()();
}
