import 'package:flutter/material.dart';
import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';
import '../styles/app_decorations.dart';

/// زر مخصص مع أنماط متعددة
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final IconData? icon;
  final double? iconSize;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.width,
    this.height,
    this.padding,
    this.textStyle,
    this.icon,
    this.iconSize,
  });

  /// زر أساسي (Primary)
  factory CustomButton.primary({
    required String text,
    VoidCallback? onPressed,
    double? width,
    IconData? icon,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.primary,
      width: width,
      icon: icon,
    );
  }

  /// زر ثانوي (Secondary)
  factory CustomButton.secondary({
    required String text,
    VoidCallback? onPressed,
    double? width,
    IconData? icon,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.secondary,
      width: width,
      icon: icon,
    );
  }

  /// زر نصي (Text)
  factory CustomButton.text({
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.text,
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: _getDecoration(),
            child: Container(
              padding:
                  padding ??
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: _getTextColor(), size: iconSize ?? 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: (textStyle ?? _getDefaultTextStyle()).copyWith(
                      color: _getTextColor(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _getDecoration() {
    switch (variant) {
      case ButtonVariant.primary:
        return AppDecorations.primaryButton;
      case ButtonVariant.secondary:
        return BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryDark, width: 2),
        );
      case ButtonVariant.text:
        return const BoxDecoration();
    }
  }

  Color _getTextColor() {
    switch (variant) {
      case ButtonVariant.primary:
        return AppColors.white;
      case ButtonVariant.secondary:
        return AppColors.primaryDark;
      case ButtonVariant.text:
        return AppColors.primaryDark;
    }
  }

  TextStyle _getDefaultTextStyle() {
    return AppTextStyles.button;
  }
}

/// أنواع الأزرار
enum ButtonVariant { primary, secondary, text }
