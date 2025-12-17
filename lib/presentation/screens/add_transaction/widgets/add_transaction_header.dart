import 'package:flutter/material.dart';
import '../../../styles/app_colors.dart';
import '../../../styles/app_text_styles.dart';

/// Header widget for the Add Transaction screen
class AddTransactionHeader extends StatelessWidget {
  final bool isEditing;

  const AddTransactionHeader({super.key, this.isEditing = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: AppTextStyles.buttonSmall.copyWith(
                color: AppColors.gray600,
              ),
            ),
          ),
          Text(isEditing ? 'تعديل معاملة' : 'إضافة معاملة', style: AppTextStyles.h3),
          const SizedBox(width: 48), // Spacer to balance the "Cancel" button
        ],
      ),
    );
  }
}
