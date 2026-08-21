// lib/database/tables/settings_table.dart

import 'package:drift/drift.dart';

class Settings extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Every setting key must be unique.
  //
  // Examples:
  // currency
  // low_stock_threshold
  // staff_debt_limit
  TextColumn get key =>
      text().unique()();

  // Settings are stored as strings and parsed
  // by the application when needed.
  TextColumn get value =>
      text()();
}
