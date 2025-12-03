import 'package:flutter/material.dart';
import '../styles/app_colors.dart';
import '../styles/app_spacing.dart';
import '../styles/app_decorations.dart';

/// Floating Action Button مخصص مع تدرج وتوهج
class CustomFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final double size;

  const CustomFAB({
    super.key,
    required this.onPressed,
    this.icon = Icons.add,
    this.size = AppSpacing.fabSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          child: Container(
            decoration: AppDecorations.floatingActionButton,
            child: Icon(icon, color: AppColors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
