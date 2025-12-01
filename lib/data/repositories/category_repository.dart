import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/category_type.dart';
import '../local/app_database.dart';
import '../local/daos/categories_dao.dart';

class CategoryRepository {
  final CategoriesDao _categoriesDao;
  final _uuid = const Uuid();

  CategoryRepository(this._categoriesDao);

  // Get all categories
  Future<List<Category>> getAllCategories() =>
      _categoriesDao.getAllCategories();

  // Watch all categories
  Stream<List<Category>> watchAllCategories() =>
      _categoriesDao.watchAllCategories();

  // Get categories by type
  Future<List<Category>> getCategoriesByType(CategoryType type) =>
      _categoriesDao.getCategoriesByType(type);

  // Watch categories by type
  Stream<List<Category>> watchCategoriesByType(CategoryType type) =>
      _categoriesDao.watchCategoriesByType(type);

  // Create category
  Future<String> createCategory({
    required String name,
    required String icon,
    required String color,
    required CategoryType type,
  }) async {
    final id = _uuid.v4();
    final category = CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      icon: Value(icon),
      color: Value(color),
      type: Value(type),
    );
    await _categoriesDao.insertCategory(category);
    return id;
  }

  // Update category
  Future<bool> updateCategory({
    required String id,
    String? name,
    String? icon,
    String? color,
    CategoryType? type,
  }) async {
    final category = CategoriesCompanion(
      id: Value(id),
      name: name != null ? Value(name) : const Value.absent(),
      icon: icon != null ? Value(icon) : const Value.absent(),
      color: color != null ? Value(color) : const Value.absent(),
      type: type != null ? Value(type) : const Value.absent(),
    );
    return await _categoriesDao.updateCategory(category);
  }

  // Delete category
  Future<int> deleteCategory(String id) => _categoriesDao.deleteCategory(id);
}
