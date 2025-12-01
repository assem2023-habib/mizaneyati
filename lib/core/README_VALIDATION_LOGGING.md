# دليل سريع - Validation & Database Logging

## 📁 الملفات المنفذة

### Core Files (الملفات الأساسية)

- ✅ `lib/core/validation/validators.dart` - 11 دالة تحقق
- ✅ `lib/core/logging/db_logger.dart` - نظام تسجيل شامل

### Example Files (ملفات الأمثلة)

- ✅ `lib/domain/usecases/transaction_usecase_example.dart` - 3 أمثلة UseCases
- ✅ `lib/data/local/daos/accounts_dao_example.dart` - 6 أمثلة DAOs

### Dependencies (التبعيات)

- ✅ `logger: ^2.0.2+1` مضاف إلى pubspec.yaml

---

## 🚀 البدء السريع

### 1. استخدام Validators

```dart
import 'package:mizaneyati/core/validation/validators.dart';
import 'package:mizaneyati/core/utils/result.dart';

// في Repository أو UseCase:
final validation = Validators.validateAmount(amount);
if (validation is Fail) {
  return Fail((validation as Fail).failure);
}
```

### 2. استخدام DbLogger

```dart
import 'package:mizaneyati/core/logging/db_logger.dart';

// تسجيل استعلام
final sw = Stopwatch()..start();
try {
  final result = await database.query(...);
  sw.stop();
  DbLogger().logQuery('SELECT ...', duration: sw.elapsed);
  return result;
} catch (e, st) {
  DbLogger().logError('Query failed', e, st);
  rethrow;
}
```

---

## 📚 قواعد التحقق المتاحة

| الدالة                                 | متى تستخدمها        |
| -------------------------------------- | ------------------- |
| `validateAmount(double)`               | قبل أي عملية مالية  |
| `validateAccountActive(bool, String?)` | قبل إنشاء معاملة    |
| `validateCategoryForTransaction(...)`  | عند ربط فئة بمعاملة |
| `validateNotFutureDate(DateTime)`      | عند إدخال تاريخ     |
| `validateTransfer(...)`                | عند تحويل أموال     |
| `canDeleteCategory(int)`               | قبل حذف فئة         |
| `canDeleteAccount(...)`                | قبل حذف حساب        |
| `validateAccountName(String)`          | إنشاء/تحديث حساب    |
| `validateCategoryName(String)`         | إنشاء/تحديث فئة     |
| `validateNonNegativeBalance(double)`   | تحديث رصيد          |

---

## 🎯 أمثلة سريعة

### مثال 1: التحقق في Repository

```dart
Future<Result<String>> createAccount({required String name, required double balance}) async {
  // التحقق من الاسم
  final nameValidation = Validators.validateAccountName(name);
  if (nameValidation is Fail) return Fail((nameValidation as Fail).failure);

  // التحقق من الرصيد
  final balanceValidation = Validators.validateNonNegativeBalance(balance);
  if (balanceValidation is Fail) return Fail((balanceValidation as Fail).failure);

  // متابعة الإنشاء...
  await _dao.insert(...);
}
```

### مثال 2: التحقق المتعدد في UseCase

```dart
Future<Result<String>> createTransaction(TransactionEntity tx) async {
  // 1. تحقق من البيانات الأساسية
  final validations = [
    Validators.validateAmount(tx.amount),
    Validators.validateNotFutureDate(tx.date),
  ];

  for (final validation in validations) {
    if (validation is Fail) return Fail((validation as Fail).failure);
  }

  // 2. تحقق من الحساب
  final accountResult = await _accountRepo.getAccountById(tx.accountId);
  if (accountResult is Fail) return Fail((accountResult as Fail).failure);

  final account = (accountResult as Success).value;
  final activeCheck = Validators.validateAccountActive(account.isActive);
  if (activeCheck is Fail) return Fail((activeCheck as Fail).failure);

  // 3. متابعة العملية...
}
```

### مثال 3: Logging في DAO

```dart
@DriftAccessor(tables: [Accounts])
class AccountsDao extends DatabaseAccessor<AppDatabase> {
  Future<List<AccountData>> getAllAccounts() async {
    final sw = Stopwatch()..start();

    try {
      final result = await select(accounts).get();
      sw.stop();

      DbLogger().logQuery(
        'SELECT * FROM accounts',
        duration: sw.elapsed,
      );

      // تحذير للاستعلامات البطيئة
      if (sw.elapsedMilliseconds > 200) {
        DbLogger().logWarning('Slow query: ${sw.elapsedMilliseconds}ms');
      }

      return result;
    } catch (e, st) {
      DbLogger().logError('Failed to get accounts', e, st);
      rethrow;
    }
  }
}
```

---

## ⚙️ النصائح الهامة

### ✅ افعل

- استخدم Validators في بداية كل دالة UseCase/Repository
- سجّل الاستعلامات البطيئة والعمليات المعقدة
- أضف context (meta) للأخطاء لسهولة التتبع
- اختبر Validators مع unit tests

### ❌ لا تفعل

- لا تسجل بيانات حساسة في الإنتاج
- لا تسجل كل استعلام (فقط الحرجة/البطيئة)
- لا تتجاهل فشل التحقق
- لا تضع validations في UI فقط

---

## 🧪 اختبار سريع

```dart
void main() {
  test('validateAmount works correctly', () {
    expect(Validators.validateAmount(100), isA<Success>());
    expect(Validators.validateAmount(0), isA<Fail>());
    expect(Validators.validateAmount(-50), isA<Fail>());
  });
}
```

---

## 📖 المراجع الكاملة

- [walkthrough.md](file:///C:/Users/RYZEN/.gemini/antigravity/brain/d3ef96c4-15b6-40bd-9fc8-b0ae5b7806cb/walkthrough.md) - دليل شامل
- [implementation_plan.md](file:///C:/Users/RYZEN/.gemini/antigravity/brain/d3ef96c4-15b6-40bd-9fc8-b0ae5b7806cb/implementation_plan.md) - خطة التنفيذ
- [transaction_usecase_example.dart](file:///c:/Users/RYZEN/Desktop/Flutter/mizaneyati/lib/domain/usecases/transaction_usecase_example.dart) - أمثلة UseCases
- [accounts_dao_example.dart](file:///c:/Users/RYZEN/Desktop/Flutter/mizaneyati/lib/data/local/daos/accounts_dao_example.dart) - أمثلة DAOs

---

تم بنجاح! 🎉
