// lib/domain/validation/budget_validator.dart

import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../entities/budget_entity.dart';

/// Budget validation logic
/// All validators return `Result<void>` for consistency.
class BudgetValidator {
  BudgetValidator._();

  /// Validates that the limit amount is greater than zero.
  static Result<void> validateLimitAmount(int limitMinor) {
    if (limitMinor <= 0) {
      return const Fail(
        ValidationFailure(
          'قيمة الحد الأقصى للميزانية يجب أن تكون أكبر من الصفر',
          code: 'budget_limit_non_positive',
        ),
      );
    }
    return const Success(null);
  }

  /// Validates that the start date is not after the end date.
  static Result<void> validateDateRange(DateTime start, DateTime end) {
    if (end.isBefore(start) || end.isAtSameMomentAs(start)) {
      return const Fail(
        ValidationFailure(
          'تاريخ الانتهاء يجب أن يكون بعد تاريخ البدء',
          code: 'budget_invalid_date_range',
        ),
      );
    }
    return const Success(null);
  }

  /// Validates that a new budget does not overlap with existing budgets of the same category.
  ///
  /// `existingBudgets` is a list of budgets that belong to the same category.
  /// The method checks that the new budget period does not intersect any existing period.
  static Result<void> validateNoOverlap({
    required DateTime newStart,
    required DateTime newEnd,
    required List<BudgetEntity> existingBudgets,
  }) {
    for (final budget in existingBudgets) {
      final existingStart = budget.startDate.value;
      final existingEnd = budget.endDate.value;
      final overlap =
          !(newEnd.isBefore(existingStart) || newStart.isAfter(existingEnd));
      if (overlap) {
        return const Fail(
          ValidationFailure(
            'يتعارض تاريخ الميزانية مع ميزانية أخرى لنفس الفئة',
            code: 'budget_date_overlap',
          ),
        );
      }
    }
    return const Success(null);
  }
}
