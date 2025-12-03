import 'package:flutter/material.dart';
import '../widgets/gradient_background.dart';
import '../widgets/custom_button.dart';
import '../widgets/page_indicators.dart';
import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';
import '../styles/app_spacing.dart';

/// شاشة Onboarding - الترحيب الأولى
/// التصميم مبني على المواصفات الكاملة من SCREENS_DOCUMENTATION.md
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // محتوى صفحات الـ Onboarding
  final List<OnboardingContent> _pages = const [
    OnboardingContent(
      image: 'assets/images/onboarding_1.png', // يجب إضافة الصورة لاحقاً
      title: 'إدارة مصاريفك بسهولة',
      description: 'تتبع مصاريفك اليومية والشهرية بدقة',
    ),
    OnboardingContent(
      image: 'assets/images/onboarding_2.png',
      title: 'تحكم كامل بميزانيتك',
      description: 'راقب دخلك ومصروفاتك في مكان واحد',
    ),
    OnboardingContent(
      image: 'assets/images/onboarding_3.png',
      title: 'تقارير وإحصائيات مفصلة',
      description: 'احصل على رؤية واضحة لوضعك المالي',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _onStart() {
    // الانتقال إلى شاشة Dashboard
    Navigator.of(context).pushReplacementNamed('/dashboard');
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _onStart();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground.onboarding(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.paddingXl),
            child: Column(
              children: [
                // المحتوى الرئيسي (يأخذ معظم المساحة)
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _OnboardingPage(content: _pages[index]);
                    },
                  ),
                ),

                // مؤشرات الصفحات
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.marginLg),
                  child: PageIndicators(
                    currentPage: _currentPage,
                    totalPages: _pages.length,
                  ),
                ),

                // زر البدء/التالي
                SizedBox(
                  width: AppSpacing.maxWidthButton,
                  child: CustomButton.primary(
                    text: _currentPage == _pages.length - 1
                        ? 'ابدأ الآن'
                        : 'التالي',
                    onPressed: _onNext,
                  ),
                ),
                const SizedBox(height: AppSpacing.marginLg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// صفحة واحدة من Onboarding
class _OnboardingPage extends StatelessWidget {
  final OnboardingContent content;

  const _OnboardingPage({required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // الصورة التوضيحية
        Container(
          width: AppSpacing.onboardingImageWidth,
          height: AppSpacing.onboardingImageHeight,
          margin: const EdgeInsets.only(bottom: AppSpacing.marginXl),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          ),
          child: content.image.isNotEmpty
              ? Image.asset(
                  content.image,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // في حالة عدم وجود الصورة، عرض أيقونة placeholder
                    return Icon(
                      Icons.account_balance_wallet,
                      size: 120,
                      color: AppColors.primaryDark.withOpacity(0.5),
                    );
                  },
                )
              : Icon(
                  Icons.account_balance_wallet,
                  size: 120,
                  color: AppColors.primaryDark.withOpacity(0.5),
                ),
        ),

        // العنوان الرئيسي
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.marginMd),
          child: Text(
            content.title,
            style: AppTextStyles.h1,
            textAlign: TextAlign.center,
          ),
        ),

        // النص التوضيحي
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.paddingMd),
          child: Text(
            content.description,
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

/// محتوى صفحة Onboarding
class OnboardingContent {
  final String image;
  final String title;
  final String description;

  const OnboardingContent({
    required this.image,
    required this.title,
    required this.description,
  });
}
