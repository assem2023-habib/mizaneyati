import '../../repositories/budget_repository.dart';
import '../../core/utils/result.dart';

class DeleteBudgetUseCase {
  final BudgetRepository _repository;

  DeleteBudgetUseCase(this._repository);

  Future<Result<void>> execute(String budgetId) async {
    return await _repository.delete(budgetId);
  }
}
