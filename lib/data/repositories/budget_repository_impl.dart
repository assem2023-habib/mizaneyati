// lib/data/repositories/budget_repository_impl.dart
import 'package:drift/drift.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';
import '../local/db/app_database.dart';
import '../local/daos/budgets_dao.dart';
import '../local/mappers/budget_mapper.dart';
import '../local/mappers/error_mapper.dart';

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
  Future<Result<List<BudgetEntity>>> getAll() async {
    try {
      final budgets = await _budgetsDao.getAllBudgets();
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
  Stream<List<BudgetEntity>> watchAll() {
    return _budgetsDao.watchAllBudgets().map(
      (budgets) => budgets.map((e) => e.toEntity()).toList(),
    );
  }

  @override
  Future<Result<List<BudgetEntity>>> getByAccount(String accountId) async {
    try {
      // Get all transactions for this account, extract unique category IDs,
      // then get budgets for those categories
      final result = await _db
          .customSelect(
            'SELECT DISTINCT category_id FROM transactions WHERE account_id = ?',
            variables: [Variable.withString(accountId)],
          )
          .get();

      final categoryIds = result
          .map((row) => row.read<String>('category_id'))
          .toList();

      if (categoryIds.isEmpty) {
        return const Success([]);
      }

      // Get budgets for these categories
      final budgets = await _budgetsDao.getAllBudgets();
      final filteredBudgets = budgets
          .where((budget) => categoryIds.contains(budget.categoryId))
          .map((e) => e.toEntity())
          .toList();

      return Success(filteredBudgets);
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<int>> calculateSpentForBudget(String budgetId) async {
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

  @override
  Future<Result<double>> getBudgetProgress(String budgetId) async {
    try {
      final budgetResult = await getById(budgetId);
      if (budgetResult is Fail) {
        return Fail((budgetResult as Fail).failure);
      }

      final budget = (budgetResult as Success<BudgetEntity>).value;
      final spentResult = await calculateSpentForBudget(budgetId);

      if (spentResult is Fail) {
        return Fail((spentResult as Fail).failure);
      }

      final spentMinor = (spentResult as Success<int>).value;
      final limitMinor = budget.limitAmount.minorUnits;

      if (limitMinor == 0) {
        return const Success(0.0);
      }

      final progress = (spentMinor / limitMinor) * 100;
      return Success(progress);
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<bool>> isBudgetExceeded(String budgetId) async {
    try {
      final budgetResult = await getById(budgetId);
      if (budgetResult is Fail) {
        return Fail((budgetResult as Fail).failure);
      }

      final budget = (budgetResult as Success<BudgetEntity>).value;
      final spentResult = await calculateSpentForBudget(budgetId);

      if (spentResult is Fail) {
        return Fail((spentResult as Fail).failure);
      }

      final spentMinor = (spentResult as Success<int>).value;
      final limitMinor = budget.limitAmount.minorUnits;

      return Success(spentMinor > limitMinor);
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }
}
