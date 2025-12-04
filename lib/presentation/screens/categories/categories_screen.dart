import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_text_styles.dart';
import '../../styles/app_spacing.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/custom_button.dart';

// Domain Imports
import '../../../domain/entities/category_entity.dart';
import '../../../core/utils/result.dart';
import '../../../application/providers/usecases_providers.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  List<CategoryEntity> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);

    final result = await ref.read(getCategoriesUseCaseProvider).execute();

    if (mounted) {
      setState(() {
        if (result is Success) {
          _categories = (result as Success<List<CategoryEntity>>).value;
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: GradientBackground.dashboard(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _categories.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد فئات',
                          style: AppTextStyles.bodySecondary,
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(AppSpacing.paddingMd),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: AppSpacing.gapMd,
                              mainAxisSpacing: AppSpacing.gapMd,
                              childAspectRatio: 1.0,
                            ),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
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

  Widget _buildCategoryCard(CategoryEntity category) {
    // Convert hex color to Flutter Color
    final hexString = category.color.hex.replaceFirst('#', '');
    final color = Color(int.parse('FF$hexString', radix: 16));
    // For icon, we use a default since IconValue may need a mapper
    // In a real app, you'd map IconValue.value to IconData
    const icon = Icons.category;

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
          const Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 8),
          Text(
            category.name.value,
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
