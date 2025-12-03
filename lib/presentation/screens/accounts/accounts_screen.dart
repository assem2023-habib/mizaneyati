import 'package:flutter/material.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_text_styles.dart';

/// شاشة إدارة الحسابات (Placeholder)
/// TODO: تنفيذ التصميم الكامل لاحقاً
class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الحسابات', style: AppTextStyles.h2),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance, size: 80, color: AppColors.primaryDark),
            const SizedBox(height: 24),
            Text('إدارة الحسابات', style: AppTextStyles.h2),
            const SizedBox(height: 8),
            Text('قريباً', style: AppTextStyles.bodySecondary),
          ],
        ),
      ),
    );
  }
}
