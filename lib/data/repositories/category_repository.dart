import 'package:uuid/uuid.dart';
import '../../domain/models/category_type.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../core/utils/error_mapper.dart';
import '../../domain/entities/category_entity.dart';
import '../local/daos/categories_dao.dart';
import '../local/mappers/category_mapper.dart';

class CategoryRepository {
  final CategoriesDao _categoriesDao;
  final _uuid = const Uuid();

  CategoryRepository(this._categoriesDao);

  // Get all categories
  Future<Result<List<CategoryEntity>>> getAllCategories() async {
    try {
      final categories = await _categoriesDao.getAllCategories();
      final entities = categories.map((c) => c.toEntity()).toList();
      return Success(entities);
    } on DatabaseException catch (e) {
      return Fail(DatabaseFailure(e.message, code: 'db_error'));
    } catch (e, stackTrace) {
      return Fail(mapDatabaseException(e, stackTrace));
    }
  }

  // Watch all categories
  Stream<Result<List<CategoryEntity>>> watchAllCategories() {
    try {
      return _categoriesDao.watchAllCategories().map((categories) {
        try {
          final entities = categories.map((c) => c.toEntity()).toList();
          return Success(entities);
        } catch (e, stackTrace) {
          return Fail<List<CategoryEntity>>(
            mapDatabaseException(e, stackTrace),
          );
        }
      });
    } catch (e, stackTrace) {
      return Stream.value(Fail(mapDatabaseException(e, stackTrace)));
    }
  }

  // Get categories by type
  Future<Result<List<CategoryEntity>>> getCategoriesByType(
    CategoryType type,
  ) async {
    try {
      final categories = await _categoriesDao.getCategoriesByType(type);
      final entities = categories.map((c) => c.toEntity()).toList();
      return Success(entities);
    } on DatabaseException catch (e) {
      return Fail(DatabaseFailure(e.message, code: 'db_error'));
    } catch (e, stackTrace) {
      return Fail(mapDatabaseException(e, stackTrace));
    }
  }

  // Watch categories by type
  Stream<Result<List<CategoryEntity>>> watchCategoriesByType(
    CategoryType type,
  ) {
    try {
      return _categoriesDao.watchCategoriesByType(type).map((categories) {
        try {
          final entities = categories.map((c) => c.toEntity()).toList();
          return Success(entities);
        } catch (e, stackTrace) {
          return Fail<List<CategoryEntity>>(
            mapDatabaseException(e, stackTrace),
          );
        }
      });
    } catch (e, stackTrace) {
      return Stream.value(Fail(mapDatabaseException(e, stackTrace)));
    }
  }

  // Create category
  Future<Result<String>> createCategory({
    required String name,
    required String icon,
    required String color,
    required CategoryType type,
  }) async {
    try {
      // Validation
      if (name.trim().isEmpty) {
        return const Fail(
          ValidationFailure('اسم الفئة مطلوب', code: 'empty_name'),
        );
      }

      final id = _uuid.v4();
      final entity = CategoryEntity(
        id: id,
        name: name,
        icon: icon,
        color: color,
        type: type,
      );

      await _categoriesDao.insertCategory(entity.toCompanion());
      return Success(id);
    } on ValidationException catch (e) {
      return Fail(ValidationFailure(e.message, code: 'validation_error'));
    } on DatabaseException catch (e) {
      return Fail(DatabaseFailure(e.message, code: 'db_error'));
    } catch (e, stackTrace) {
      return Fail(mapDatabaseException(e, stackTrace));
    }
  }

  // Update category
  Future<Result<bool>> updateCategory(CategoryEntity category) async {
    try {
      // Validation
      if (category.name.trim().isEmpty) {
        return const Fail(
          ValidationFailure('اسم الفئة مطلوب', code: 'empty_name'),
        );
      }

      final result = await _categoriesDao.updateCategory(
        category.toCompanion(),
      );
      return Success(result);
    } on ValidationException catch (e) {
      return Fail(ValidationFailure(e.message, code: 'validation_error'));
    } on DatabaseException catch (e) {
      return Fail(DatabaseFailure(e.message, code: 'db_error'));
    } catch (e, stackTrace) {
      return Fail(mapDatabaseException(e, stackTrace));
    }
  }

  // Delete category
  Future<Result<int>> deleteCategory(String id) async {
    try {
      final result = await _categoriesDao.deleteCategory(id);
      if (result == 0) {
        return const Fail(
          NotFoundFailure('الفئة غير موجودة', code: 'category_not_found'),
        );
      }
      return Success(result);
    } on DatabaseException catch (e) {
      // Foreign key constraint (category has transactions)
      if (e.message.contains('FOREIGN KEY')) {
        return const Fail(
          DatabaseFailure(
            'لا يمكن حذف هذه الفئة لأنها مرتبطة بعمليات',
            code: 'category_has_transactions',
          ),
        );
      }
      return Fail(DatabaseFailure(e.message, code: 'db_error'));
    } catch (e, stackTrace) {
      return Fail(mapDatabaseException(e, stackTrace));
    }
  }
}
