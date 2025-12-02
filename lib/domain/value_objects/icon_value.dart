import 'package:meta/meta.dart';
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';

/// Value Object representing an icon identifier
///
/// Immutable and self-validating. Ensures icon name is not empty
/// and automatically trims whitespace.
///
/// Example:
/// ```dart
/// final iconResult = IconValue.create('wallet');
/// if (iconResult is Success<IconValue>) {
///   print(iconResult.value.name); // 'wallet'
/// }
///
/// final emptyIcon = IconValue.create('   ');
/// // Returns Fail with ValidationFailure
/// ```
@immutable
class IconValue {
  final String name;

  const IconValue._(this.name);

  /// Factory that performs validation and returns Result<IconValue>
  ///
  /// [name] - Icon identifier/name
  ///
  /// Returns [ValidationFailure] if icon name is empty after trimming.
  static Result<IconValue> create(String name) {
    final trimmed = name.trim();

    if (trimmed.isEmpty) {
      return const Fail(
        ValidationFailure('Icon name cannot be empty', code: 'icon_empty'),
      );
    }

    return Success(IconValue._(trimmed));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is IconValue && other.name == name);

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => name;
}
