import 'package:flutter/material.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_text_styles.dart';

/// شاشة الإعدادات (Placeholder)
/// TODO: تنفيذ التصميم الكامل لاحقاً
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.settings, size: 80, color: AppColors.primaryDark),
              const SizedBox(height: 24),
              Text('الإعدادات', style: AppTextStyles.h2),
              const SizedBox(height: 8),
              Text('قريباً', style: AppTextStyles.bodySecondary),
            ],
          ),
        ),
      ),
    );
  }
}
