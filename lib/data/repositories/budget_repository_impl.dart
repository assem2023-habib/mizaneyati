// lib/data/repositories/budget_repository_impl.dart
import 'package:drift/drift.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';
import '../local/db/app_database.dart';
import '../local/daos/budgets_dao.dart';
import '../local/mappers/budget_mapper.dart';
import 'error_mapper.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetsDao _budgetsDao;
  final AppDatabase _db;

  BudgetRepositoryImpl(this._db) : _budgetsDao = _db.budgetsDao;

  @override
  Future<Result<String>> create(BudgetEntity budget) async {
    try {
      final companion = budget.toCompanion();
      await _budgetsDao.insertBudget(companion);
      return Success(budget.id);
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<void>> update(BudgetEntity budget) async {
    try {
      final companion = budget.toCompanion();
      final result = await _budgetsDao.updateBudget(companion);
      if (!result) {
        return const Fail(
          NotFoundFailure('الميزانية غير موجودة', code: 'budget_not_found'),
        );
      }
      return const Success(null);
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<void>> delete(String budgetId) async {
    try {
      final result = await _budgetsDao.deleteBudget(budgetId);
      if (result == 0) {
        return const Fail(
          NotFoundFailure('الميزانية غير موجودة', code: 'budget_not_found'),
        );
      }
      return const Success(null);
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<BudgetEntity>> getById(String budgetId) async {
    try {
      final budget = await _budgetsDao.getById(budgetId);
      if (budget == null) {
        return const Fail(
          NotFoundFailure('الميزانية غير موجودة', code: 'budget_not_found'),
        );
      }
      return Success(budget.toEntity());
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<List<BudgetEntity>>> getActiveBudgets() async {
    try {
      final budgets = await _budgetsDao.getActiveBudgets();
      return Success(budgets.map((e) => e.toEntity()).toList());
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<List<BudgetEntity>>> getByCategory(String categoryId) async {
    try {
      final budgets = await _budgetsDao.getBudgetsByCategory(categoryId);
      return Success(budgets.map((e) => e.toEntity()).toList());
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }

  @override
  Stream<List<BudgetEntity>> watchActiveBudgets() {
    return _budgetsDao.watchActiveBudgets().map(
      (budgets) => budgets.map((e) => e.toEntity()).toList(),
    );
  }

  @override
  Future<Result<int>> getSpentAmount(String budgetId) async {
    try {
      // 1. Get budget to know category and date range
      final budget = await _budgetsDao.getById(budgetId);
      if (budget == null) {
        return const Fail(
          NotFoundFailure('الميزانية غير موجودة', code: 'budget_not_found'),
        );
      }

      // 2. Sum transactions for this category within date range
      // We sum 'amount' (real) from transactions table
      final result = await _db
          .customSelect(
            'SELECT SUM(amount) as total FROM transactions '
            'WHERE category_id = ? AND date BETWEEN ? AND ?',
            variables: [
              Variable.withString(budget.categoryId),
              Variable.withDateTime(budget.startDate),
              Variable.withDateTime(budget.endDate),
            ],
          )
          .getSingle();

      final totalDouble = result.read<double?>('total') ?? 0.0;
      return Success((totalDouble * 100).toInt()); // Convert to minor units
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }
}
