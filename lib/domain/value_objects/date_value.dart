import 'package:meta/meta.dart';
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';

/// Value Object representing a transaction date
///
/// Immutable and self-validating. Prevents dates too far in the future
/// but allows a small time skew to account for clock differences.
///
/// Example:
/// ```dart
/// final dateResult = DateValue.create(DateTime.now());
/// if (dateResult is Success<DateValue>) {
///   print(dateResult.value.value);
/// }
///
/// // With custom skew allowance
/// final futureDate = DateValue.create(
///   DateTime.now().add(Duration(minutes: 3)),
///   allowedSkew: Duration(minutes: 5),
/// ); // Valid
/// ```
@immutable
class DateValue {
  final DateTime value;

  const DateValue._(this.value);

  /// Factory that performs validation and returns Result<DateValue>
  ///
  /// [date] - The date to validate
  /// [allowedSkew] - Time allowance for future dates (default: 5 minutes)
  ///
  /// Returns [ValidationFailure] if date is too far in the future
  /// beyond the allowed skew.
  static Result<DateValue> create(
    DateTime date, {
    Duration allowedSkew = const Duration(minutes: 5),
  }) {
    final now = DateTime.now();

    if (date.isAfter(now.add(allowedSkew))) {
      return const Fail(
        ValidationFailure('Date cannot be in the future', code: 'date_future'),
      );
    }

    return Success(DateValue._(date));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is DateValue && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toIso8601String();
}
