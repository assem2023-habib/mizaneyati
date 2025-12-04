import 'package:flutter/material.dart';
import '../../../styles/app_colors.dart';
import '../../../styles/app_text_styles.dart';

/// Notes input field widget
class NotesInputField extends StatelessWidget {
  final TextEditingController controller;

  const NotesInputField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray300.withOpacity(0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        maxLines: 3,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'ملاحظات...',
          hintStyle: AppTextStyles.bodySecondary,
          icon: const Icon(Icons.notes, color: AppColors.gray400, size: 20),
        ),
        style: AppTextStyles.body,
      ),
    );
  }
}
