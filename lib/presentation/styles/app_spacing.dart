/// نظام المسافات والأبعاد للتطبيق
/// مبني على المواصفات من SCREENS_DOCUMENTATION.md
class AppSpacing {
  AppSpacing._();

  // ============================================================================
  // المسافات الأساسية (Base Spacing)
  // ============================================================================

  static const double xs = 4.0; // 0.25rem
  static const double sm = 8.0; // 0.5rem
  static const double md = 16.0; // 1rem
  static const double lg = 24.0; // 1.5rem
  static const double xl = 32.0; // 2rem
  static const double xxl = 48.0; // 3rem

  // ============================================================================
  // Padding (الحواف الداخلية)
  // ============================================================================

  /// Padding صغير جداً (4px)
  static const double paddingXs = xs;

  /// Padding صغير (8px / gap-2)
  static const double paddingSm = sm;

  /// Padding متوسط (16px / p-4 / gap-4)
  static const double paddingMd = md;

  /// Padding كبير (24px / p-6)
  static const double paddingLg = lg;

  /// Padding كبير جداً (32px / p-8)
  static const double paddingXl = xl;

  /// Padding للبطاقات (20px / p-5)
  static const double paddingCard = 20.0;

  /// Padding للحاوية الرئيسية (24px / px-6)
  static const double paddingContainer = lg;

  // ============================================================================
  // Margin (الحواف الخارجية)
  // ============================================================================

  /// Margin صغير (8px / mb-2)
  static const double marginSm = sm;

  /// Margin متوسط (16px / mb-4)
  static const double marginMd = md;

  /// Margin كبير (24px / mb-6)
  static const double marginLg = lg;

  /// Margin كبير جداً (48px / mb-12)
  static const double marginXl = xxl;

  // ============================================================================
  // Gap (المسافات بين العناصر)
  // ============================================================================

  /// Gap صغير جداً (4px)
  static const double gapXs = xs;

  /// Gap صغير (8px / gap-2)
  static const double gapSm = sm;

  /// Gap متوسط (16px / gap-4)
  static const double gapMd = md;

  /// Gap كبير (24px / gap-6)
  static const double gapLg = lg;

  // ============================================================================
  // Border Radius (الزوايا الدائرية)
  // ============================================================================

  /// زوايا صغيرة (8px)
  static const double radiusSm = 8.0;

  /// زوايا متوسطة (12px)
  static const double radiusMd = 12.0;

  /// زوايا كبيرة (16px)
  static const double radiusLg = 16.0;

  /// زوايا كبيرة جداً (20px)
  static const double radiusXl = 20.0;

  /// زوايا البطاقات (24px)
  static const double radiusCard = 24.0;

  /// زوايا بطاقة الرصيد (28px)
  static const double radiusBalance = 28.0;

  /// زوايا الهيدر (32px)
  static const double radiusHeader = 32.0;

  /// دائري كامل (9999px)
  static const double radiusFull = 9999.0;

  // ============================================================================
  // أحجام محددة (Specific Sizes)
  // ============================================================================

  /// عرض الأيقونة الصغيرة
  static const double iconSm = 20.0;

  /// عرض الأيقونة المتوسطة
  static const double iconMd = 24.0;

  /// عرض الأيقونة الكبيرة
  static const double iconLg = 32.0;

  /// عرض أيقونة الفئة في قائمة المعاملات
  static const double iconCategory = 24.0;

  /// حجم دائرة الأيقونة الخارجية في قائمة المعاملات
  static const double categoryIconOuter = 48.0;

  /// حجم دائرة الأيقونة الداخلية في قائمة المعاملات
  static const double categoryIconInner = 24.0;

  /// عرض زر العمل السريع (Quick Action)
  static const double quickActionSize = 70.0;

  /// عرض أيقونة المستخدم في الهيدر
  static const double userAvatarSize = 56.0;

  /// عرض FAB
  static const double fabSize = 64.0;

  /// عرض مؤشر الصفحة النشط
  static const double activeIndicatorWidth = 32.0;

  /// عرض مؤشر الصفحة غير النشط
  static const double inactiveIndicatorSize = 8.0;

  /// ارتفاع مؤشر الصفحة
  static const double indicatorHeight = 8.0;

  /// عرض بطاقة Carousel (Insight Card)
  static const double carouselCardWidth = 280.0;

  /// عرض النقطة الملونة في قائمة الفئات
  static const double categoryDotSize = 12.0;

  // ============================================================================
  // ارتفاعات محددة (Specific Heights)
  // ============================================================================

  /// ارتفاع الصورة التوضيحية في Onboarding
  static const double onboardingImageHeight = 256.0;

  /// عرض الصورة التوضيحية في Onboarding
  static const double onboardingImageWidth = 320.0;

  /// ارتفاع الرسم البياني
  static const double chartHeight = 200.0;

  /// ارتفاع شريط التنقل السفلي (تقريبي)
  static const double bottomNavHeight = 80.0;

  /// المسافة السفلية لتفادي تغطية المحتوى بشريط التنقل
  static const double bottomPadding = 96.0; // 6rem

  /// موضع FAB من الأسفل (فوق شريط التنقل)
  static const double fabBottomPosition = 112.0; // 7rem

  // ============================================================================
  // أقصى عروض (Max Widths)
  // ============================================================================

  /// أقصى عرض للمحتوى في Onboarding
  static const double maxWidthOnboarding = 448.0; // max-w-md / 28rem

  /// أقصى عرض للزر في Onboarding
  static const double maxWidthButton = 192.0; // max-w-xs

  /// أقصى عرض لشريط التنقل على الشاشات الكبيرة
  static const double maxWidthBottomNav = 672.0; // max-w-2xl

  // ============================================================================
  // Blur Radius (قوة الضبابية)
  // ============================================================================

  /// ضبابية خفيفة
  static const double blurLight = 16.0;

  /// ضبابية متوسطة
  static const double blurMedium = 24.0;

  /// ضبابية قوية للدوائر في الخلفية
  static const double blurHeavy = 60.0;

  // ============================================================================
  // أحجام الظلال (Shadow Sizes)
  // ============================================================================

  /// ظل صغير
  static const double shadowSm = 8.0;

  /// ظل متوسط
  static const double shadowMd = 16.0;

  /// ظل كبير
  static const double shadowLg = 24.0;

  /// ظل كبير جداً
  static const double shadowXl = 32.0;

  /// ظل للتوهج
  static const double shadowGlow = 40.0;
}
