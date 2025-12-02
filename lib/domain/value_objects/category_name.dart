import 'package:meta/meta.dart';
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';

/// Value Object representing a category name
///
/// Immutable and self-validating. Automatically trims whitespace
/// and enforces length constraints.
///
/// Example:
/// ```dart
/// final nameResult = CategoryName.create('  Food & Dining  ');
/// if (nameResult is Success<CategoryName>) {
///   print(nameResult.value.value); // 'Food & Dining'
/// }
/// ```
@immutable
class CategoryName {
  final String value;

  static const int minLen = 1;
  static const int maxLen = 50;

  const CategoryName._(this.value);

  /// Factory that performs validation and returns Result<CategoryName>
  ///
  /// [name] - The category name to validate
  ///
  /// Returns [ValidationFailure] if:
  /// - Name is empty after trimming
  /// - Name is too short (< 1 character)
  /// - Name is too long (> 50 characters)
  static Result<CategoryName> create(String name) {
    final trimmed = name.trim();

    if (trimmed.length < minLen) {
      return const Fail(
        ValidationFailure(
          'Category name is too short',
          code: 'category_name_short',
        ),
      );
    }

    if (trimmed.length > maxLen) {
      return const Fail(
        ValidationFailure(
          'Category name is too long (max $maxLen characters)',
          code: 'category_name_long',
        ),
      );
    }

    return Success(CategoryName._(trimmed));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is CategoryName && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
