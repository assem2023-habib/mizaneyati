import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';
import 'dashboard/dashboard_screen.dart';
import 'transactions_list/transactions_list_screen.dart';
import 'statistics/statistics_screen.dart';
import 'budgets/budgets_screen.dart';
import 'settings/settings_screen.dart';

/// شاشة رئيسية تحتوي على Bottom Navigation
/// تدير التنقل بين الشاشات الخمس الرئيسية
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(), // 0 - الرئيسية
    TransactionsListScreen(), // 1 - المعاملات
    StatisticsScreen(), // 2 - الإحصائيات
    BudgetsScreen(), // 3 - الميزانيات
    SettingsScreen(), // 4 - الإعدادات
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
