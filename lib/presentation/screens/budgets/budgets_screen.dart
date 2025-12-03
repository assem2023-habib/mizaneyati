import 'package:flutter/material.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_text_styles.dart';

/// شاشة إدارة الميزانيات (Placeholder)
/// TODO: تنفيذ التصميم الكامل لاحقاً
class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet,
                size: 80,
                color: AppColors.primaryDark,
              ),
              const SizedBox(height: 24),
              Text('الميزانيات', style: AppTextStyles.h2),
              const SizedBox(height: 8),
              Text('قريباً', style: AppTextStyles.bodySecondary),
            ],
          ),
        ),
      ),
    );
  }
}
