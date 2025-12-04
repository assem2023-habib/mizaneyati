import 'package:flutter/material.dart';

/// نظام الألوان الكامل للتطبيق
/// مبني على المواصفات من SCREENS_DOCUMENTATION.md
class AppColors {
  AppColors._();

  // ============================================================================
  // الألوان الأساسية (Primary Colors)
  // ============================================================================

  /// اللون الأساسي الداكن - أخضر داكن (Green 800)
  static const Color primaryDark = Color(0xFF2E7D32);

  /// اللون الأساسي الرئيسي - أخضر متوسط (Green 400)
  static const Color primaryMain = Color(0xFF60AD5E);

  /// اللون الأساسي الفاتح - نعناعي فاتح (Mint)
  static const Color primaryLight = Color(0xFFB0F2DE);

  // ============================================================================
  // ألوان المعاملات (Transaction Colors)
  // ============================================================================

  /// لون المصروفات - أحمر (Red 600)
  static const Color expense = Color(0xFFE53935);

  /// لون الدخل - أخضر (Green 500)
  static const Color income = Color(0xFF4CAF50);

  /// لون التحويل - أزرق (Blue 500)
  static const Color transfer = Color(0xFF2196F3);

  // ============================================================================
  // الألوان الخاصة (Special Colors)
  // ============================================================================

  /// لون رقم الرصيد - ذهبي (Amber 500)
  static const Color balance = Color(0xFFFFC107);

  // ============================================================================
  // ألوان الفئات (Category Colors)
  // ============================================================================

  static const Color categoryFood = Color(0xFFFF6B6B);
  static const Color categoryTransport = Color(0xFF4ECDC4);
  static const Color categoryShopping = Color(0xFF95E1D3);
  static const Color categoryEntertainment = Color(0xFFF38181);
  static const Color categoryHealth = Color(0xFFAA96DA);
  static const Color categorySalary = Color(0xFF4CAF50);
  static const Color categoryBills = Color(0xFFFF8E53);
  static const Color categoryEducation = Color(0xFF3D5A80);
  static const Color categoryOther = Color(0xFF999999);

  /// خريطة ألوان الفئات للوصول الديناميكي
  static const Map<String, Color> categoryColors = {
    'طعام': categoryFood,
    'مواصلات': categoryTransport,
    'تسوق': categoryShopping,
    'ترفيه': categoryEntertainment,
    'صحة': categoryHealth,
    'راتب': categorySalary,
    'فواتير': categoryBills,
    'تعليم': categoryEducation,
    'أخرى': categoryOther,
  };

  // ============================================================================
  // الألوان الحيادية (Neutral Colors)
  // ============================================================================

  /// أبيض نقي
  static const Color white = Color(0xFFFFFFFF);

  /// خلفية فاتحة
  static const Color backgroundLight = Color(0xFFF9FBFD);

  /// خلفية فاتحة جداً - أزرق سماوي
  static const Color backgroundLighter = Color(0xFFDFF1FF);

  // درجات الرمادي (Gray Scale)
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF6B7280);
  static const Color gray800 = Color(0xFF1F2937);

  // ============================================================================
  // التدرجات (Gradients)
  // ============================================================================

  /// تدرج الخلفية الرئيسية (vertical من أعلى لأسفل)
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      backgroundLighter, // #DFF1FF
      backgroundLight, // #F9FBFD
    ],
  );

  /// تدرج الخلفية البديل (لشاشة Onboarding)
  static const LinearGradient onboardingGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE3F2FD), // أزرق فاتح جداً
      Color(0xFFF4F7F9), // رمادي-أزرق فاتح
    ],
  );

  /// تدرج أخضر أساسي (135 درجة)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryDark, // #2E7D32
      primaryMain, // #60AD5E
    ],
  );

  /// تدرج البطاقات البيضاء
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      white, // #FFFFFF
      Color(0xFFF0F0F0), // رمادي فاتح جداً
    ],
  );

  // ============================================================================
  // الدوائر الضبابية في الخلفية (Blurry Circles)
  // ============================================================================

  /// دائرة بيضاء شفافة
  static const Color blurryCircleWhite = Color(0x4DFFFFFF); // 30% opacity

  /// دائرة خضراء نعناعية شفافة
  static const Color blurryCircleMint = Color(0x99B0F2DE); // 60% opacity

  /// دائرة زرقاء سماوية شفافة
  static const Color blurryCircleBlue = Color(0x99B3E5FC); // 60% opacity

  // ============================================================================
  // ألوان Glassmorphism
  // ============================================================================

  /// خلفية زجاجية - أبيض شفاف 40%
  static const Color glassBg40 = Color(0x66FFFFFF);

  /// خلفية زجاجية - أبيض شفاف 50%
  static const Color glassBg50 = Color(0x80FFFFFF);

  /// حدود زجاجية - أبيض شفاف 60%
  static const Color glassBorder60 = Color(0x99FFFFFF);

  /// حدود زجاجية - أبيض شفاف 70%
  static const Color glassBorder70 = Color(0xB3FFFFFF);

  // ============================================================================
  // دوال مساعدة (Helper Functions)
  // ============================================================================

  /// الحصول على لون فئة حسب الاسم
  static Color getCategoryColor(String categoryName) {
    return categoryColors[categoryName] ?? categoryOther;
  }

  /// إنشاء لون مع شفافية محددة
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// إنشاء shadow color من لون محدد
  static Color getShadowColor(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}
