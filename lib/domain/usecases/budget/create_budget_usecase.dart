// lib/domain/usecases/budget/create_budget_usecase.dart
import 'package:uuid/uuid.dart';
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';
import '../entities/budget_entity.dart';
import '../repositories/budget_repository.dart';
import '../repositories/category_repository.dart';

class CreateBudgetUseCase {
  final BudgetRepository _budgetRepo;
  final CategoryRepository _categoryRepo;
  final Uuid _uuid = const Uuid();

  CreateBudgetUseCase(this._budgetRepo, this._categoryRepo);

  Future<Result<String>> call({
    required String name,
    required int amountMinor,
    required String categoryId,
    required DateTime startDate,
    required DateTime endDate,
    bool isRecurring = false,
  }) async {
    // 1. Validation
    if (amountMinor <= 0) {
      return const Fail(
        ValidationFailure(
          'مبلغ الميزانية يجب أن يكون أكبر من صفر',
          code: 'invalid_budget_amount',
        ),
      );
    }

    if (endDate.isBefore(startDate)) {
      return const Fail(
        ValidationFailure(
          'تاريخ الانتهاء يجب أن يكون بعد تاريخ البدء',
          code: 'invalid_date_range',
        ),
      );
    }

    // 2. Check Category Existence
    final catRes = await _categoryRepo.getById(categoryId);
    if (catRes is Fail) return catRes;

    // 3. Build Entity
    final id = _uuid.v4();
    final budget = BudgetEntity(
      id: id,
      name: name,
      amountMinor: amountMinor,
      categoryId: categoryId,
      startDate: startDate,
      endDate: endDate,
      isRecurring: isRecurring,
      isActive: true,
      createdAt: DateTime.now(),
    );

    // 4. Persist
    return await _budgetRepo.create(budget);
  }
}
