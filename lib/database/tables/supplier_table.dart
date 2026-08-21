//lib/database/tables/supplier_table.dart
import 'package:drift/drift.dart';

class Suppliers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()(); // supplier name
  TextColumn get contact => text().nullable()(); // phone/email
  TextColumn get address => text().nullable()();
  TextColumn get notes => text().nullable()(); // optional notes
}
