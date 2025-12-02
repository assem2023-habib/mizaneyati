import 'package:uuid/uuid.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../core/utils/error_mapper.dart';
import '../../domain/entities/budget_entity.dart';
import '../local/daos/budgets_dao.dart';
import '../local/mappers/budget_mapper.dart';

class BudgetRepository {
  final BudgetsDao _budgetsDao;
  final _uuid = const Uuid();

  BudgetRepository(this._budgetsDao);

  // Get all budgets
  Future<Result<List<BudgetEntity>>> getAllBudgets() async {
    try {
      final budgets = await _budgetsDao.getAllBudgets();
      final entities = budgets.map((b) => b.toEntity()).toList();
      return Success(entities);
    } on DatabaseException catch (e) {
      return Fail(DatabaseFailure(e.message, code: 'db_error'));
    } catch (e, stackTrace) {
      return Fail(mapDatabaseException(e, stackTrace));
    }
  }

  // Watch all budgets
  Stream<Result<List<BudgetEntity>>> watchAllBudgets() {
    try {
      return _budgetsDao.watchAllBudgets().map((budgets) {
        try {
          final entities = budgets.map((b) => b.toEntity()).toList();
          return Success(entities);
        } catch (e, stackTrace) {
          return Fail<List<BudgetEntity>>(mapDatabaseException(e, stackTrace));
        }
      });
    } catch (e, stackTrace) {
      return Stream.value(Fail(mapDatabaseException(e, stackTrace)));
    }
  }

  // Create budget
  Future<Result<String>> createBudget({
    required String categoryId,
    required double limitAmount,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Validation
      if (limitAmount <= 0) {
        return const Fail(
          ValidationFailure(
            'حد الميزانية يجب أن يكون أكبر من صفر',
            code: 'invalid_limit',
          ),
        );
      }

      if (startDate.isAfter(endDate)) {
        return const Fail(
          ValidationFailure(
            'تاريخ البداية يجب أن يكون قبل تاريخ النهاية',
            code: 'invalid_date_range',
          ),
        );
      }

      final id = _uuid.v4();
      final entity = BudgetEntity(
        id: id,
        categoryId: categoryId,
        limitAmountMinor: (limitAmount * 100).toInt(), // Convert to minor units
        startDate: startDate,
        endDate: endDate,
        isActive: true,
      );

      await _budgetsDao.insertBudget(entity.toCompanion());
      return Success(id);
    } on ValidationException catch (e) {
      return Fail(ValidationFailure(e.message, code: 'validation_error'));
    } on DatabaseException catch (e) {
      return Fail(DatabaseFailure(e.message, code: 'db_error'));
    } catch (e, stackTrace) {
      return Fail(mapDatabaseException(e, stackTrace));
    }
  }

  // Update budget
  Future<Result<bool>> updateBudget(BudgetEntity budget) async {
    try {
      // Validation
      if (budget.limitAmountMinor <= 0) {
        return const Fail(
          ValidationFailure(
            'حد الميزانية يجب أن يكون أكبر من صفر',
            code: 'invalid_limit',
          ),
        );
      }

      if (budget.startDate.isAfter(budget.endDate)) {
        return const Fail(
          ValidationFailure(
            'تاريخ البداية يجب أن يكون قبل تاريخ النهاية',
            code: 'invalid_date_range',
          ),
        );
      }

      final result = await _budgetsDao.updateBudget(budget.toCompanion());
      return Success(result);
    } on ValidationException catch (e) {
      return Fail(ValidationFailure(e.message, code: 'validation_error'));
    } on DatabaseException catch (e) {
      return Fail(DatabaseFailure(e.message, code: 'db_error'));
    } catch (e, stackTrace) {
      return Fail(mapDatabaseException(e, stackTrace));
    }
  }

  // Delete budget
  Future<Result<int>> deleteBudget(String id) async {
    try {
      final result = await _budgetsDao.deleteBudget(id);
      if (result == 0) {
        return const Fail(
          NotFoundFailure('الميزانية غير موجودة', code: 'budget_not_found'),
        );
      }
      return Success(result);
    } on DatabaseException catch (e) {
      return Fail(DatabaseFailure(e.message, code: 'db_error'));
    } catch (e, stackTrace) {
      return Fail(mapDatabaseException(e, stackTrace));
    }
  }
}
