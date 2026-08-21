// lib/database/tables/product_table.dart
import 'package:drift/drift.dart';
import 'category_table.dart';

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get barcode => text().nullable()();
  TextColumn get name => text()();
  TextColumn get brand => text().nullable()();
  IntColumn get categoryId => integer().references(Categories, #id)(); // ✅ link
  TextColumn get unit => text()(); // e.g. "pcs", "kg"
  RealColumn get costPrice => real()();
  RealColumn get sellingPrice => real()();
  
  ///  stock quantity
  IntColumn get stock => integer().withDefault(const Constant(0))();

  TextColumn get imagePath => text().nullable()();

  DateTimeColumn get expiryDate => dateTime().nullable()();
}
