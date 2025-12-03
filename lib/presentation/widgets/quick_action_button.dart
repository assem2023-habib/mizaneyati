import 'package:flutter/material.dart';
import '../styles/app_colors.dart';
import '../styles/app_spacing.dart';
import 'glassmorphic_container.dart';

/// زر عمل سريع دائري (Quick Action Button)
/// يُستخدم في: Dashboard للأزرار الثلاثة (مصروف، دخل، تحويل)
class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color glowColor;
  final String label;
  final VoidCallback onPressed;
  final double size;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.glowColor,
    required this.label,
    required this.onPressed,
    this.size = AppSpacing.quickActionSize,
  });

  /// زر مصروف (Expense)
  factory QuickActionButton.expense({
    required VoidCallback onPressed,
    String label = 'مصروف',
  }) {
    return QuickActionButton(
      icon: Icons.arrow_downward,
      iconColor: AppColors.expense,
      glowColor: AppColors.expense,
      label: label,
      onPressed: onPressed,
    );
  }

  /// زر دخل (Income)
  factory QuickActionButton.income({
    required VoidCallback onPressed,
    String label = 'دخل',
  }) {
    return QuickActionButton(
      icon: Icons.arrow_upward,
      iconColor: AppColors.income,
      glowColor: AppColors.income,
      label: label,
      onPressed: onPressed,
    );
  }

  /// زر تحويل (Transfer)
  factory QuickActionButton.transfer({
    required VoidCallback onPressed,
    String label = 'تحويل',
  }) {
    return QuickActionButton(
      icon: Icons.swap_horiz,
      iconColor: AppColors.transfer,
      glowColor: AppColors.transfer,
      label: label,
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // الزر الدائري
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: AppColors.glassBg50,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.glassBorder70, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withOpacity(0.25),
                    blurRadius: AppSpacing.shadowLg,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: glowColor.withOpacity(0.15),
                    blurRadius: 20,
                    offset: Offset.zero,
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: AppSpacing.iconLg),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.paddingSm),
        // النص
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.gray600,
          ),
        ),
      ],
    );
  }
}
