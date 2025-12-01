import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'budgets_dao.g.dart';

@DriftAccessor(tables: [Budgets])
class BudgetsDao extends DatabaseAccessor<AppDatabase> with _$BudgetsDaoMixin {
  BudgetsDao(AppDatabase db) : super(db);

  // Get all budgets
  Future<List<Budget>> getAllBudgets() => select(budgets).get();

  // Watch all budgets
  Stream<List<Budget>> watchAllBudgets() => select(budgets).watch();

  // Insert budget
  Future<int> insertBudget(BudgetsCompanion budget) =>
      into(budgets).insert(budget);

  // Update budget
  Future<bool> updateBudget(BudgetsCompanion budget) =>
      update(budgets).replace(budget);

  // Delete budget
  Future<int> deleteBudget(String id) =>
      (delete(budgets)..where((tbl) => tbl.id.equals(id))).go();
}
