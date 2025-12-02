import 'package:meta/meta.dart';
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';

/// Value Object representing a color in hexadecimal format
///
/// Immutable and self-validating. Validates hex format and
/// normalizes to uppercase.
///
/// Supports both 6-digit (#RRGGBB) and 8-digit (#RRGGBBAA) formats.
///
/// Example:
/// ```dart
/// final colorResult = ColorValue.create('#ff5722');
/// if (colorResult is Success<ColorValue>) {
///   print(colorResult.value.hex); // '#FF5722'
/// }
///
/// final invalidColor = ColorValue.create('red');
/// // Returns Fail with ValidationFailure
/// ```
@immutable
class ColorValue {
  final String hex;

  const ColorValue._(this.hex);

  /// Regex for validating hex color format
  /// Accepts #RRGGBB or #RRGGBBAA format
  static final _hexRegex = RegExp(r'^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{8})$');

  /// Factory that performs validation and returns Result<ColorValue>
  ///
  /// [hex] - Color in hexadecimal format (e.g., '#FF5722' or '#FF5722AA')
  ///
  /// Returns [ValidationFailure] if the hex format is invalid.
  static Result<ColorValue> create(String hex) {
    if (!_hexRegex.hasMatch(hex)) {
      return const Fail(
        ValidationFailure(
          'Invalid color hex format. Use #RRGGBB or #RRGGBBAA',
          code: 'invalid_color',
        ),
      );
    }

    return Success(ColorValue._(hex.toUpperCase()));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ColorValue && other.hex == hex);

  @override
  int get hashCode => hex.hashCode;

  @override
  String toString() => hex;
}
