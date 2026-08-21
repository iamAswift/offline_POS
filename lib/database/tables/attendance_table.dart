//lib/database/tables/attendance_table.dart

import 'package:drift/drift.dart';

class Attendance extends Table {
  // Unique attendance record
  IntColumn get id => integer().autoIncrement()();

  // Links attendance to the existing Users.id
  IntColumn get userId => integer()();

  // When the employee clocked in
  DateTimeColumn get clockIn => dateTime()();

  // When the employee clocked out.
  // Nullable because the employee may still be working.
  DateTimeColumn get clockOut => dateTime().nullable()();

  // Optional notes for future use
  TextColumn get notes => text().nullable()();

  // When this attendance record was created
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  // User who performed the correction
  IntColumn get correctedByUserId => integer().nullable()();

  // When the correction was made
  DateTimeColumn get correctedAt => dateTime().nullable()();

  // Why the attendance was corrected
  TextColumn get correctionNote => text().nullable()();

}