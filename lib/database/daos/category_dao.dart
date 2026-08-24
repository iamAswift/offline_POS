//lib/database/daos/category_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/category_table.dart';
import '../models/category_model.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase> with _$CategoryDaoMixin {
  CategoryDao(super.db);

  // Get all categories
  Future<List<Category>> getAllCategories() => select(categories).get();

  // Get all categories for snapshot (non-reactive)
  Future<List<CategoryModel>> getAllCategoriesForSnapshot() async {
  final rows = await select(categories).get();

  return rows.map((row) => CategoryModel(
        id: row.id,
        name: row.name,
        imagePath: row.imagePath,
      )).toList();
}


  // Watch categories (for reactive UI)
  Stream<List<Category>> watchAllCategories() => select(categories).watch();

  // Insert new category
  Future<int> insertCategory(CategoriesCompanion category) =>
      into(categories).insert(category);

  // Update category

  
  Future<bool> updateCategory(Category category) =>
      update(categories).replace(category);

  // Delete category
  Future<int> deleteCategory(int id) =>
      (delete(categories)..where((tbl) => tbl.id.equals(id))).go();
}
