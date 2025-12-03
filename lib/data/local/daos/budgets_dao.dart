import 'package:drift/drift.dart';
import '../db/app_database.dart';
import '../db/tables.dart';

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

  // Get budget by ID
  Future<Budget?> getById(String id) =>
      (select(budgets)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  // Get active budgets
  Future<List<Budget>> getActiveBudgets() {
    final now = DateTime.now();
    return (select(budgets)..where(
          (tbl) =>
              tbl.isActive.equals(true) &
              tbl.startDate.isSmallerOrEqualValue(now) &
              tbl.endDate.isBiggerOrEqualValue(now),
        ))
        .get();
  }

  // Watch active budgets
  Stream<List<Budget>> watchActiveBudgets() {
    final now = DateTime.now();
    return (select(budgets)..where(
          (tbl) =>
              tbl.isActive.equals(true) &
              tbl.startDate.isSmallerOrEqualValue(now) &
              tbl.endDate.isBiggerOrEqualValue(now),
        ))
        .watch();
  }

  // Get budgets by category
  Future<List<Budget>> getBudgetsByCategory(String categoryId) => (select(
    budgets,
  )..where((tbl) => tbl.categoryId.equals(categoryId))).get();

  // Get budgets by account (if budget is linked to account, assuming schema has accountId)
  // Checking schema... assuming budgets table might not have accountId based on previous context,
  // but let's check if it was intended.
  // If not in schema, we skip or add it.
  // Assuming budget is global or per category for now as per common practice unless specified.
  // Wait, BudgetEntity usually has categoryId.
  // If no accountId in Budgets table, we can't implement getByAccount directly unless we mean "budgets that include transactions from this account" which is complex.
  // Let's assume for now we skip getByAccount if column doesn't exist, or check schema.
  // I will check schema in tables.dart to be sure.
}
