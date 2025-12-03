import 'package:flutter/material.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_text_styles.dart';

/// شاشة إدارة الفئات (Placeholder)
/// TODO: تنفيذ التصميم الكامل لاحقاً
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الفئات', style: AppTextStyles.h2),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category, size: 80, color: AppColors.primaryDark),
            const SizedBox(height: 24),
            Text('إدارة الفئات', style: AppTextStyles.h2),
            const SizedBox(height: 8),
            Text('قريباً', style: AppTextStyles.bodySecondary),
          ],
        ),
      ),
    );
  }
}
