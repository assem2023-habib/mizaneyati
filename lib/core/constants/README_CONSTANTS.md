# دليل استخدام الثوابت - App Constants

## ملف `app_constants.dart`

ملف شامل يحتوي على جميع ثوابت وإعدادات التطبيق.

## المحتويات

### 1. معلومات التطبيق

```dart
AppConstants.appName           // 'ميزانيتي'
AppConstants.appVersion        // '1.0.0'
```

### 2. العملات 🪙

#### العملة الافتراضية

```dart
AppConstants.defaultCurrency        // 'SYP'
AppConstants.defaultCurrencySymbol  // 'ل.س'
```

#### الوصول للعملات

```dart
final syrianPound = AppConstants.supportedCurrencies['SYP']!;
print(syrianPound.symbol);      // 'ل.س'
print(syrianPound.decimalDigits); // 0
```

### 3. تنسيقات التاريخ 📅

```dart
AppConstants.defaultDateFormat     // 'yyyy-MM-dd'
AppConstants.displayDateFormat     // 'd MMMM yyyy'
AppConstants.shortDateFormat       // 'dd/MM/yyyy'
AppConstants.timeFormat            // 'HH:mm'
AppConstants.dateTimeFormat        // 'yyyy-MM-dd HH:mm'
```

#### مثال استخدام

```dart
import 'package:intl/intl.dart';

final formatter = DateFormat(AppConstants.displayDateFormat, 'ar');
final dateStr = formatter.format(DateTime.now());
// 'ناتج: "1 ديسمبر 2024"
```

### 4. الإعدادات المالية 💰

```dart
AppConstants.minAmount               // 0.01
AppConstants.maxAmount               // 100,000,000,000
AppConstants.defaultDecimalPlaces    // 0 (للسوري)
AppConstants.defaultAccountBalance   // 0.0
```

#### استخدام في التحقق

```dart
if (amount < AppConstants.minAmount) {
  return ValidationFailure('المبلغ أقل من الحد الأدنى');
}

if (amount > AppConstants.maxAmount) {
  return ValidationFailure('المبلغ أكبر من الحد الأقصى');
}
```

### 5. الألوان والأيقونات 🎨

#### الألوان الافتراضية

```dart
AppConstants.defaultColors[0]  // '#FF5252' (أحمر)
AppConstants.defaultColors[1]  // '#FF6E40' (برتقالي)
// ... 14 لون
```

#### الأيقونات

```dart
AppConstants.defaultIcons[0]   // 'shopping_cart'
AppConstants.defaultIcons[1]   // 'restaurant'
// ... 20 أيقونة
```

#### مثال: عرض قائمة الألوان

```dart
Widget buildColorPicker() {
  return Wrap(
    children: AppConstants.defaultColors.map((colorHex) {
      return GestureDetector(
        onTap: () => selectColor(colorHex),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000),
            shape: BoxShape.circle,
          ),
        ),
      );
    }).toList(),
  );
}
```

### 6. الفئات الافتراضية 📂

#### فئات المصروفات

```dart
AppConstants.defaultExpenseCategories  // 8 فئات
// طعام ومشروبات، مواصلات، فواتير، ترفيه، صحة، تعليم، تسوق، أخرى
```

#### فئات الدخل

```dart
AppConstants.defaultIncomeCategories   // 5 فئات
// راتب، مشاريع، استثمارات، هدايا، أخرى
```

#### مثال: إنشاء فئات افتراضية عند أول استخدام

```dart
Future<void> createDefaultCategories() async {
  for (final defaultCat in AppConstants.defaultExpenseCategories) {
    await categoryRepo.createCategory(
      name: defaultCat.name,
      icon: defaultCat.icon,
      color: defaultCat.color,
      type: CategoryType.expense,
    );
  }

  for (final defaultCat in AppConstants.defaultIncomeCategories) {
    await categoryRepo.createCategory(
      name: defaultCat.name,
      icon: defaultCat.icon,
      color: defaultCat.color,
      type: CategoryType.income,
    );
  }
}
```

### 7. الحسابات الافتراضية 🏦

```dart
AppConstants.defaultAccounts  // 3 حسابات
// نقدي، حساب بنكي، بطاقة ائتمان
```

#### مثال: إنشاء حسابات افتراضية

```dart
Future<void> createDefaultAccounts() async {
  for (final defaultAcc in AppConstants.defaultAccounts) {
    await accountRepo.createAccount(
      name: defaultAcc.name,
      balance: defaultAcc.balance,
      type: AccountType.values.firstWhere(
        (t) => t.name == defaultAcc.type,
      ),
      color: defaultAcc.color,
      icon: defaultAcc.icon,
    );
  }
}
```

### 8. إعدادات التقارير 📊

```dart
AppConstants.defaultReportDays    // 30 يوم
AppConstants.itemsPerPage         // 20 عنصر
AppConstants.maxTopCategories     // 5 فئات
```

### 9. النسخ الاحتياطي 💾

```dart
AppConstants.backupFolderName        // 'mizaneyati_backups'
AppConstants.maxAutoBackups          // 10
```

### 10. القيود والمحددات ⚠️

```dart
AppConstants.maxAccountNameLength     // 50 حرف
AppConstants.maxCategoryNameLength    // 30 حرف
AppConstants.maxNoteLength            // 500 حرف
AppConstants.maxReceiptImageSizeMB    // 5.0 MB
```

#### مثال: التحقق من طول الاسم

```dart
final accountName = 'حساب البنك العربي الدولي التجاري الكبير المتحد';
if (accountName.length > AppConstants.maxAccountNameLength) {
  return ValidationFailure('اسم الحساب طويل جداً');
}
```

### 11. الإشعارات 🔔

```dart
AppConstants.enableBudgetNotifications  // true
AppConstants.budgetWarningPercentage    // 80%
AppConstants.budgetExceededPercentage   // 100%
```

#### مثال: التحقق من تجاوز الميزانية

```dart
final percentage = (spent / budget.limitAmount) * 100;

if (percentage >= AppConstants.budgetWarningPercentage) {
  showNotification('تحذير: اقتربت من نهاية ميزانيتك!');
}

if (percentage >= AppConstants.budgetExceededPercentage) {
  showNotification('تجاوزت الميزانية المحددة!');
}
```

## أمثلة عملية كاملة

### مثال 1: عرض المبلغ بالعملة

```dart
String formatCurrency(double amount) {
  final currency = AppConstants.supportedCurrencies[AppConstants.defaultCurrency]!;
  final formatter = NumberFormat.currency(
    symbol: currency.symbol,
    decimalDigits: currency.decimalDigits,
    locale: 'ar',
  );
  return formatter.format(amount);
}

// الاستخدام
print(formatCurrency(1000));  // '1,000 ل.س'
```

### مثال 2: مدقق طول النص

```dart
String? validateText(String text, {required String fieldName, required int maxLength}) {
  if (text.trim().isEmpty) {
    return '$fieldName مطلوب';
  }
  if (text.length > maxLength) {
    return '$fieldName طويل جداً (الحد الأقصى $maxLength حرف)';
  }
  return null;
}

// الاستخدام
final error = validateText(
  accountName,
  fieldName: 'اسم الحساب',
  maxLength: AppConstants.maxAccountNameLength,
);
```

### مثال 3: Setup أولي للتطبيق

```dart
Future<void> setupFirstTimeUse() async {
  // 1. إنشاء الفئات الافتراضية
  await createDefaultCategories();

  // 2. إنشاء الحسابات الافتراضية
  await createDefaultAccounts();

  // 3. حفظ الإعدادات
  await prefs.setString('currency', AppConstants.defaultCurrency);
  await prefs.setString('dateFormat', AppConstants.displayDateFormat);

  print('تم إعداد التطبيق بنجاح!');
}
```

## نصائح

> [!TIP]
> استخدم `AppConstants` بدلاً من القيم الثابتة المباشرة (hardcoded) في كل مكان بالتطبيق

> [!IMPORTANT]
> عند تغيير أي ثابت، تأكد من تحديث جميع الأماكن التي تعتمد عليه

> [!NOTE]
> يمكنك توسيع `AppConstants` بإضافة ثوابت جديدة حسب احتياجك

---

✅ جاهز للاستخدام!
