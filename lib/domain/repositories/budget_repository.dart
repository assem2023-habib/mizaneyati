// lib/domain/repositories/budget_repository.dart
import '../entities/budget_entity.dart';
import '../../core/utils/result.dart';

/// Abstract repository for Budget operations
///
/// This defines the contract that the data layer must implement.
/// All mutation methods return Future<Result<T>> for error handling.
/// Reactive queries return Stream for real-time updates.
abstract class BudgetRepository {
  /// Creates a new budget and returns its ID
  Future<Result<String>> create(BudgetEntity budget);

  /// Updates an existing budget
  Future<Result<void>> update(BudgetEntity budget);

  /// Deletes a budget by ID
  Future<Result<void>> delete(String budgetId);

  /// Gets a budget by ID
  Future<Result<BudgetEntity>> getById(String budgetId);

  /// Gets all budgets
  Future<Result<List<BudgetEntity>>> getAll();

  /// Gets active budgets (within current period)
  Future<Result<List<BudgetEntity>>> getActiveBudgets();

  /// Watches active budgets for real-time updates
  Stream<List<BudgetEntity>> watchActiveBudgets();

  /// Watches all budgets for real-time updates
  Stream<List<BudgetEntity>> watchAll();

  /// Gets budgets for a specific category
  Future<Result<List<BudgetEntity>>> getByCategory(String categoryId);

  /// Gets budgets for a specific account
  Future<Result<List<BudgetEntity>>> getByAccount(String accountId);

  /// Calculates total spent amount for a budget in its period
  ///
  /// Returns the amount in minor units
  Future<Result<int>> calculateSpentForBudget(String budgetId);

  /// Gets budget progress (spent / total) as a percentage
  Future<Result<double>> getBudgetProgress(String budgetId);

  /// Checks if budget limit is exceeded
  Future<Result<bool>> isBudgetExceeded(String budgetId);
}
