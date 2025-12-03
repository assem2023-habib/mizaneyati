# أفضل الممارسات والنصائح - Best Practices

**آخر تحديث:** ديسمبر 2025

---

## 🎯 مبادئ عامة

### 1. اتبع Clean Architecture
```dart
// ✅ صحيح: فصل واضح بين الطبقات
class TransactionRepository {
  final TransactionDao _dao;
  
  Future<Result<String>> create(TransactionEntity tx) async {
    // منطق المستودع
  }
}

// ❌ خطأ: خلط بين الطبقات
class TransactionRepository {
  Future<Result<String>> create(TransactionEntity tx) async {
    // منطق قاعدة البيانات
    final db = AppDatabase();
    // ...
  }
}
```

### 2. استخدم Result Pattern
```dart
// ✅ صحيح: معالجة آمنة للأخطاء
final result = await repository.create(entity);
if (result is Success) {
  final id = result.value;
  // معالجة النجاح
} else if (result is Fail) {
  final failure = result.failure;
  // معالجة الفشل
}

// ❌ خطأ: استثناءات غير معالجة
try {
  final id = await repository.create(entity);
} catch (e) {
  // معالجة عامة
}
```

### 3. استخدم Value Objects
```dart
// ✅ صحيح: التحقق في Value Object
final nameResult = AccountName.create('حسابي');
if (nameResult is Fail) {
  return Fail((nameResult as Fail).failure);
}
final name = (nameResult as Success).value;

// ❌ خطأ: التحقق في كل مكان
if (name.isEmpty || name.length > 50) {
  return Fail(ValidationFailure('...'));
}
```

### 4. استخدم Riverpod بشكل صحيح
```dart
// ✅ صحيح: استخدام Providers
final accountsProvider = FutureProvider<List<AccountEntity>>((ref) async {
  final repo = ref.watch(accountRepositoryProvider);
  return await repo.getAll();
});

// ❌ خطأ: حالة محلية
class AccountsScreen extends StatefulWidget {
  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  List<AccountEntity> accounts = [];
  // ...
}
```

---

## 📝 معايير الكود

### 1. التسمية
```dart
// ✅ صحيح: أسماء واضحة ومعبرة
class CreateAccountUseCase {
  Future<Result<String>> call({required String name}) async { }
}

final accountRepositoryProvider = Provider((ref) => AccountRepositoryImpl());

// ❌ خطأ: أسماء غير واضحة
class CA {
  Future<Result<String>> execute({required String n}) async { }
}

final arp = Provider((ref) => ARI());
```

### 2. التعليقات والتوثيق
```dart
// ✅ صحيح: توثيق واضح
/// ينشئ حساب جديد
/// 
/// [name] - اسم الحساب (1-50 حرف)
/// [balance] - الرصيد الأولي
/// 
/// يرجع معرف الحساب الجديد أو فشل
Future<Result<String>> createAccount({
  required String name,
  required double balance,
}) async { }

// ❌ خطأ: بدون توثيق
Future<Result<String>> createAccount({
  required String name,
  required double balance,
}) async { }
```

### 3. الثوابت
```dart
// ✅ صحيح: استخدام AppConstants
if (name.length > AppConstants.maxAccountNameLength) {
  return Fail(ValidationFailure('اسم طويل جداً'));
}

// ❌ خطأ: hardcoded values
if (name.length > 50) {
  return Fail(ValidationFailure('اسم طويل جداً'));
}
```

### 4. معالجة الأخطاء
```dart
// ✅ صحيح: أخطاء محددة
if (result is Fail) {
  final failure = result.failure;
  if (failure is ValidationFailure) {
    // معالجة خطأ التحقق
  } else if (failure is DatabaseFailure) {
    // معالجة خطأ قاعدة البيانات
  }
}

// ❌ خطأ: معالجة عامة
if (result is Fail) {
  print('حدث خطأ');
}
```

---

## 🎨 أفضل ممارسات الواجهات الرسومية

### 1. استخدم const Constructors
```dart
// ✅ صحيح
class MyWidget extends StatelessWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Hello'),
      ),
    );
  }
}

// ❌ خطأ
class MyWidget extends StatelessWidget {
  MyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Hello'),
      ),
    );
  }
}
```

### 2. استخدم ConsumerWidget
```dart
// ✅ صحيح: الوصول إلى Riverpod
class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsProvider);
    return accounts.when(
      data: (data) => ListView(children: [...]),
      loading: () => const CircularProgressIndicator(),
      error: (err, st) => Text('خطأ: $err'),
    );
  }
}

// ❌ خطأ: استخدام StatefulWidget
class AccountsScreen extends StatefulWidget {
  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}
```

### 3. استخدم Responsive Design
```dart
// ✅ صحيح: تصميم متجاوب
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return isMobile ? MobileLayout() : DesktopLayout();
  }
}

// ❌ خطأ: تصميم ثابت
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 600,
      child: MyLayout(),
    );
  }
}
```

### 4. استخدم Theme
```dart
// ✅ صحيح: استخدام الثيم
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Hello',
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}

// ❌ خطأ: ألوان hardcoded
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Hello',
      style: TextStyle(
        fontSize: 24,
        color: Colors.blue,
      ),
    );
  }
}
```

---

## 🧪 أفضل ممارسات الاختبار

### 1. اختبر Value Objects
```dart
// ✅ صحيح
test('Money should fail for negative amount', () {
  final result = Money.create(-100);
  expect(result, isA<Fail>());
});

// ❌ خطأ
test('Money creation', () {
  final money = Money.create(100);
  expect(money, isNotNull);
});
```

### 2. اختبر UseCases
```dart
// ✅ صحيح
test('CreateAccountUseCase should create account', () async {
  final mockRepo = MockAccountRepository();
  final useCase = CreateAccountUseCase(mockRepo);
  
  final result = await useCase(name: 'Test', balance: 100);
  
  expect(result, isA<Success>());
  verify(mockRepo.create(any)).called(1);
});

// ❌ خطأ
test('CreateAccountUseCase works', () async {
  final useCase = CreateAccountUseCase(realRepository);
  final result = await useCase(name: 'Test', balance: 100);
  expect(result, isNotNull);
});
```

### 3. استخدم Mocks
```dart
// ✅ صحيح
class MockAccountRepository extends Mock implements AccountRepository {}

test('test', () {
  final mockRepo = MockAccountRepository();
  when(mockRepo.getAll()).thenAnswer((_) async => []);
  // ...
});

// ❌ خطأ
test('test', () {
  final repo = AccountRepositoryImpl(realDatabase);
  // ...
});
```

---

## 📊 أفضل ممارسات الأداء

### 1. استخدم Lazy Loading
```dart
// ✅ صحيح: تحميل كسول
final accountsProvider = FutureProvider((ref) async {
  return await repository.getAll();
});

// ❌ خطأ: تحميل فوري
final accounts = await repository.getAll();
```

### 2. استخدم Caching
```dart
// ✅ صحيح: تخزين مؤقت
final accountsProvider = FutureProvider.autoDispose((ref) async {
  return await repository.getAll();
});

// ❌ خطأ: بدون تخزين
final accountsProvider = FutureProvider((ref) async {
  return await repository.getAll();
});
```

### 3. استخدم Pagination
```dart
// ✅ صحيح: تقسيم البيانات
final transactionsProvider = FutureProvider.autoDispose
    .family<List<TransactionEntity>, int>((ref, page) async {
  return await repository.getPage(page);
});

// ❌ خطأ: تحميل الكل
final transactionsProvider = FutureProvider((ref) async {
  return await repository.getAll();
});
```

---

## 🔐 أفضل ممارسات الأمان

### 1. التحقق من المدخلات
```dart
// ✅ صحيح
final validation = Validators.validateAmount(amount);
if (validation is Fail) {
  return Fail((validation as Fail).failure);
}

// ❌ خطأ
if (amount > 0) {
  // معالجة
}
```

### 2. معالجة الأخطاء
```dart
// ✅ صحيح
try {
  final result = await database.query(...);
  return Success(result);
} catch (e, st) {
  DbLogger().logError('Query failed', e, st);
  return Fail(DatabaseFailure('خطأ في قاعدة البيانات'));
}

// ❌ خطأ
final result = await database.query(...);
return Success(result);
```

### 3. حماية البيانات الحساسة
```dart
// ✅ صحيح
DbLogger().logInfo('User logged in');
// لا تسجل كلمات المرور أو البيانات الحساسة

// ❌ خطأ
DbLogger().logInfo('User: $email, Password: $password');
```

---

## 📱 أفضل ممارسات التطبيق

### 1. استخدم Proper Navigation
```dart
// ✅ صحيح: استخدام GoRouter
context.go('/accounts');
context.push('/account/edit/$id');

// ❌ خطأ: استخدام Navigator
Navigator.of(context).push(
  MaterialPageRoute(builder: (_) => AccountsScreen()),
);
```

### 2. استخدم Localization
```dart
// ✅ صحيح: استخدام intl
final formatter = DateFormat(AppConstants.displayDateFormat, 'ar');
final dateStr = formatter.format(date);

// ❌ خطأ: hardcoded strings
final dateStr = '${date.day}/${date.month}/${date.year}';
```

### 3. استخدم Proper State Management
```dart
// ✅ صحيح: Riverpod
final isLoadingProvider = StateProvider((ref) => false);

// ❌ خطأ: setState
setState(() {
  isLoading = true;
});
```

---

## 🚀 نصائح للإنتاجية

### 1. استخدم Code Generation
```bash
# توليد الكود
flutter pub run build_runner build --delete-conflicting-outputs

# مراقبة التغييرات
flutter pub run build_runner watch
```

### 2. استخدم Hot Reload
```bash
# تشغيل مع Hot Reload
flutter run

# في الكونسول: اضغط 'r'
```

### 3. استخدم DevTools
```bash
# فتح DevTools
flutter pub global run devtools

# أو من VS Code: Ctrl+Shift+P > Open DevTools
```

### 4. استخدم Snippets
```dart
// إنشاء snippets مخصصة في VS Code
// File > Preferences > User Snippets > dart.json
```

---

## 📚 قائمة التحقق قبل الـ Commit

- [ ] الكود يتبع معايير الأسلوب
- [ ] جميع الاختبارات تمر
- [ ] لا توجد تحذيرات من المحلل
- [ ] التوثيق محدث
- [ ] لا توجد hardcoded values
- [ ] معالجة الأخطاء صحيحة
- [ ] الأداء محسّن
- [ ] لا توجد بيانات حساسة مسجلة

---

## 🎓 موارد تعليمية

### Flutter
- [Flutter Documentation](https://flutter.dev)
- [Flutter Cookbook](https://flutter.dev/docs/cookbook)
- [Flutter Best Practices](https://flutter.dev/docs/testing/best-practices)

### Dart
- [Dart Documentation](https://dart.dev)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Dart Null Safety](https://dart.dev/null-safety)

### Architecture
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [MVVM Pattern](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel)
- [Repository Pattern](https://martinfowler.com/eaaCatalog/repository.html)

### State Management
- [Riverpod Documentation](https://riverpod.dev)
- [Provider Pattern](https://pub.dev/packages/provider)
- [GetX](https://pub.dev/packages/get)

---

## 💡 نصائح إضافية

### 1. استخدم Linting
```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - avoid_print
    - prefer_const_constructors
    - prefer_const_declarations
```

### 2. استخدم Formatting
```bash
# تنسيق الكود
dart format lib/

# التحقق من التنسيق
dart format --set-exit-if-changed lib/
```

### 3. استخدم Analyzer
```bash
# تحليل الكود
flutter analyze

# مع تقرير مفصل
flutter analyze --watch
```

---

تم إعداد الملف: ديسمبر 2025

**اتبع هذه الممارسات لضمان كود عالي الجودة وسهل الصيانة.**
