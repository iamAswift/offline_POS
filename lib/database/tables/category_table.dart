// lib/database/tables/category_table.dart
import 'package:drift/drift.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get imagePath => text().nullable()(); // optional photo
}
