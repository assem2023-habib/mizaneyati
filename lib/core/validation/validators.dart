// lib/core/validation/validators.dart

import '../errors/failures.dart';
import '../utils/result.dart';
import '../../domain/models/transaction_type.dart';
import '../../domain/models/category_type.dart';

/// Type alias for validation results
typedef ValidationResult = Result<void>;

/// Centralized validation rules for the mizaneyati application
///
/// All validators return `Result<void>` for seamless integration with
/// the existing Result/Failure pattern.
///
/// Usage in UseCases/Repositories:
/// ```dart
/// final validation = Validators.validateAmount(amount);
/// if (validation is Fail) return validation;
/// ```
class Validators {
  // Private constructor to prevent instantiation
  Validators._();

  /// Validates that an amount is greater than zero
  ///
  /// Returns:
  /// - Success(null) if amount > 0
  /// - Fail(ValidationFailure) if amount <= 0
  ///
  /// Example:
  /// ```dart
  /// final result = Validators.validateAmount(100.0);
  /// // Returns: Success(null)
  ///
  /// final result2 = Validators.validateAmount(0);
  /// // Returns: Fail(ValidationFailure('المبلغ يجب أن يكون أكبر من صفر'))
  /// ```
  static ValidationResult validateAmount(double amount) {
    if (amount <= 0) {
      return const Fail(
        ValidationFailure(
          'المبلغ يجب أن يكون أكبر من صفر',
          code: 'invalid_amount',
        ),
      );
    }
    return const Success(null);
  }

  /// Validates that an account is active
  ///
  /// Parameters:
  /// - [isActive]: The active status of the account
  /// - [accountId]: Optional account ID for error context
  ///
  /// Returns:
  /// - Success(null) if account is active
  /// - Fail(ValidationFailure) if account is inactive
  ///
  /// Example:
  /// ```dart
  /// final account = await accountRepo.getAccountById(id);
  /// final result = Validators.validateAccountActive(
  ///   account.isActive,
  ///   accountId: account.id,
  /// );
  /// ```
  static ValidationResult validateAccountActive(
    bool isActive, {
    String? accountId,
  }) {
    if (!isActive) {
      return Fail(
        ValidationFailure(
          'الحساب غير مفعل',
          code: 'account_inactive',
          info: accountId != null ? {'accountId': accountId} : null,
        ),
      );
    }
    return const Success(null);
  }

  /// Validates that a category type matches the transaction type
  ///
  /// Rules:
  /// - If transaction is expense → category must be expense
  /// - If transaction is income → category must be income
  /// - Transfer transactions don't require category validation
  ///
  /// Parameters:
  /// - [txType]: The transaction type
  /// - [categoryType]: The category type
  /// - [categoryId]: Optional category ID for error context
  ///
  /// Example:
  /// ```dart
  /// final result = Validators.validateCategoryForTransaction(
  ///   TransactionType.expense,
  ///   CategoryType.income, // Wrong!
  ///   categoryId: 'cat-123',
  /// );
  /// // Returns: Fail with mismatch error
  /// ```
  static ValidationResult validateCategoryForTransaction(
    TransactionType txType,
    CategoryType categoryType, {
    String? categoryId,
  }) {
    // Transfer transactions don't need category validation
    if (txType == TransactionType.transfer) {
      return const Success(null);
    }

    // Check if types match
    if (txType == TransactionType.expense &&
        categoryType != CategoryType.expense) {
      return Fail(
        ValidationFailure(
          'الفئة لا تتطابق مع نوع العملية (يجب أن تكون فئة مصروف)',
          code: 'category_type_mismatch',
          info: categoryId != null ? {'categoryId': categoryId} : null,
        ),
      );
    }

    if (txType == TransactionType.income &&
        categoryType != CategoryType.income) {
      return Fail(
        ValidationFailure(
          'الفئة لا تتطابق مع نوع العملية (يجب أن تكون فئة دخل)',
          code: 'category_type_mismatch',
          info: categoryId != null ? {'categoryId': categoryId} : null,
        ),
      );
    }

    return const Success(null);
  }

  /// Validates that a date is not in the future
  ///
  /// Parameters:
  /// - [date]: The date to validate
  /// - [allowedSkew]: Allowed time difference to account for clock skew (default: 5 minutes)
  ///
  /// Returns:
  /// - Success(null) if date is not in future (considering skew)
  /// - Fail(ValidationFailure) if date is in the future
  ///
  /// Example:
  /// ```dart
  /// final result = Validators.validateNotFutureDate(
  ///   DateTime.now().add(Duration(days: 1)),
  /// );
  /// // Returns: Fail (future date)
  /// ```
  static ValidationResult validateNotFutureDate(
    DateTime date, {
    Duration allowedSkew = const Duration(minutes: 5),
  }) {
    final now = DateTime.now();
    if (date.isAfter(now.add(allowedSkew))) {
      return Fail(
        ValidationFailure(
          'التاريخ لا يمكن أن يكون في المستقبل',
          code: 'future_date',
          info: {'date': date.toIso8601String()},
        ),
      );
    }
    return const Success(null);
  }

  /// Validates transfer transaction requirements
  ///
  /// Rules:
  /// - Both fromAccountId and toAccountId must be provided
  /// - The two accounts must be different
  ///
  /// Parameters:
  /// - [fromAccountId]: Source account ID
  /// - [toAccountId]: Destination account ID
  ///
  /// Example:
  /// ```dart
  /// final result = Validators.validateTransfer(
  ///   fromAccountId: 'acc-1',
  ///   toAccountId: 'acc-1', // Same account!
  /// );
  /// // Returns: Fail (same account error)
  /// ```
  static ValidationResult validateTransfer({
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

  /// Validates if a category can be deleted
  ///
  /// A category cannot be deleted if it has associated transactions.
  ///
  /// Parameters:
  /// - [transactionsCount]: Number of transactions using this category
  ///
  /// Example:
  /// ```dart
  /// final count = await repo.getTransactionCountForCategory(categoryId);
  /// final result = Validators.canDeleteCategory(count);
  /// if (result is Fail) {
  ///   // Show error to user
  /// }
  /// ```
  static ValidationResult canDeleteCategory(int transactionsCount) {
    if (transactionsCount > 0) {
      return Fail(
        ValidationFailure(
          'لا يمكن حذف الفئة لأنها تحتوي على معاملات',
          code: 'category_has_transactions',
          info: {'count': transactionsCount},
        ),
      );
    }
    return const Success(null);
  }

  /// Validates if an account can be deleted
  ///
  /// Rules:
  /// - Account cannot be deleted if it has transactions
  /// - Optionally, account balance must be zero (if requireZeroBalance is true)
  ///
  /// Parameters:
  /// - [transactionsCount]: Number of transactions in this account
  /// - [balance]: Current account balance
  /// - [requireZeroBalance]: Whether to enforce zero balance requirement
  ///
  /// Example:
  /// ```dart
  /// final count = await repo.getTransactionCountForAccount(accountId);
  /// final account = await repo.getAccountById(accountId);
  /// final result = Validators.canDeleteAccount(
  ///   transactionsCount: count,
  ///   balance: account.balance,
  ///   requireZeroBalance: true,
  /// );
  /// ```
  static ValidationResult canDeleteAccount({
    required int transactionsCount,
    required double balance,
    bool requireZeroBalance = false,
  }) {
    if (transactionsCount > 0) {
      return Fail(
        ValidationFailure(
          'لا يمكن حذف الحساب لأنه يحتوي على معاملات',
          code: 'account_has_transactions',
          info: {'count': transactionsCount},
        ),
      );
    }

    if (requireZeroBalance && balance != 0.0) {
      return Fail(
        ValidationFailure(
          'يجب أن يكون رصيد الحساب صفرًا لحذفه',
          code: 'account_balance_not_zero',
          info: {'balance': balance},
        ),
      );
    }

    return const Success(null);
  }

  /// Validates account name is not empty
  ///
  /// This is a common validation that can be reused across different operations.
  ///
  /// Example:
  /// ```dart
  /// final result = Validators.validateAccountName('');
  /// // Returns: Fail (empty name)
  /// ```
  static ValidationResult validateAccountName(String name) {
    if (name.trim().isEmpty) {
      return const Fail(
        ValidationFailure('اسم الحساب مطلوب', code: 'empty_account_name'),
      );
    }
    return const Success(null);
  }

  /// Validates category name is not empty
  ///
  /// Example:
  /// ```dart
  /// final result = Validators.validateCategoryName('  ');
  /// // Returns: Fail (empty name)
  /// ```
  static ValidationResult validateCategoryName(String name) {
    if (name.trim().isEmpty) {
      return const Fail(
        ValidationFailure('اسم الفئة مطلوب', code: 'empty_category_name'),
      );
    }
    return const Success(null);
  }

  /// Validates that balance is not negative
  ///
  /// Example:
  /// ```dart
  /// final result = Validators.validateNonNegativeBalance(-100);
  /// // Returns: Fail (negative balance)
  /// ```
  static ValidationResult validateNonNegativeBalance(double balance) {
    if (balance < 0) {
      return const Fail(
        ValidationFailure(
          'الرصيد لا يمكن أن يكون سالباً',
          code: 'negative_balance',
        ),
      );
    }
    return const Success(null);
  }
}
