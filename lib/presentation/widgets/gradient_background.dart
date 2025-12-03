import 'package:flutter/material.dart';
import '../styles/app_colors.dart';
import '../styles/app_spacing.dart';

/// خلفية متدرجة مع دوائر ضبابية اختيارية
/// تُستخدم في: Dashboard، Onboarding
class GradientBackground extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final bool showBlurryCircles;
  final List<BlurryCircle>? customCircles;

  const GradientBackground({
    super.key,
    required this.child,
    this.gradient = AppColors.backgroundGradient,
    this.showBlurryCircles = false,
    this.customCircles,
  });

  /// خلفية Dashboard مع دوائر ضبابية
  factory GradientBackground.dashboard({required Widget child}) {
    return GradientBackground(
      gradient: AppColors.backgroundGradient,
      showBlurryCircles: true,
      customCircles: const [
        // دائرة 1 - أعلى يمين (بيضاء)
        BlurryCircle(
          size: 300,
          color: AppColors.blurryCircleWhite,
          opacity: 0.3,
          top: 0.1,
          right: 0.05,
          blurRadius: 60,
        ),
        // دائرة 2 - وسط يسار (خضراء نعناعية)
        BlurryCircle(
          size: 250,
          color: AppColors.blurryCircleMint,
          opacity: 0.3,
          top: 0.3,
          left: 0.1,
          blurRadius: 50,
        ),
        // دائرة 3 - أسفل يمين (زرقاء سماوية)
        BlurryCircle(
          size: 200,
          color: AppColors.blurryCircleBlue,
          opacity: 0.3,
          bottom: 0.2,
          right: 0.2,
          blurRadius: 40,
        ),
        // دائرة 4 - وسط يسار سفلي (بيضاء خفيفة)
        BlurryCircle(
          size: 150,
          color: Color(0xE6FFFFFF),
          opacity: 0.2,
          top: 0.6,
          left: 0.05,
          blurRadius: 35,
        ),
      ],
      child: child,
    );
  }

  /// خلفية Onboarding (بدون دوائر)
  factory GradientBackground.onboarding({required Widget child}) {
    return GradientBackground(
      gradient: AppColors.onboardingGradient,
      showBlurryCircles: false,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: Stack(
        children: [
          // الدوائر الضبابية (إذا كانت مفعلة)
          if (showBlurryCircles) ..._buildBlurryCircles(context),
          // المحتوى
          child,
        ],
      ),
    );
  }

  List<Widget> _buildBlurryCircles(BuildContext context) {
    final circles = customCircles ?? [];
    return circles
        .map(
          (circle) => Positioned(
            top: circle.top != null
                ? MediaQuery.of(context).size.height * circle.top!
                : null,
            bottom: circle.bottom != null
                ? MediaQuery.of(context).size.height * circle.bottom!
                : null,
            left: circle.left != null
                ? MediaQuery.of(context).size.width * circle.left!
                : null,
            right: circle.right != null
                ? MediaQuery.of(context).size.width * circle.right!
                : null,
            child: Container(
              width: circle.size,
              height: circle.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    circle.color.withOpacity(circle.opacity),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),
        )
        .toList();
  }
}

/// تعريف دائرة ضبابية
class BlurryCircle {
  final double size;
  final Color color;
  final double opacity;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double blurRadius;

  const BlurryCircle({
    required this.size,
    required this.color,
    this.opacity = 0.3,
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.blurRadius = 60,
  });
}
