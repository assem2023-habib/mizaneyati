// lib/domain/usecases/budget/get_budget_status_usecase.dart
import '../../core/utils/result.dart';
import '../entities/budget_entity.dart';
import '../repositories/budget_repository.dart';

class BudgetStatus {
  final BudgetEntity budget;
  final int spentMinor;
  final int remainingMinor;
  final double progress; // 0.0 to 1.0 (or more if exceeded)
  final bool isExceeded;

  BudgetStatus({
    required this.budget,
    required this.spentMinor,
    required this.remainingMinor,
    required this.progress,
    required this.isExceeded,
  });
}

class GetBudgetStatusUseCase {
  final BudgetRepository _budgetRepo;

  GetBudgetStatusUseCase(this._budgetRepo);

  Future<Result<BudgetStatus>> call(String budgetId) async {
    // 1. Get Budget
    final budgetRes = await _budgetRepo.getById(budgetId);
    if (budgetRes is Fail) return Fail((budgetRes as Fail).failure);
    final budget = (budgetRes as Success<BudgetEntity>).value;

    // 2. Calculate Spent
    final spentRes = await _budgetRepo.calculateSpentForBudget(budgetId);
    if (spentRes is Fail) return Fail((spentRes as Fail).failure);
    final spentMinor = (spentRes as Success<int>).value;

    // 3. Calculate Status
    final remainingMinor = budget.amountMinor - spentMinor;
    final progress = spentMinor / budget.amountMinor;
    final isExceeded = spentMinor > budget.amountMinor;

    return Success(
      BudgetStatus(
        budget: budget,
        spentMinor: spentMinor,
        remainingMinor: remainingMinor,
        progress: progress,
        isExceeded: isExceeded,
      ),
    );
  }
}
