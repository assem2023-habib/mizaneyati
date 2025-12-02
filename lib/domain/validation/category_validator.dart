// lib/domain/validation/category_validator.dart
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';

/// Category validation logic
/// All validators return Result<void> for consistency
class CategoryValidator {
  CategoryValidator._();

  /// Validates category name is not empty
  static Result<void> validateCategoryName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return const Fail(
        ValidationFailure('اسم الفئة مطلوب', code: 'empty_category_name'),
      );
    }
    if (trimmed.length < 2) {
      return const Fail(
        ValidationFailure(
          'اسم الفئة قصير جداً (الحد الأدنى حرفان)',
          code: 'category_name_too_short',
        ),
      );
    }
    if (trimmed.length > 30) {
      return const Fail(
        ValidationFailure(
          'اسم الفئة طويل جداً (الحد الأقصى 30 حرف)',
          code: 'category_name_too_long',
        ),
      );
    }
    return const Success(null);
  }

  /// Validates if category can be deleted
  ///
  /// Category cannot be deleted if it has transactions
  static Result<void> canDeleteCategory({required int transactionsCount}) {
    if (transactionsCount > 0) {
      return Fail(
        ValidationFailure(
          'لا يمكن حذف الفئة لأنها مستخدمة في معاملات',
          code: 'category_has_transactions',
          info: {'count': transactionsCount},
        ),
      );
    }
    return const Success(null);
  }

  /// Validates color format (hex color)
  static Result<void> validateColor(String color) {
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

  /// Validates icon name is not empty
  static Result<void> validateIcon(String icon) {
    final trimmed = icon.trim();
    if (trimmed.isEmpty) {
      return const Fail(
        ValidationFailure(
          'يجب اختيار أيقونة للفئة',
          code: 'empty_category_icon',
        ),
      );
    }
    return const Success(null);
  }
}
