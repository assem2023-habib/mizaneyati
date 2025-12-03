import 'package:flutter/material.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_text_styles.dart';

/// شاشة إضافة معاملة مالية (Placeholder)
/// TODO: تنفيذ التصميم الكامل لاحقاً
class AddTransactionScreen extends StatelessWidget {
  const AddTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة معاملة', style: AppTextStyles.h2),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 80,
              color: AppColors.primaryDark,
            ),
            const SizedBox(height: 24),
            Text('إضافة معاملة مالية', style: AppTextStyles.h2),
            const SizedBox(height: 8),
            Text('قريباً', style: AppTextStyles.bodySecondary),
          ],
        ),
      ),
    );
  }
}
