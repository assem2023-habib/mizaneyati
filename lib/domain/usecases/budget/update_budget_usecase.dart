import '../../repositories/budget_repository.dart';
import '../../entities/budget_entity.dart';
import '../../core/utils/result.dart';

class UpdateBudgetUseCase {
  final BudgetRepository _repository;

  UpdateBudgetUseCase(this._repository);

  Future<Result<void>> execute(BudgetEntity budget) async {
    return await _repository.update(budget);
  }
}
