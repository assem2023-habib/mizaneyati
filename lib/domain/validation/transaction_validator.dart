// lib/domain/validation/transaction_validator.dart
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';
import '../models/transaction_type.dart';
import '../models/category_type.dart';

/// Transaction validation logic
/// All validators return Result<void> for consistency
class TransactionValidator {
  TransactionValidator._();

  /// Maximum allowed time skew for future date validation (5 minutes)
  static const Duration allowedSkew = Duration(minutes: 5);

  /// Validates that the amount is greater than zero
  ///
  /// Returns [Success] if valid, [Fail] with [ValidationFailure] otherwise
  static Result<void> validateAmount(int minorAmount) {
    if (minorAmount <= 0) {
      return const Fail(
        ValidationFailure(
          'المبلغ يجب أن يكون أكبر من صفر',
          code: 'invalid_amount',
        ),
      );
    }
    return const Success(null);
  }

  /// Validates that the date is not in the future (with small skew allowed)
  ///
  /// Returns [Success] if valid, [Fail] with [ValidationFailure] otherwise
  static Result<void> validateNotFutureDate(DateTime date) {
    final now = DateTime.now();
    if (date.isAfter(now.add(allowedSkew))) {
      return const Fail(
        ValidationFailure(
          'التاريخ لا يمكن أن يكون في المستقبل',
          code: 'future_date',
        ),
      );
    }
    return const Success(null);
  }

  /// Validates that the category type matches the transaction type
  ///
  /// For expense transactions, category must be expense type
  /// For income transactions, category must be income type
  /// Transfer transactions don't use categories
  static Result<void> validateCategoryForTransaction(
    TransactionType txType,
    CategoryType categoryType,
  ) {
    if (txType == TransactionType.expense &&
        categoryType != CategoryType.expense) {
      return const Fail(
        ValidationFailure(
          'الفئة لا تتطابق مع نوع العملية (يجب أن تكون فئة مصروف)',
          code: 'category_type_mismatch',
        ),
      );
    }
    if (txType == TransactionType.income &&
        categoryType != CategoryType.income) {
      return const Fail(
        ValidationFailure(
          'الفئة لا تتطابق مع نوع العملية (يجب أن تكون فئة دخل)',
          code: 'category_type_mismatch',
        ),
      );
    }
    return const Success(null);
  }

  /// Validates transfer accounts are both present and different
  ///
  /// Returns [Success] if valid, [Fail] with [ValidationFailure] otherwise
  static Result<void> validateTransferAccounts({
    required String? fromAccountId,
    required String? toAccountId,
  }) {
    if (fromAccountId == null || toAccountId == null) {
      return const Fail(
        ValidationFailure(
          'يجب تحديد الحساب المصدر والحساب الوجهة للتحويل',
          code: 'transfer_accounts_missing',
        ),
      );
    }
    if (fromAccountId == toAccountId) {
      return const Fail(
        ValidationFailure(
          'لا يمكن تحويل الأموال إلى نفس الحساب',
          code: 'transfer_same_account',
        ),
      );
    }
    return const Success(null);
  }

  /// Validates note length if provided
  static Result<void> validateNote(String? note, {int maxLength = 500}) {
    if (note != null && note.length > maxLength) {
      return Fail(
        ValidationFailure(
          'الملاحظة طويلة جداً (الحد الأقصى $maxLength حرف)',
          code: 'note_too_long',
          info: {'maxLength': maxLength, 'actualLength': note.length},
        ),
      );
    }
    return const Success(null);
  }
}
