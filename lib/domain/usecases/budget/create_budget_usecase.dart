// lib/domain/usecases/budget/create_budget_usecase.dart
import 'package:uuid/uuid.dart';
import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../entities/budget_entity.dart';
import '../../repositories/budget_repository.dart';
import '../../repositories/category_repository.dart';
import '../../value_objects/money.dart';
import '../../value_objects/date_value.dart';

class CreateBudgetUseCase {
  final BudgetRepository _budgetRepo;
  final CategoryRepository _categoryRepo;
  final Uuid _uuid = const Uuid();

  CreateBudgetUseCase(this._budgetRepo, this._categoryRepo);

  Future<Result<Object>> call({
    required int limitAmountMinor,
    required String categoryId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // 1. Create Value Objects (Validation)
    final limitResult = Money.create(limitAmountMinor);
    if (limitResult is Fail) return limitResult;

    final startResult = DateValue.create(startDate);
    if (startResult is Fail) return startResult;

    final endResult = DateValue.create(endDate);
    if (endResult is Fail) return endResult;

    // 2. Business Validation
    if (endDate.isBefore(startDate) || endDate.isAtSameMomentAs(startDate)) {
      return const Fail(
        ValidationFailure(
          'End date must be after start date',
          code: 'invalid_date_range',
        ),
      );
    }

    // 3. Check Category Existence
    final catRes = await _categoryRepo.getById(categoryId);
    if (catRes is Fail) return catRes;

    // 4. Build Entity
    final id = _uuid.v4();
    final budget = BudgetEntity(
      id: id,
      categoryId: categoryId,
      limitAmount: (limitResult as Success<Money>).value,
      startDate: (startResult as Success<DateValue>).value,
      endDate: (endResult as Success<DateValue>).value,
      isActive: true,
    );

    // 5. Persist
    return await _budgetRepo.create(budget);
  }
}
