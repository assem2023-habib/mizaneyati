import 'package:flutter/material.dart';
import '../styles/app_colors.dart';
import '../styles/app_spacing.dart';

/// مؤشرات الصفحات (Page Indicators)
/// يُستخدم في: Onboarding
class PageIndicators extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const PageIndicators({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.paddingXs),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: index == currentPage
                ? AppSpacing.activeIndicatorWidth
                : AppSpacing.inactiveIndicatorSize,
            height: AppSpacing.indicatorHeight,
            decoration: BoxDecoration(
              color: index == currentPage
                  ? AppColors.primaryDark
                  : AppColors.gray300,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
          ),
        ),
      ),
    );
  }
}
