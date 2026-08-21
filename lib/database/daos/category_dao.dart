import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/category_table.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase> with _$CategoryDaoMixin {
  CategoryDao(super.db);

  // Get all categories
  Future<List<Category>> getAllCategories() => select(categories).get();

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
