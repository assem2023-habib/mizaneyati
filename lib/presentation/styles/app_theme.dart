import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// نظام الثيم الكامل للتطبيق
/// يجمع كل الألوان والخطوط والتنسيقات
class AppTheme {
  AppTheme._();

  /// الثيم الرئيسي للتطبيق (Light Theme)
  static ThemeData get lightTheme {
    return ThemeData(
      // ========================================
      // الألوان الأساسية
      // ========================================
      primaryColor: AppColors.primaryDark,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryDark,
        secondary: AppColors.primaryMain,
        surface: AppColors.white,
        error: AppColors.expense,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.gray800,
        onError: AppColors.white,
      ),

      // ========================================
      // نظام الخطوط
      // ========================================
      textTheme: TextTheme(
        displayLarge: AppTextStyles.h1,
        displayMedium: AppTextStyles.h2,
        displaySmall: AppTextStyles.h3,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.bodySmall,
        bodySmall: AppTextStyles.caption,
        labelLarge: AppTextStyles.button,
      ),

      // ========================================
      // الأزرار
      // ========================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.white,
          textStyle: AppTextStyles.button,
          elevation: 4,
          shadowColor: AppColors.primaryDark.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),

      // ========================================
      // البطاقات
      // ========================================
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),

      // ========================================
      // AppBar
      // ========================================
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.h2,
        iconTheme: const IconThemeData(color: AppColors.primaryDark),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

      // ========================================
      // Bottom Navigation Bar
      // ========================================
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.glassBg50,
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: AppColors.categoryOther,
        selectedLabelStyle: AppTextStyles.tiny,
        unselectedLabelStyle: AppTextStyles.tiny,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // ========================================
      // FloatingActionButton
      // ========================================
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        elevation: 8,
        shape: const CircleBorder(),
      ),

      // ========================================
      // Icons
      // ========================================
      iconTheme: const IconThemeData(color: AppColors.primaryDark, size: 24),

      // ========================================
      // Divider
      // ========================================
      dividerTheme: DividerThemeData(
        color: AppColors.gray300,
        thickness: 1,
        space: 16,
      ),

      // ========================================
      // Input Decoration
      // ========================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.gray300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.gray300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.expense),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: AppTextStyles.bodySecondary,
        labelStyle: AppTextStyles.body,
      ),

      // ========================================
      // General
      // ========================================
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  /// تطبيق نظام RTL (من اليمين لليسار) للعربية
  static Locale get arabicLocale => const Locale('ar', 'SY');

  /// اتجاه النص (RTL للعربية)
  static TextDirection get textDirection => TextDirection.rtl;
}
