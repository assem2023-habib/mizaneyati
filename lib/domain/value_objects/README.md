# Value Objects (VOs)

## نظرة عامة

الـ Value Objects هي كائنات غير قابلة للتغيير (immutable) تحمل قيمة وتتحقق من صحتها تلقائياً. تُستخدم في طبقة الـ Domain لضمان عدم دخول قيم غير صالحة إلى النظام.

## لماذا نستخدم Value Objects؟

### 1. ✅ التحقق الفوري من الصحة

```dart
// ❌ بدون VO - يمكن إنشاء قيمة غير صالحة
final account = AccountEntity(name: '', balance: -100); // خطأ!

// ✅ مع VO - يتم التحقق عند الإنشاء
final nameResult = AccountName.create('');
if (nameResult is Fail) {
  print('Error: ${nameResult.failure.message}');
}
```

### 2. 🔄 تقليل تكرار الكود

القواعد تُكتب مرة واحدة في الـ VO بدلاً من تكرارها في كل مكان.

### 3. 🧹 Entities نظيفة وصغيرة

الـ Entities لا تحتوي على منطق التحقق - تستقبل VOs جاهزة.

### 4. 🧪 سهولة الاختبار

كل VO يمكن اختباره بشكل منفصل.

### 5. 🛡️ منع التسرب

لا يمكن لقيم غير صالحة أن تصل إلى قاعدة البيانات أو الـ UI.

## Value Objects المتاحة

### 💰 Money

تمثيل الأموال بالوحدات الصغرى (قرش).

```dart
// ✅ صحيح
final money = Money.create(15000); // 150.00 ليرة
if (money is Success<Money>) {
  print(money.value.toMajor(100)); // 150.0
}

// ❌ خطأ - مبلغ سالب
final invalid = Money.create(-100);
// Returns: Fail(ValidationFailure('Amount must be >= 0', code: 'money_negative'))
```

**القواعد:**

- المبلغ يجب أن يكون >= 0
- يُخزن بالوحدات الصغرى لتجنب مشاكل الفاصلة العشرية

### 📝 AccountName

اسم الحساب مع التحقق من الطول.

```dart
// ✅ صحيح
final name = AccountName.create('  محفظتي  ');
if (name is Success<AccountName>) {
  print(name.value.value); // 'محفظتي' (تم إزالة الفراغات)
}

// ❌ خطأ - اسم طويل جداً
final longName = AccountName.create('a' * 100);
// Returns: ValidationFailure(code: 'account_name_long')
```

**القواعد:**

- الطول: 1-50 حرف
- يتم إزالة الفراغات من البداية والنهاية تلقائياً

### 🏷️ CategoryName

اسم الفئة - نفس قواعد AccountName.

```dart
final category = CategoryName.create('مواصلات');
```

### 📄 NoteValue

ملاحظة اختيارية مع حد أقصى للطول.

```dart
// ✅ صحيح - نص عادي
final note = NoteValue.create('دفع للبقالة');

// ✅ صحيح - null
final noNote = NoteValue.create(null);

// ✅ صحيح - نص فارغ يتحول إلى null
final emptyNote = NoteValue.create('   ');
if (emptyNote is Success<NoteValue>) {
  print(emptyNote.value.value); // null
}

// ❌ خطأ - نص طويل جداً
final longNote = NoteValue.create('a' * 300);
// Returns: ValidationFailure(code: 'note_too_long')
```

**القواعد:**

- اختياري (يقبل null)
- الحد الأقصى: 200 حرف
- النص الفارغ يتحول إلى null

### 📅 DateValue

تاريخ المعاملة مع منع التواريخ المستقبلية.

```dart
// ✅ صحيح - تاريخ حالي
final date = DateValue.create(DateTime.now());

// ✅ صحيح - مع هامش زمني مخصص
final nearFuture = DateValue.create(
  DateTime.now().add(Duration(minutes: 3)),
  allowedSkew: Duration(minutes: 5),
);

// ❌ خطأ - تاريخ مستقبلي بعيد
final future = DateValue.create(
  DateTime.now().add(Duration(days: 1)),
);
// Returns: ValidationFailure(code: 'date_future')
```

**القواعد:**

- لا يمكن أن يكون في المستقبل (مع هامش 5 دقائق افتراضياً)
- يمكن تخصيص الهامش الزمني

### 🎨 ColorValue

لون بصيغة hex مع التحقق من الصيغة.

```dart
// ✅ صحيح - 6 خانات
final color = ColorValue.create('#ff5722');
if (color is Success<ColorValue>) {
  print(color.value.hex); // '#FF5722' (uppercase)
}

// ✅ صحيح - 8 خانات (مع alpha)
final colorAlpha = ColorValue.create('#ff5722aa');

// ❌ خطأ - صيغة غير صحيحة
final invalid = ColorValue.create('red');
// Returns: ValidationFailure(code: 'invalid_color')
```

**القواعد:**

- يجب أن يكون بصيغة `#RRGGBB` أو `#RRGGBBAA`
- يتم تحويله إلى أحرف كبيرة تلقائياً

### 🎯 IconValue

معرف الأيقونة.

```dart
// ✅ صحيح
final icon = IconValue.create('wallet');

// ❌ خطأ - فارغ
final empty = IconValue.create('   ');
// Returns: ValidationFailure(code: 'icon_empty')
```

**القواعد:**

- يجب ألا يكون فارغاً
- يتم إزالة الفراغات تلقائياً

## كيفية الاستخدام في UseCases

### المثال الكامل

```dart
class CreateAccountUseCase {
  final AccountRepository repository;

  Future<Result<String>> execute({
    required String name,
    required int initialBalanceMinor,
    required String color,
    String? icon,
  }) async {
    // 1. التحقق من VOs
    final nameResult = AccountName.create(name);
    if (nameResult is Fail) return Fail(nameResult.failure);

    final moneyResult = Money.create(initialBalanceMinor);
    if (moneyResult is Fail) return Fail(moneyResult.failure);

    final colorResult = ColorValue.create(color);
    if (colorResult is Fail) return Fail(colorResult.failure);

    Result<IconValue>? iconResult;
    if (icon != null) {
      iconResult = IconValue.create(icon);
      if (iconResult is Fail) return Fail(iconResult.failure);
    }

    // 2. بناء الـ Entity
    final account = AccountEntity(
      id: uuid.v4(),
      name: (nameResult as Success<AccountName>).value.value,
      balanceMinor: (moneyResult as Success<Money>).value.toMinor(),
      color: (colorResult as Success<ColorValue>).value.hex,
      icon: iconResult is Success<IconValue> ? iconResult.value.name : null,
      createdAt: DateTime.now(),
    );

    // 3. حفظ في قاعدة البيانات
    return await repository.createAccount(account);
  }
}
```

### نمط أفضل - Helper Function (اختياري)

```dart
// دالة مساعدة لتقليل التكرار
Result<T> unwrapOrFail<T>(Result<T> result) {
  if (result is Fail) return result;
  return result;
}

// الاستخدام
final nameResult = unwrapOrFail(AccountName.create(name));
if (nameResult is Fail) return nameResult;
```

## مواصفات عامة للـ VO

### ✅ يجب أن يكون

1. **Immutable** - جميع الحقول `final`
2. **Self-validating** - التحقق في factory method
3. **Value equality** - تعريف `==` و `hashCode`
4. **Result pattern** - factory يُرجع `Result<VO>`

### ❌ يجب ألا يحتوي على

1. **I/O operations** - لا قواعد بيانات أو ملفات
2. **Complex logic** - المنطق المعقد يذهب إلى UseCase
3. **Dependencies** - مستقل تماماً

## إنشاء VO جديد

### Template

```dart
import 'package:meta/meta.dart';
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';

@immutable
class YourValueObject {
  final YourType value;

  const YourValueObject._(this.value);

  static Result<YourValueObject> create(YourType input) {
    // التحقق من الصحة هنا
    if (/* شرط الخطأ */) {
      return const Fail(
        ValidationFailure(
          'رسالة الخطأ',
          code: 'error_code',
        ),
      );
    }

    return Success(YourValueObject._(processedInput));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is YourValueObject && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}
```

## الترجمة (i18n)

استخدم `code` من الـ Failure للربط مع الترجمة:

```dart
// في UI layer
String getErrorMessage(String code) {
  final messages = {
    'money_negative': 'المبلغ يجب أن يكون موجب',
    'account_name_short': 'اسم الحساب قصير جداً',
    'account_name_long': 'اسم الحساب طويل جداً',
    'note_too_long': 'الملاحظة طويلة جداً',
    'date_future': 'التاريخ لا يمكن أن يكون في المستقبل',
    'invalid_color': 'صيغة اللون غير صحيحة',
    'icon_empty': 'يجب اختيار أيقونة',
  };
  return messages[code] ?? 'خطأ غير معروف';
}
```

## الاختبار

### مثال Unit Test

```dart
void main() {
  group('Money', () {
    test('should create valid money', () {
      final result = Money.create(1000);

      expect(result, isA<Success<Money>>());
      expect((result as Success<Money>).value.toMinor(), 1000);
    });

    test('should fail for negative amount', () {
      final result = Money.create(-100);

      expect(result, isA<Fail<Money>>());
      expect((result as Fail<Money>).failure.code, 'money_negative');
    });
  });
}
```

## Best Practices

### ✅ افعل

- استخدم VOs لكل القيم التي تحتاج تحقق
- اجعل رسائل الخطأ واضحة ومفيدة
- استخدم error codes للترجمة
- اختبر جميع الحالات (صحيح، خطأ، حدود)

### ❌ لا تفعل

- لا تضع منطق الأعمال في VO
- لا تقم بعمليات I/O في VO
- لا تعتمد على خدمات خارجية
- لا ترمي Exceptions - استخدم Result<T>

## Resources

- [transaction_usecase_example.dart](../usecases/transaction_usecase_example.dart) - مثال كامل لاستخدام VOs
- [Result Pattern](../../core/utils/result.dart) - نمط Result<T>
- [Failures](../../core/errors/failures.dart) - أنواع الأخطاء

---

**ملاحظة:** الـ VOs هي جزء من Clean Architecture - طبقة Domain مستقلة تماماً عن التفاصيل التقنية.
