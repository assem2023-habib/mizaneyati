import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriesDaoMixin {
  CategoriesDao(AppDatabase db) : super(db);

  // Get all categories
  Future<List<Category>> getAllCategories() => select(categories).get();

  // Watch all categories
  Stream<List<Category>> watchAllCategories() => select(categories).watch();

  // Get categories by type
  Future<List<Category>> getCategoriesByType(CategoryType type) =>
      (select(categories)..where((tbl) => tbl.type.equals(type.name))).get();

  // Watch categories by type
  Stream<List<Category>> watchCategoriesByType(CategoryType type) =>
      (select(categories)..where((tbl) => tbl.type.equals(type.name))).watch();

  // Insert category
  Future<int> insertCategory(CategoriesCompanion category) =>
      into(categories).insert(category);

  // Update category
  Future<bool> updateCategory(CategoriesCompanion category) =>
      update(categories).replace(category);

  // Delete category
  Future<int> deleteCategory(String id) =>
      (delete(categories)..where((tbl) => tbl.id.equals(id))).go();
}
