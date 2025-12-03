import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// نظام الخطوط الكامل للتطبيق
/// مبني على المواصفات من SCREENS_DOCUMENTATION.md
class AppTextStyles {
  AppTextStyles._();

  // ============================================================================
  // الخط الأساسي (Base Font Family)
  // ============================================================================

  /// استخدام Cairo font للعربية (من Google Fonts)
  static TextStyle get _baseTextStyle => GoogleFonts.cairo(
    textStyle: const TextStyle(decoration: TextDecoration.none),
  );

  // ============================================================================
  // العناوين (Headings)
  // ============================================================================

  /// h1 - العنوان الرئيسي الكبير (24px / 1.5rem)
  /// استخدام: العناوين الرئيسية في الشاشات
  static TextStyle get h1 => _baseTextStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w500, // Medium
    height: 1.5,
    color: AppColors.primaryDark,
  );

  /// h2 - العنوان الفرعي (20px / 1.25rem)
  /// استخدام: عناوين الأقسام
  static TextStyle get h2 => _baseTextStyle.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w500, // Medium
    height: 1.5,
    color: AppColors.primaryDark,
  );

  /// h3 - العنوان الصغير (18px / 1.125rem)
  /// استخدام: عناوين البطاقات
  static TextStyle get h3 => _baseTextStyle.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w500, // Medium
    height: 1.5,
    color: AppColors.primaryDark,
  );

  // ============================================================================
  // النصوص العادية (Body Text)
  // ============================================================================

  /// النص الأساسي (16px / 1rem)
  static TextStyle get body => _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
    height: 1.5,
    color: AppColors.gray800,
  );

  /// النص الصغير (14px / 0.875rem)
  static TextStyle get bodySmall => _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400, // Regular
    height: 1.5,
    color: AppColors.gray600,
  );

  /// النص الثانوي (مع لون رمادي)
  static TextStyle get bodySecondary => _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
    height: 1.5,
    color: AppColors.gray500,
  );

  // ============================================================================
  // النصوص المخصصة للداشبورد (Dashboard Specific)
  // ============================================================================

  /// رقم الرصيد الكبير (48px / 3rem) - ذهبي مع ظل
  static TextStyle get balanceAmount => _baseTextStyle.copyWith(
    fontSize: 48,
    fontWeight: FontWeight.w700, // Bold
    height: 1.2,
    color: AppColors.balance,
    shadows: [
      Shadow(
        color: AppColors.balance.withOpacity(0.4),
        blurRadius: 24,
        offset: const Offset(0, 4),
      ),
    ],
  );

  /// أرقام المصاريف في البطاقات (28px / 1.75rem)
  static TextStyle get cardAmount => _baseTextStyle.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w600, // Semi-bold
    height: 1.3,
  );

  /// أرقام الاتجاه (24px / 1.5rem)
  static TextStyle get trendAmount => _baseTextStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600, // Semi-bold
    height: 1.3,
  );

  /// النص الصغير جداً (13.6px / 0.85rem)
  /// استخدام: "مرحباً" في الهيدر
  static TextStyle get caption => _baseTextStyle.copyWith(
    fontSize: 13.6,
    fontWeight: FontWeight.w400, // Regular
    height: 1.4,
    color: AppColors.gray600,
  );

  /// النص الصغير جداً جداً (10.4px / 0.65rem)
  /// استخدام: نصوص شريط التنقل السفلي
  static TextStyle get tiny => _baseTextStyle.copyWith(
    fontSize: 10.4,
    fontWeight: FontWeight.w400, // Regular
    height: 1.3,
  );

  // ============================================================================
  // نصوص الأزرار (Button Text)
  // ============================================================================

  /// نص الزر الأساسي
  static TextStyle get button => _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500, // Medium
    height: 1.5,
    color: AppColors.white,
  );

  /// نص الزر الصغير
  static TextStyle get buttonSmall => _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500, // Medium
    height: 1.4,
    color: AppColors.white,
  );

  // ============================================================================
  // نصوص المعاملات (Transaction Text)
  // ============================================================================

  /// مبلغ المصروف (أحمر)
  static TextStyle get expenseAmount => _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600, // Semi-bold
    height: 1.4,
    color: AppColors.expense,
  );

  /// مبلغ الدخل (أخضر)
  static TextStyle get incomeAmount => _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600, // Semi-bold
    height: 1.4,
    color: AppColors.income,
  );

  /// اسم الفئة في قائمة المعاملات
  static TextStyle get transactionCategory => _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
    height: 1.4,
    color: AppColors.gray800,
  );

  /// التاريخ والملاحظات في المعاملات
  static TextStyle get transactionMeta => _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400, // Regular
    height: 1.4,
    color: AppColors.gray400,
  );

  // ============================================================================
  // نصوص خاصة (Special Text)
  // ============================================================================

  /// النص الأبيض (للاستخدام على الخلفيات الداكنة)
  static TextStyle get whiteText => _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
    height: 1.5,
    color: AppColors.white,
  );

  /// النص الأبيض الشفاف 90%
  static TextStyle get whiteText90 => _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
    height: 1.5,
    color: AppColors.white.withOpacity(0.9),
  );

  /// النص الأبيض الشفاف 80%
  static TextStyle get whiteText80 => _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
    height: 1.5,
    color: AppColors.white.withOpacity(0.8),
  );

  // ============================================================================
  // دوال مساعدة (Helper Functions)
  // ============================================================================

  /// إنشاء نص مع لون مخصص
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// إنشاء نص مع حجم مخصص
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  /// إنشاء نص مع وزن مخصص
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// إنشاء نص مع ظل
  static TextStyle withShadow(
    TextStyle style, {
    required Color shadowColor,
    double blurRadius = 10,
    Offset offset = const Offset(0, 2),
  }) {
    return style.copyWith(
      shadows: [
        Shadow(color: shadowColor, blurRadius: blurRadius, offset: offset),
      ],
    );
  }
}
