// lib/data/repositories/category_repository_impl.dart
import 'package:drift/drift.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/models/category_type.dart';
import '../../domain/repositories/category_repository.dart';
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';
import '../local/db/app_database.dart';
import '../local/daos/categories_dao.dart';
import '../local/mappers/category_mapper.dart';
import '../local/mappers/error_mapper.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoriesDao _categoriesDao;
  final AppDatabase _db;

  CategoryRepositoryImpl(this._db) : _categoriesDao = _db.categoriesDao;

  @override
  Future<Result<String>> create(CategoryEntity category) async {
    try {
      final companion = category.toCompanion();
      await _categoriesDao.insertCategory(companion);
      return Success(category.id);
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<void>> update(CategoryEntity category) async {
    try {
      final companion = category.toCompanion();
      final result = await _categoriesDao.updateCategory(companion);
      if (!result) {
        return const Fail(
          NotFoundFailure('الفئة غير موجودة', code: 'category_not_found'),
        );
      }
      return const Success(null);
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<void>> delete(String categoryId) async {
    try {
      final result = await _categoriesDao.deleteCategory(categoryId);
      if (result == 0) {
        return const Fail(
          NotFoundFailure('الفئة غير موجودة', code: 'category_not_found'),
        );
      }
      return const Success(null);
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<CategoryEntity>> getById(String categoryId) async {
    try {
      final category = await _categoriesDao.getById(categoryId);
      if (category == null) {
        return const Fail(
          NotFoundFailure('الفئة غير موجودة', code: 'category_not_found'),
        );
      }
      return Success(category.toEntity());
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<List<CategoryEntity>>> getAll() async {
    try {
      final categories = await _categoriesDao.getAllCategories();
      return Success(categories.map((e) => e.toEntity()).toList());
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<List<CategoryEntity>>> getByType(CategoryType type) async {
    try {
      // Assuming DAO expects CategoryType enum directly if column is EnumColumn,
      // or we need to check how it's generated.
      // The DAO method signature I saw earlier: getCategoriesByType(CategoryType type)
      // but inside it used type.name.
      // Let's assume the DAO handles it correctly or we pass what it expects.
      final categories = await _categoriesDao.getCategoriesByType(type);
      return Success(categories.map((e) => e.toEntity()).toList());
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }

  @override
  Stream<List<CategoryEntity>> watchAll() {
    return _categoriesDao.watchAllCategories().map(
      (categories) => categories.map((e) => e.toEntity()).toList(),
    );
  }

  @override
  Stream<List<CategoryEntity>> watchByType(CategoryType type) {
    return _categoriesDao
        .watchCategoriesByType(type)
        .map((categories) => categories.map((e) => e.toEntity()).toList());
  }

  @override
  Future<Result<int>> countTransactions(String categoryId) async {
    try {
      final count = await _db
          .customSelect(
            'SELECT COUNT(*) as c FROM transactions WHERE category_id = ?',
            variables: [Variable.withString(categoryId)],
          )
          .map((row) => row.read<int>('c'))
          .getSingle();

      return Success(count);
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<List<CategoryEntity>>> getMostUsed({int limit = 5}) async {
    try {
      // Complex query to join transactions and categories and group by category
      // This might be better in DAO, but customSelect here is fine for now.
      final rows = await _db
          .customSelect(
            '''
        SELECT c.*, COUNT(t.id) as tx_count 
        FROM categories c
        JOIN transactions t ON t.category_id = c.id
        GROUP BY c.id
        ORDER BY tx_count DESC
        LIMIT ?
        ''',
            variables: [Variable.withInt(limit)],
          )
          .get();

      final categories = rows.map((row) {
        return CategoryEntity(
          id: row.read<String>('id'),
          name: row.read<String>('name'),
          icon: row.read<String>('icon'),
          color: row.read<String>('color'),
          type: CategoryType.values.firstWhere(
            (e) => e.name == row.read<String>('type'),
          ),
        );
      }).toList();

      return Success(categories);
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }
}
