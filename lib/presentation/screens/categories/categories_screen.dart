import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_text_styles.dart';
import '../../styles/app_spacing.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/custom_button.dart';
import 'widgets/add_category_dialog.dart';

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
                  onPressed: () async {
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (context) => const AddCategoryDialog(),
                    );
                    if (result == true) {
                      _loadCategories();
                    }
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

  void _showCategoryOptions(CategoryEntity category) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: AppColors.primaryMain),
                title: const Text('تعديل'),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (context) => AddCategoryDialog(categoryToEdit: category),
                  );
                  if (result == true) {
                    _loadCategories();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.expense),
                title: const Text('حذف'),
                onTap: () async {
                  Navigator.pop(context);
                  _confirmDelete(category);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(CategoryEntity category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف فئة "${category.name.value}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await ref.read(deleteCategoryUseCaseProvider).call(category.id);
      if (result is Success) {
        _loadCategories();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف الفئة بنجاح')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('فشل حذف الفئة (قد تكون مرتبطة بمعاملات)')),
          );
        }
      }
    }
  }

  Widget _buildCategoryCard(CategoryEntity category) {
    // Convert hex color to Flutter Color
    final hexString = category.color.hex.replaceFirst('#', '');
    final color = Color(int.parse('FF$hexString', radix: 16));
    
    IconData icon;
    try {
      final codePoint = int.parse(category.icon.name);
      icon = IconData(codePoint, fontFamily: 'MaterialIcons');
    } catch (e) {
      icon = Icons.category;
    }

    return GestureDetector(
      onTap: () => _showCategoryOptions(category),
      child: Container(
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
            Icon(icon, color: Colors.white, size: 32),
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
      ),
    );
  }
}
