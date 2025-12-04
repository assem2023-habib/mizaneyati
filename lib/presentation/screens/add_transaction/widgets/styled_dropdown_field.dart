import 'package:flutter/material.dart';
import '../../../styles/app_colors.dart';
import '../../../styles/app_text_styles.dart';

/// Generic dropdown field with consistent styling
class StyledDropdownField<T> extends StatelessWidget {
  final T? value;
  final String hintText;
  final IconData hintIcon;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const StyledDropdownField({
    super.key,
    this.value,
    required this.hintText,
    required this.hintIcon,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray300.withOpacity(0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Row(
            children: [
              Icon(hintIcon, color: AppColors.gray400, size: 20),
              const SizedBox(width: 12),
              Text(hintText, style: AppTextStyles.bodySecondary),
            ],
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.gray600),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
