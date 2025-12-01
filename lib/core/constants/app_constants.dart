// lib/core/constants/app_constants.dart

/// ثوابت التطبيق الأساسية
///
/// يحتوي على:
/// - العملات المدعومة
/// - تنسيقات التاريخ والوقت
/// - الإعدادات المالية الافتراضية
/// - الفئات والحسابات الافتراضية
/// - حدود ونطاقات البيانات

class AppConstants {
  // منع الإنشاء
  AppConstants._();

  // ============================================================================
  // معلومات التطبيق
  // ============================================================================

  static const String appName = 'ميزانيتي';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // ============================================================================
  // العملات
  // ============================================================================

  /// العملة الافتراضية
  static const String defaultCurrency = 'SYP';

  /// رمز العملة الافتراضية
  static const String defaultCurrencySymbol = 'ل.س';

  /// العملات المدعومة
  static const Map<String, CurrencyInfo> supportedCurrencies = {
    'SYP': CurrencyInfo(
      code: 'SYP',
      name: 'الليرة السورية',
      symbol: 'ل.س',
      decimalDigits: 0, // عادةً لا نستخدم كسور في الليرة
    ),
    'USD': CurrencyInfo(
      code: 'USD',
      name: 'الدولار الأمريكي',
      symbol: '\$',
      decimalDigits: 2,
    ),
    'EUR': CurrencyInfo(
      code: 'EUR',
      name: 'اليورو',
      symbol: '€',
      decimalDigits: 2,
    ),
    'TRY': CurrencyInfo(
      code: 'TRY',
      name: 'الليرة التركية',
      symbol: '₺',
      decimalDigits: 2,
    ),
  };

  // ============================================================================
  // تنسيقات التاريخ والوقت
  // ============================================================================

  /// تنسيق التاريخ الافتراضي (مثال: 2024-12-01)
  static const String defaultDateFormat = 'yyyy-MM-dd';

  /// تنسيق التاريخ للعرض (م ثال: 1 ديسمبر 2024)
  static const String displayDateFormat = 'd MMMM yyyy';

  /// تنسيق التاريخ المختصر (مثال: 01/12/2024)
  static const String shortDateFormat = 'dd/MM/yyyy';

  /// تنسيق الوقت (مثال: 14:30)
  static const String timeFormat = 'HH:mm';

  /// تنسيق التاريخ والوقت معاً
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';

  /// تنسيق التاريخ للعرض مع  الوقت
  static const String displayDateTimeFormat = 'd MMMM yyyy - HH:mm';

  // ============================================================================
  // الإعدادات المالية
  // ============================================================================

  /// الحد الأدنى للمبلغ
  static const double minAmount = 0.01;

  /// الحد الأقصى للمبلغ (100 مليار)
  static const double maxAmount = 100000000000.0;

  /// الحد الأدنى للرصيد المسموح (يمكن أن يكون سالباً لبعض الحسابات)
  static const double minBalance = -1000000000.0;

  /// الحد الأقصى للرصيد
  static const double maxBalance = 100000000000.0;

  /// عدد الأرقام العشرية في العرض
  static const int defaultDecimalPlaces = 0; // للسوري

  /// الرصيد الافتراضي للحساب الجديد
  static const double defaultAccountBalance = 0.0;

  // ============================================================================
  // إعدادات النسخ الاحتياطي
  // ============================================================================

  /// المجلد الافتراضي للنسخ الاحتياطي
  static const String backupFolderName = 'mizaneyati_backups';

  /// تنسيق اسم ملف النسخ الاحتياطي
  static const String backupFileNameFormat =
      'mizaneyati_backup_yyyyMMdd_HHmmss.db';

  /// الحد الأقصى لعدد النسخ الاحتياطية التلقائية
  static const int maxAutoBackups = 10;

  // ============================================================================
  // إعدادات التقارير والإحصائيات
  // ============================================================================

  /// عدد الأيام في نطاق التقرير الافتراضي
  static const int defaultReportDays = 30;

  /// عدد العناصر في الصفحة الواحدة (pagination)
  static const int itemsPerPage = 20;

  /// الحد الأقصى لعدد الفئات الأكثر استخداماً في الإحصائيات
  static const int maxTopCategories = 5;

  // ============================================================================
  // الألوان الافتراضية (HEX)
  // ============================================================================

  static const List<String> defaultColors = [
    '#FF5252', // أحمر
    '#FF6E40', // برتقالي محمر
    '#FFAB40', // برتقالي
    '#FFD740', // أصفر
    '#AEEA00', // أخضر ليموني
    '#69F0AE', // أخضر فاتح
    '#64FFDA', // أخضر  مزرق
    '#40C4FF', // أزرق سماوي
    '#448AFF', // أزرق
    '#536DFE', // نيلي
    '#7C4DFF', // بنفسجي
    '#E040FB', // أرجواني
    '#FF4081', // وردي
    '#FF5722', // برتقالي غامق
  ];

  // ============================================================================
  // الأيقونات الافتراضية (Material Icons)
  // ============================================================================

  static const List<String> defaultIcons = [
    'shopping_cart',
    'restaurant',
    'local_gas_station',
    'electric_bolt',
    'water_drop',
    'phone_android',
    'wifi',
    'home',
    'directions_car',
    'health_and_safety',
    'school',
    'sports_esports',
    'theaters',
    'card_giftcard',
    'payments',
    'account_balance',
    'savings',
    'attach_money',
    'trending_up',
    'business',
  ];

  // ============================================================================
  // الفئات الافتراضية (Default Categories)
  // ============================================================================

  /// فئات المصروفات الافتراضية
  static const List<DefaultCategory> defaultExpenseCategories = [
    DefaultCategory(
      name: 'طعام ومشروبات',
      icon: 'restaurant',
      color: '#FF5252',
    ),
    DefaultCategory(name: 'مواصلات', icon: 'directions_car', color: '#448AFF'),
    DefaultCategory(name: 'فواتير', icon: 'receipt', color: '#FFC107'),
    DefaultCategory(name: 'ترفيه', icon: 'theaters', color: '#E91E63'),
    DefaultCategory(name: 'صحة', icon: 'health_and_safety', color: '#4CAF50'),
    DefaultCategory(name: 'تعليم', icon: 'school', color: '#9C27B0'),
    DefaultCategory(name: 'تسوق', icon: 'shopping_cart', color: '#FF6E40'),
    DefaultCategory(name: 'أخرى', icon: 'category', color: '#757575'),
  ];

  /// فئات الدخل الافتراضية
  static const List<DefaultCategory> defaultIncomeCategories = [
    DefaultCategory(name: 'راتب', icon: 'work', color: '#4CAF50'),
    DefaultCategory(name: 'مشاريع', icon: 'business', color: '#2196F3'),
    DefaultCategory(name: 'استثمارات', icon: 'trending_up', color: '#FF9800'),
    DefaultCategory(name: 'هدايا', icon: 'card_giftcard', color: '#E91E63'),
    DefaultCategory(name: 'أخرى', icon: 'attach_money', color: '#607D8B'),
  ];

  // ============================================================================
  // الحسابات الافتراضية (Default Accounts)
  // ============================================================================

  static const List<DefaultAccount> defaultAccounts = [
    DefaultAccount(
      name: 'نقدي',
      type: 'cash',
      icon: 'account_balance_wallet',
      color: '#4CAF50',
      balance: 0.0,
    ),
    DefaultAccount(
      name: 'حساب بنكي',
      type: 'bank',
      icon: 'account_balance',
      color: '#2196F3',
      balance: 0.0,
    ),
    DefaultAccount(
      name: 'بطاقة ائتمان',
      type: 'creditCard',
      icon: 'credit_card',
      color: '#FF9800',
      balance: 0.0,
    ),
  ];

  // ============================================================================
  // إعدادات الأمان والخصوصية
  // ============================================================================

  /// تمكين قفل التطبيق برقم سري
  static const bool enableAppLock = false;

  /// المدة الافتراضية لقفل التطبيق (بالثواني)
  static const int appLockTimeoutSeconds = 60;

  // ============================================================================
  // إعدادات الإشعارات
  // ============================================================================

  /// تمكين إشعارات تذكير الميزانية
  static const bool enableBudgetNotifications = true;

  /// النسبة المئوية لتنبيه اقتراب نهاية الميزانية
  static const double budgetWarningPercentage = 80.0; // 80%

  /// النسبة المئوية لتنبيه تجاوز الميزانية
  static const double budgetExceededPercentage = 100.0; // 100%

  // ============================================================================
  // إعدادات المزامنة (إذا كان هناك مزامنة سحابية مستقبلاً)
  // ============================================================================

  /// تمكين المزامنة التلقائية
  static const bool enableAutoSync = false;

  /// الفترة الزمنية للمزامنة التلقائية (بالدقائق)
  static const int syncIntervalMinutes = 30;

  // ============================================================================
  // قيود ومحددات
  // ============================================================================

  /// الحد الأقصى لطول اسم الحساب
  static const int maxAccountNameLength = 50;

  /// الحد الأقصى لطول اسم الفئة
  static const int maxCategoryNameLength = 30;

  /// الحد الأقصى لطول الملاحظة
  static const int maxNoteLength = 500;

  /// الحد الأقصى لحجم الصورة المرفقة (بالميجابايت)
  static const double maxReceiptImageSizeMB = 5.0;

  // ============================================================================
  // روابط مفيدة
  // ============================================================================

  /// رابط سياسة الخصوصية
  static const String privacyPolicyUrl = '';

  /// رابط شروط الاستخدام
  static const String termsOfServiceUrl = '';

  /// رابط الدعم
  static const String supportEmail = 'support@mizaneyati.app';
}

// ============================================================================
// Classes مساعدة
// ============================================================================

/// معلومات العملة
class CurrencyInfo {
  final String code;
  final String name;
  final String symbol;
  final int decimalDigits;

  const CurrencyInfo({
    required this.code,
    required this.name,
    required this.symbol,
    required this.decimalDigits,
  });
}

/// فئة افتراضية
class DefaultCategory {
  final String name;
  final String icon;
  final String color;

  const DefaultCategory({
    required this.name,
    required this.icon,
    required this.color,
  });
}

/// حساب افتراضي
class DefaultAccount {
  final String name;
  final String type;
  final String icon;
  final String color;
  final double balance;

  const DefaultAccount({
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    required this.balance,
  });
}
