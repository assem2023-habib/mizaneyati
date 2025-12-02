// lib/domain/repositories/category_repository.dart
import '../entities/category_entity.dart';
import '../models/category_type.dart';
import '../../core/utils/result.dart';

/// Abstract repository for Category operations
///
/// This defines the contract that the data layer must implement.
/// All mutation methods return Future<Result<T>> for error handling.
/// Reactive queries return Stream for real-time updates.
abstract class CategoryRepository {
  /// Creates a new category and returns its ID
  Future<Result<String>> create(CategoryEntity category);

  /// Updates an existing category
  Future<Result<void>> update(CategoryEntity category);

  /// Deletes a category by ID
  Future<Result<void>> delete(String categoryId);

  /// Gets a category by ID
  Future<Result<CategoryEntity>> getById(String categoryId);

  /// Gets all categories
  Future<Result<List<CategoryEntity>>> getAll();

  /// Gets categories by type (income or expense)
  Future<Result<List<CategoryEntity>>> getByType(CategoryType type);

  /// Watches all categories for real-time updates
  Stream<List<CategoryEntity>> watchAll();

  /// Watches categories by type for real-time updates
  Stream<List<CategoryEntity>> watchByType(CategoryType type);

  /// Counts transactions for a category
  Future<Result<int>> countTransactions(String categoryId);

  /// Gets the most used categories (by transaction count)
  Future<Result<List<CategoryEntity>>> getMostUsed({int limit = 5});
}
