// lib/domain/usecases/budget/get_budgets_usecase.dart
import '../../../core/utils/result.dart';
import '../../entities/budget_entity.dart';
import '../../repositories/budget_repository.dart';

class GetBudgetsUseCase {
  final BudgetRepository _budgetRepo;

  GetBudgetsUseCase(this._budgetRepo);

  Future<Result<List<BudgetEntity>>> execute() {
    return _budgetRepo.getAll();
  }

  Future<Result<List<BudgetEntity>>> active() {
    return _budgetRepo.getActiveBudgets();
  }

  Stream<List<BudgetEntity>> watchAll() {
    return _budgetRepo.watchAll();
  }

  Stream<List<BudgetEntity>> watchActive() {
    return _budgetRepo.watchActiveBudgets();
  }
}
