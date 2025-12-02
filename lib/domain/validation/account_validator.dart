// lib/domain/validation/account_validator.dart
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';

/// Account validation logic
/// All validators return Result<void> for consistency
class AccountValidator {
  AccountValidator._();

  /// Validates that account is active
  static Result<void> validateAccountActive(
    bool isActive, {
    String? accountId,
  }) {
    if (!isActive) {
      return Fail(
        ValidationFailure(
          'الحساب غير مفعل',
          code: 'account_inactive',
          info: {'accountId': accountId},
        ),
      );
    }
    return const Success(null);
  }

  /// Validates account name is not empty
  static Result<void> validateAccountName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return const Fail(
        ValidationFailure('اسم الحساب مطلوب', code: 'empty_account_name'),
      );
    }
    if (trimmed.length < 2) {
      return const Fail(
        ValidationFailure(
          'اسم الحساب قصير جداً (الحد الأدنى حرفان)',
          code: 'account_name_too_short',
        ),
      );
    }
    if (trimmed.length > 50) {
      return const Fail(
        ValidationFailure(
          'اسم الحساب طويل جداً (الحد الأقصى 50 حرف)',
          code: 'account_name_too_long',
        ),
      );
    }
    return const Success(null);
  }

  /// Validates balance is not negative
  static Result<void> validateBalance(int balanceMinor) {
    if (balanceMinor < 0) {
      return Fail(
        ValidationFailure(
          'الرصيد لا يمكن أن يكون سالباً',
          code: 'negative_balance',
          info: {'balance': balanceMinor},
        ),
      );
    }
    return const Success(null);
  }

  /// Validates if account can be deleted
  ///
  /// Account cannot be deleted if:
  /// - It has transactions
  /// - It has non-zero balance (optional check)
  static Result<void> canDeleteAccount({
    required int transactionsCount,
    required int balanceMinor,
    bool requireZeroBalance = false,
  }) {
    if (transactionsCount > 0) {
      return Fail(
        ValidationFailure(
          'لا يمكن حذف الحساب لأنه يحتوي معاملات',
          code: 'account_has_transactions',
          info: {'count': transactionsCount},
        ),
      );
    }
    if (requireZeroBalance && balanceMinor != 0) {
      return Fail(
        ValidationFailure(
          'يجب أن يكون رصيد الحساب صفراً لحذفه',
          code: 'account_balance_not_zero',
          info: {'balance': balanceMinor},
        ),
      );
    }
    return const Success(null);
  }

  /// Validates color format (hex color)
  static Result<void> validateColor(String color) {
    // Simple hex color validation (supports #RGB, #RRGGBB, #AARRGGBB)
    final hexPattern = RegExp(r'^#?([A-Fa-f0-9]{6}|[A-Fa-f0-9]{8})$');
    if (!hexPattern.hasMatch(color)) {
      return Fail(
        ValidationFailure(
          'صيغة اللون غير صحيحة',
          code: 'invalid_color_format',
          info: {'color': color},
        ),
      );
    }
    return const Success(null);
  }

  /// Validates sufficient balance for a transaction
  static Result<void> validateSufficientBalance({
    required int currentBalanceMinor,
    required int requiredAmountMinor,
    String? accountId,
  }) {
    if (currentBalanceMinor < requiredAmountMinor) {
      return Fail(
        ValidationFailure(
          'الرصيد غير كافٍ لإتمام العملية',
          code: 'insufficient_balance',
          info: {
            'currentBalance': currentBalanceMinor,
            'requiredAmount': requiredAmountMinor,
            'accountId': accountId,
          },
        ),
      );
    }
    return const Success(null);
  }
}
