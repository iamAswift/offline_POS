//lib/database/tables/user_table.dart
import 'package:drift/drift.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  // Nullable initially so existing users can be migrated safely.
  TextColumn get loginId => text().nullable()();
  TextColumn get email => text().unique()();
  TextColumn get password => text()();

  // Account status
  // true  = employee can log in
  // false = employee cannot log in
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true))();


  // Roles: owner, manager, staff
  TextColumn get role => text().withDefault(const Constant('staff'))();

}


