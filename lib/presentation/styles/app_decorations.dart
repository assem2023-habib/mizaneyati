import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

/// نظام الديكورات والتأثيرات البصرية
/// مبني على المواصفات من SCREENS_DOCUMENTATION.md
class AppDecorations {
  AppDecorations._();

  // ============================================================================
  // Glassmorphism Decorations
  // ============================================================================

  /// ديكور زجاجي للهيدر (40% opacity, 24px blur)
  static BoxDecoration glassmorphicHeader = BoxDecoration(
    color: AppColors.glassBg40,
    borderRadius: BorderRadius.circular(AppSpacing.radiusHeader),
    border: Border.all(color: AppColors.glassBorder60, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: AppSpacing.shadowSm,
        offset: const Offset(0, 8),
      ),
    ],
  );

  /// ديكور زجاجي للأزرار والبطاقات (50% opacity, 16px blur)
  static BoxDecoration glassmorphicButton = BoxDecoration(
    color: AppColors.glassBg50,
    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
    border: Border.all(color: AppColors.glassBorder70, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: AppSpacing.shadowSm,
        offset: const Offset(0, 8),
      ),
    ],
  );

  /// ديكور زجاجي لقائمة المعاملات وشريط التنقل
  static BoxDecoration glassmorphicContainer = BoxDecoration(
    color: AppColors.glassBg50,
    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
    border: Border.all(color: AppColors.glassBorder70, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: AppSpacing.shadowLg,
        offset: const Offset(0, 8),
      ),
    ],
  );

  /// ديكور زجاجي لشريط التنقل السفلي (ظل للأعلى)
  static BoxDecoration glassmorphicBottomNav = BoxDecoration(
    color: AppColors.glassBg50,
    border: Border(top: BorderSide(color: AppColors.glassBorder70, width: 1)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: AppSpacing.shadowLg,
        offset: const Offset(0, -4),
      ),
    ],
  );

  // ============================================================================
  // Card Decorations
  // ============================================================================

  /// ديكور بطاقة الرصيد الرئيسية (مع تدرج أخضر)
  static BoxDecoration balanceCard = BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: BorderRadius.circular(AppSpacing.radiusBalance),
    boxShadow: [
      BoxShadow(
        color: AppColors.primaryDark.withOpacity(0.35),
        blurRadius: AppSpacing.shadowMd,
        offset: const Offset(0, 16),
      ),
      // ظل داخلي (إضاءة)
      BoxShadow(
        color: Colors.white.withOpacity(0.2),
        blurRadius: 4,
        offset: const Offset(0, 2),
        spreadRadius: -1,
        blurStyle: BlurStyle.inner,
      ),
    ],
  );

  /// ديكور البطاقات البيضاء (Insight Cards, Category Card)
  static BoxDecoration whiteCard = BoxDecoration(
    gradient: AppColors.cardGradient,
    borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: AppSpacing.shadowLg,
        offset: const Offset(0, 8),
      ),
    ],
  );

  /// ديكور عنصر معاملة واحدة
  static BoxDecoration transactionItem = BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
  );

  // ============================================================================
  // Button Decorations
  // ============================================================================

  /// ديكور الزر الأساسي (من متدرج أخضر)
  static BoxDecoration primaryButton = BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: AppColors.primaryDark.withOpacity(0.3),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  /// ديكور زر العمل السريع (مع توهج ملون)
  static BoxDecoration quickActionButton(Color glowColor) {
    return BoxDecoration(
      color: AppColors.glassBg50,
      shape: BoxShape.circle,
      border: Border.all(color: AppColors.glassBorder70, width: 1),
      boxShadow: [
        BoxShadow(
          color: glowColor.withOpacity(0.25),
          blurRadius: AppSpacing.shadowLg,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: glowColor.withOpacity(0.15),
          blurRadius: 20,
          offset: Offset.zero,
        ),
      ],
    );
  }

  /// ديكور FAB (Floating Action Button)
  static BoxDecoration floatingActionButton = BoxDecoration(
    gradient: AppColors.primaryGradient,
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(
        color: AppColors.primaryDark.withOpacity(0.4),
        blurRadius: AppSpacing.shadowXl,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: AppColors.primaryDark.withOpacity(0.3),
        blurRadius: AppSpacing.shadowGlow,
        offset: Offset.zero,
      ),
    ],
  );

  // ============================================================================
  // Icon Container Decorations
  // ============================================================================

  /// ديكور دائرة الأيقونة الخارجية (مع خلفية شفافة)
  static BoxDecoration categoryIconOuter(Color categoryColor) {
    return BoxDecoration(
      color: categoryColor.withOpacity(0.3),
      shape: BoxShape.circle,
    );
  }

  /// ديكور دائرة الأيقونة الداخلية (مع لون كامل)
  static BoxDecoration categoryIconInner(Color categoryColor) {
    return BoxDecoration(color: categoryColor, shape: BoxShape.circle);
  }

  /// ديكور أيقونة المستخدم (مع تدرج وظل)
  static BoxDecoration userAvatar = BoxDecoration(
    gradient: AppColors.primaryGradient,
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(
        color: AppColors.primaryDark.withOpacity(0.3),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  /// ديكور النقطة الملونة في قائمة الفئات (مع توهج)
  static BoxDecoration categoryDot(Color categoryColor) {
    return BoxDecoration(
      color: categoryColor,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: categoryColor.withOpacity(0.8),
          blurRadius: 8,
          offset: Offset.zero,
        ),
      ],
    );
  }

  // ============================================================================
  // Page Indicator Decorations
  // ============================================================================

  /// ديكور مؤشر الصفحة النشط (pill shape أخضر)
  static BoxDecoration activePageIndicator = BoxDecoration(
    color: AppColors.primaryDark,
    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
  );

  /// ديكور مؤشر الصفحة غير النشط (دائرة رمادية)
  static BoxDecoration inactivePageIndicator = BoxDecoration(
    color: AppColors.gray300,
    shape: BoxShape.circle,
  );

  // ============================================================================
  // Special Effects
  // ============================================================================

  /// ديكور دائرة ضبابية في الخلفية
  static BoxDecoration blurryCircle(Color color, double opacity) {
    return BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [color.withOpacity(opacity), Colors.transparent],
        stops: const [0.0, 0.7],
      ),
    );
  }

  /// ديكور انعكاس الضوء القطري (للاستخدام كطبقة فوق بطاقة الرصيد)
  static BoxDecoration diagonalLightReflection = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.transparent,
        Colors.white.withOpacity(0.4),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    ),
  );

  // ============================================================================
  // Helper Functions
  // ============================================================================

  /// إنشاء shadow مخصص
  static BoxShadow customShadow({
    required Color color,
    double opacity = 0.1,
    double blurRadius = 10,
    Offset offset = const Offset(0, 4),
    double spreadRadius = 0,
  }) {
    return BoxShadow(
      color: color.withOpacity(opacity),
      blurRadius: blurRadius,
      offset: offset,
      spreadRadius: spreadRadius,
    );
  }

  /// إنشاء glow effect (توهج)
  static List<BoxShadow> glowEffect(Color color, {double opacity = 0.3}) {
    return [
      BoxShadow(
        color: color.withOpacity(opacity),
        blurRadius: 20,
        offset: Offset.zero,
      ),
      BoxShadow(
        color: color.withOpacity(opacity * 0.5),
        blurRadius: 40,
        offset: Offset.zero,
      ),
    ];
  }
}
