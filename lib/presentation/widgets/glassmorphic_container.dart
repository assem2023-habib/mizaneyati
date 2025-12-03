import 'dart:ui';
import 'package:flutter/material.dart';
import '../styles/app_colors.dart';
import '../styles/app_spacing.dart';

/// حاوية بتأثير Glassmorphism (زجاجي شفاف)
/// يُستخدم في: الهيدر، الأزرار السريعة، قائمة المعاملات، شريط التنقل
class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double blurStrength;
  final Color? backgroundColor;
  final double backgroundOpacity;
  final Color? borderColor;
  final double borderOpacity;
  final List<BoxShadow>? boxShadow;
  final Border? border;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blurStrength = 16.0,
    this.backgroundColor,
    this.backgroundOpacity = 0.5,
    this.borderColor,
    this.borderOpacity = 0.7,
    this.boxShadow,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(AppSpacing.radiusXl);
    final effectiveBackgroundColor =
        backgroundColor ?? AppColors.white.withOpacity(backgroundOpacity);
    final effectiveBorderColor =
        borderColor ?? AppColors.white.withOpacity(borderOpacity);

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurStrength, sigmaY: blurStrength),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: effectiveBackgroundColor,
              borderRadius: effectiveBorderRadius,
              border:
                  border ?? Border.all(color: effectiveBorderColor, width: 1),
              boxShadow:
                  boxShadow ??
                  [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: AppSpacing.shadowSm,
                      offset: const Offset(0, 8),
                    ),
                  ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
