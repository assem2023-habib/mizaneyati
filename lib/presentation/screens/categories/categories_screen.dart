import 'package:flutter/material.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_text_styles.dart';
import '../../styles/app_spacing.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/custom_button.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for categories
    final List<Map<String, dynamic>> categories = [
      {
        'name': 'طعام',
        'icon': Icons.restaurant,
        'color': AppColors.categoryFood,
      },
      {
        'name': 'مواصلات',
        'icon': Icons.directions_car,
        'color': AppColors.categoryTransport,
      },
      {
        'name': 'تسوق',
        'icon': Icons.shopping_bag,
        'color': AppColors.categoryShopping,
      },
      {
        'name': 'ترفيه',
        'icon': Icons.movie,
        'color': AppColors.categoryEntertainment,
      },
      {
        'name': 'صحة',
        'icon': Icons.favorite,
        'color': AppColors.categoryHealth,
      },
      {
        'name': 'راتب',
        'icon': Icons.attach_money,
        'color': AppColors.categorySalary,
      },
      {
        'name': 'فواتير',
        'icon': Icons.receipt,
        'color': AppColors.categoryBills,
      },
      {
        'name': 'تعليم',
        'icon': Icons.school,
        'color': AppColors.categoryEducation,
      },
      {
        'name': 'أخرى',
        'icon': Icons.more_horiz,
        'color': AppColors.categoryOther,
      },
    ];

    return Scaffold(
      body: GradientBackground.dashboard(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(AppSpacing.paddingMd),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: AppSpacing.gapMd,
                    mainAxisSpacing: AppSpacing.gapMd,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _buildCategoryCard(category);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.paddingMd),
                child: CustomButton.primary(
                  text: 'إضافة فئة جديدة',
                  icon: Icons.add,
                  onPressed: () {
                    // TODO: Show add category dialog
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.paddingMd),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text('الفئات', style: AppTextStyles.h2),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    final color = category['color'] as Color;
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(category['icon'], color: Colors.white, size: 32),
          const SizedBox(height: 8),
          Text(
            category['name'],
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
