import 'package:flutter/material.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_text_styles.dart';

/// شاشة قائمة المعاملات (Placeholder)
/// TODO: تنفيذ التصميم الكامل لاحقاً
class TransactionsListScreen extends StatelessWidget {
  const TransactionsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long, size: 80, color: AppColors.primaryDark),
              const SizedBox(height: 24),
              Text('قائمة المعاملات', style: AppTextStyles.h2),
              const SizedBox(height: 8),
              Text('قريباً', style: AppTextStyles.bodySecondary),
            ],
          ),
        ),
      ),
    );
  }
}
