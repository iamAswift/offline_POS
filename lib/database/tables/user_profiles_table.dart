//lib/database/tables/user_profiles_table.dart
import 'package:drift/drift.dart';
import 'user_table.dart';


class UserProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();

  // Identity
  TextColumn get nin => text().nullable()(); // National ID
  TextColumn get phone => text().nullable()();
  TextColumn get guarantorName => text().nullable()();
  TextColumn get guarantorPhone => text().nullable()();

  // Payroll
  RealColumn get salary => real().withDefault(const Constant(0.0))();
  RealColumn get amountOwed => real().withDefault(const Constant(0.0))();

  // Accountability
  BoolColumn get canReceiveStock => boolean().withDefault(const Constant(false))();
  BoolColumn get canCountStock => boolean().withDefault(const Constant(false))();
}
