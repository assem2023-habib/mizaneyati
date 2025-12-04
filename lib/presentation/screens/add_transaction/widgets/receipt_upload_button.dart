import 'dart:io';
import 'package:flutter/material.dart';
import '../../../styles/app_colors.dart';
import '../../../styles/app_text_styles.dart';

/// Receipt upload button widget
class ReceiptUploadButton extends StatelessWidget {
  final File? receiptImage;
  final VoidCallback onTap;

  const ReceiptUploadButton({
    super.key,
    this.receiptImage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = receiptImage != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.gray300.withOpacity(0.5),
            style: BorderStyle.solid,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasImage ? Icons.check_circle : Icons.camera_alt_outlined,
              color: hasImage ? AppColors.primaryMain : AppColors.gray600,
            ),
            const SizedBox(width: 8),
            Text(
              hasImage ? 'تم إضافة الصورة' : 'إضافة صورة الإيصال',
              style: AppTextStyles.buttonSmall.copyWith(
                color: hasImage ? AppColors.primaryMain : AppColors.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
