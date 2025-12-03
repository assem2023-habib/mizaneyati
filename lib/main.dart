import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'presentation/styles/app_theme.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/screens/add_transaction/add_transaction_screen.dart';
import 'presentation/screens/accounts/accounts_screen.dart';
import 'presentation/screens/categories/categories_screen.dart';

void main() {
  // تكوين شريط الحالة
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ============================================
      // معلومات التطبيق
      // ============================================
      title: 'ميزانيتي',
      debugShowCheckedModeBanner: false,

      // ============================================
      // الثيم
      // ============================================
      theme: AppTheme.lightTheme,

      // ============================================
      // اللغة والاتجاه (RTL للعربية)
      // ============================================
      locale: AppTheme.arabicLocale,
      supportedLocales: const [
        Locale('ar', 'SY'), // العربية (سوريا)
        Locale('en', 'US'), // الإنجليزية
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ============================================
      // التوجيه (Routing)
      // ============================================
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/main': (context) => const MainScreen(),
        '/dashboard': (context) => const MainScreen(), // نفس الشاشة الرئيسية
        '/add-transaction': (context) => const AddTransactionScreen(),
        '/accounts': (context) => const AccountsScreen(),
        '/categories': (context) => const CategoriesScreen(),
      },

      // ============================================
      // الشاشة الأولى
      // ============================================
      home: const OnboardingScreen(),
    );
  }
}
