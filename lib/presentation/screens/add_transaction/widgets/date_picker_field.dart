import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../../../styles/app_colors.dart';
import '../../../styles/app_text_styles.dart';

/// Date picker field widget
class DatePickerField extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onTap;

  const DatePickerField({
    super.key,
    required this.selectedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gray300.withOpacity(0.5)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.gray400,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              intl.DateFormat('yyyy-MM-dd').format(selectedDate),
              style: AppTextStyles.body,
            ),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down, color: AppColors.gray600),
          ],
        ),
      ),
    );
  }
}
