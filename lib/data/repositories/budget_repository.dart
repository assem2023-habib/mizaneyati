import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../local/app_database.dart';
import '../local/daos/budgets_dao.dart';

class BudgetRepository {
  final BudgetsDao _budgetsDao;
  final _uuid = const Uuid();

  BudgetRepository(this._budgetsDao);

  // Get all budgets
  Future<List<Budget>> getAllBudgets() => _budgetsDao.getAllBudgets();

  // Watch all budgets
  Stream<List<Budget>> watchAllBudgets() => _budgetsDao.watchAllBudgets();

  // Create budget
  Future<String> createBudget({
    required String categoryId,
    required double limitAmount,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final id = _uuid.v4();
    final budget = BudgetsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      limitAmount: Value(limitAmount),
      startDate: Value(startDate),
      endDate: Value(endDate),
      isActive: const Value(true),
    );
    await _budgetsDao.insertBudget(budget);
    return id;
  }

  // Update budget
  Future<bool> updateBudget({
    required String id,
    String? categoryId,
    double? limitAmount,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) async {
    final budget = BudgetsCompanion(
      id: Value(id),
      categoryId: categoryId != null ? Value(categoryId) : const Value.absent(),
      limitAmount: limitAmount != null
          ? Value(limitAmount)
          : const Value.absent(),
      startDate: startDate != null ? Value(startDate) : const Value.absent(),
      endDate: endDate != null ? Value(endDate) : const Value.absent(),
      isActive: isActive != null ? Value(isActive) : const Value.absent(),
    );
    return await _budgetsDao.updateBudget(budget);
  }

  // Delete budget
  Future<int> deleteBudget(String id) => _budgetsDao.deleteBudget(id);
}
