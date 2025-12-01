import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/category_type.dart';
import '../../domain/entities/category_entity.dart';
import '../local/app_database.dart';
import '../local/daos/categories_dao.dart';
import '../local/mappers/category_mapper.dart';

class CategoryRepository {
  final CategoriesDao _categoriesDao;
  final _uuid = const Uuid();

  CategoryRepository(this._categoriesDao);

  // Get all categories
  Future<List<CategoryEntity>> getAllCategories() async {
    final categories = await _categoriesDao.getAllCategories();
    return categories.map((c) => c.toEntity()).toList();
  }

  // Watch all categories
  Stream<List<CategoryEntity>> watchAllCategories() {
    return _categoriesDao.watchAllCategories().map(
      (categories) => categories.map((c) => c.toEntity()).toList(),
    );
  }

  // Get categories by type
  Future<List<CategoryEntity>> getCategoriesByType(CategoryType type) async {
    final categories = await _categoriesDao.getCategoriesByType(type);
    return categories.map((c) => c.toEntity()).toList();
  }

  // Watch categories by type
  Stream<List<CategoryEntity>> watchCategoriesByType(CategoryType type) {
    return _categoriesDao
        .watchCategoriesByType(type)
        .map((categories) => categories.map((c) => c.toEntity()).toList());
  }

  // Create category
  Future<String> createCategory({
    required String name,
    required String icon,
    required String color,
    required CategoryType type,
  }) async {
    final id = _uuid.v4();
    final entity = CategoryEntity(
      id: id,
      name: name,
      icon: icon,
      color: color,
      type: type,
    );

    await _categoriesDao.insertCategory(entity.toCompanion());
    return id;
  }

  // Update category
  Future<bool> updateCategory(CategoryEntity category) async {
    return await _categoriesDao.updateCategory(category.toCompanion());
  }

  // Delete category
  Future<int> deleteCategory(String id) => _categoriesDao.deleteCategory(id);
}
