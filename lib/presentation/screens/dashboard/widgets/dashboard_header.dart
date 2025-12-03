import 'package:flutter/material.dart';
import '../../../styles/app_colors.dart';
import '../../../styles/app_text_styles.dart';
import '../../../styles/app_spacing.dart';
import '../../../widgets/glassmorphic_container.dart';

/// رأس شاشة Dashboard (Glassmorphic Header)
class DashboardHeader extends StatelessWidget {
  final String greeting;
  final String title;
  final VoidCallback? onProfileTap;

  const DashboardHeader({
    super.key,
    this.greeting = 'مرحباً',
    this.title = 'لوحة التحكم',
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.paddingContainer),
      child: GlassmorphicContainer(
        padding: const EdgeInsets.all(AppSpacing.paddingLg),
        borderRadius: BorderRadius.circular(AppSpacing.radiusHeader),
        blurStrength: 24,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // النص الترحيبي والعنوان
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(greeting, style: AppTextStyles.caption),
                  const SizedBox(height: 4),
                  Text(title, style: AppTextStyles.h2),
                ],
              ),
            ),

            // أيقونة المستخدم
            InkWell(
              onTap: onProfileTap,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              child: Container(
                width: AppSpacing.userAvatarSize,
                height: AppSpacing.userAvatarSize,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.white,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
