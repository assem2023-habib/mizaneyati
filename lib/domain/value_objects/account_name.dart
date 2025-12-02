import 'package:meta/meta.dart';
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';

/// Value Object representing an account name
///
/// Immutable and self-validating. Automatically trims whitespace
/// and enforces length constraints.
///
/// Example:
/// ```dart
/// final nameResult = AccountName.create('  My Wallet  ');
/// if (nameResult is Success<AccountName>) {
///   print(nameResult.value.value); // 'My Wallet'
/// }
/// ```
@immutable
class AccountName {
  final String value;

  static const int minLen = 1;
  static const int maxLen = 50;

  const AccountName._(this.value);

  /// Factory that performs validation and returns Result<AccountName>
  ///
  /// [name] - The account name to validate
  ///
  /// Returns [ValidationFailure] if:
  /// - Name is empty after trimming
  /// - Name is too short (< 1 character)
  /// - Name is too long (> 50 characters)
  static Result<AccountName> create(String name) {
    final trimmed = name.trim();

    if (trimmed.length < minLen) {
      return const Fail(
        ValidationFailure(
          'Account name is too short',
          code: 'account_name_short',
        ),
      );
    }

    if (trimmed.length > maxLen) {
      return const Fail(
        ValidationFailure(
          'Account name is too long (max $maxLen characters)',
          code: 'account_name_long',
        ),
      );
    }

    return Success(AccountName._(trimmed));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is AccountName && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
