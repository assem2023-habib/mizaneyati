import 'package:uuid/uuid.dart';
import '../../domain/entities/budget_entity.dart';
import '../local/daos/budgets_dao.dart';
import '../local/mappers/budget_mapper.dart';

class BudgetRepository {
  final BudgetsDao _budgetsDao;
  final _uuid = const Uuid();

  BudgetRepository(this._budgetsDao);

  // Get all budgets
  Future<List<BudgetEntity>> getAllBudgets() async {
    final budgets = await _budgetsDao.getAllBudgets();
    return budgets.map((b) => b.toEntity()).toList();
  }

  // Watch all budgets
  Stream<List<BudgetEntity>> watchAllBudgets() {
    return _budgetsDao.watchAllBudgets().map(
      (budgets) => budgets.map((b) => b.toEntity()).toList(),
    );
  }

  // Create budget
  Future<String> createBudget({
    required String categoryId,
    required double limitAmount,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final id = _uuid.v4();
    final entity = BudgetEntity(
      id: id,
      categoryId: categoryId,
      limitAmount: limitAmount,
      startDate: startDate,
      endDate: endDate,
      isActive: true,
    );

    await _budgetsDao.insertBudget(entity.toCompanion());
    return id;
  }

  // Update budget
  Future<bool> updateBudget(BudgetEntity budget) async {
    return await _budgetsDao.updateBudget(budget.toCompanion());
  }

  // Delete budget
  Future<int> deleteBudget(String id) => _budgetsDao.deleteBudget(id);
}
