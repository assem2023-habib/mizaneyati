import 'package:meta/meta.dart';
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';

/// Value Object representing monetary amounts in minor units (e.g., qruush for SYP)
///
/// Immutable and self-validating. All amounts are stored in minor units
/// to avoid floating-point precision issues.
///
/// Example:
/// ```dart
/// final moneyResult = Money.create(15000); // 150.00 SYP
/// if (moneyResult is Success<Money>) {
///   final money = moneyResult.value;
///   print(money.toMajor(100)); // 150.0
/// }
/// ```
@immutable
class Money {
  final int minorUnits;

  const Money._(this.minorUnits);

  /// Factory that performs validation and returns Result<Money>
  ///
  /// [minorUnits] - Amount in smallest currency unit (e.g., qruush)
  ///
  /// Returns [ValidationFailure] if amount is negative.
  static Result<Money> create(int minorUnits) {
    if (minorUnits < 0) {
      return const Fail(
        ValidationFailure(
          'Amount must be greater than or equal to zero',
          code: 'money_negative',
        ),
      );
    }
    return Success(Money._(minorUnits));
  }

  /// Convert to major units (e.g., SYP from qruush)
  ///
  /// [minorUnitDivider] - How many minor units make 1 major unit (default: 100)
  double toMajor([int minorUnitDivider = 100]) => minorUnits / minorUnitDivider;

  /// Get the value in minor units
  int toMinor() => minorUnits;

  /// Create a copy with optional new value
  Money copyWith({int? minorUnits}) => Money._(minorUnits ?? this.minorUnits);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Money && other.minorUnits == minorUnits);

  @override
  int get hashCode => minorUnits.hashCode;

  @override
  String toString() => 'Money(minorUnits: $minorUnits)';
}
