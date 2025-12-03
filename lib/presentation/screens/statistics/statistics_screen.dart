import 'package:flutter/material.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_text_styles.dart';

/// شاشة الإحصائيات والرسوم البيانية (Placeholder)
/// TODO: تنفيذ التصميم الكامل لاحقاً
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, size: 80, color: AppColors.primaryDark),
              const SizedBox(height: 24),
              Text('الإحصائيات', style: AppTextStyles.h2),
              const SizedBox(height: 8),
              Text('قريباً', style: AppTextStyles.bodySecondary),
            ],
          ),
        ),
      ),
    );
  }
}
