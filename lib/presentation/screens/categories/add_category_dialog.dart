import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_text_styles.dart';
import '../../styles/app_spacing.dart';
import '../../widgets/custom_button.dart';

// Domain Imports
import '../../../domain/entities/category_entity.dart';
import '../../../domain/models/category_type.dart';
import '../../../domain/value_objects/category_name.dart';
import '../../../domain/value_objects/icon_value.dart';
import '../../../domain/value_objects/color_value.dart';
import '../../../application/providers/usecases_providers.dart';

class AddCategoryDialog extends ConsumerStatefulWidget {
  final CategoryEntity? categoryToEdit;

  const AddCategoryDialog({super.key, this.categoryToEdit});

  @override
  ConsumerState<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends ConsumerState<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late CategoryType _selectedType;
  late Color _selectedColor;
  late IconData _selectedIcon;

  final List<Color> _colors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  final List<IconData> _icons = [
    Icons.fastfood,
    Icons.restaurant,
    Icons.local_cafe,
    Icons.shopping_cart,
    Icons.shopping_bag,
    Icons.home,
    Icons.cottage,
    Icons.directions_car,
    Icons.directions_bus,
    Icons.flight,
    Icons.medical_services,
    Icons.local_hospital,
    Icons.school,
    Icons.book,
    Icons.sports_esports,
    Icons.sports_soccer,
    Icons.card_giftcard,
    Icons.fitness_center,
    Icons.work,
    Icons.business,
    Icons.attach_money,
    Icons.savings,
    Icons.account_balance_wallet,
    Icons.receipt,
    Icons.category,
    Icons.lightbulb,
    Icons.pets,
    Icons.phone_android,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.categoryToEdit?.name.value ?? '');
    _selectedType = widget.categoryToEdit?.type ?? CategoryType.expense;
    
    if (widget.categoryToEdit != null) {
      final hexString = widget.categoryToEdit!.color.hex.replaceFirst('#', '');
      _selectedColor = Color(int.parse('FF$hexString', radix: 16));
      
      try {
        final codePoint = int.parse(widget.categoryToEdit!.icon.name);
        _selectedIcon = IconData(codePoint, fontFamily: 'MaterialIcons');
      } catch (_) {
        _selectedIcon = _icons.first;
      }
    } else {
      _selectedColor = _colors.first;
      _selectedIcon = _icons.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.paddingMd),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.categoryToEdit == null ? 'إضافة فئة جديدة' : 'تعديل الفئة',
                  style: AppTextStyles.h3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.gapLg),
                
                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم الفئة',
                    prefixIcon: Icon(Icons.label),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال اسم الفئة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.gapMd),

                // Type Selection
                DropdownButtonFormField<CategoryType>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'نوع الفئة',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                  ),
                  items: CategoryType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type == CategoryType.income ? 'دخل' : 'مصروف'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.gapMd),

                // Color Picker
                Text('لون الفئة', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _colors.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final color = _colors[index];
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: _selectedColor == color
                                ? Border.all(color: Colors.black, width: 2)
                                : null,
                          ),
                          child: _selectedColor == color
                              ? const Icon(Icons.check, color: Colors.white, size: 20)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.gapMd),

                // Icon Picker
                Text('أيقونة الفئة', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200, // Limit height for grid
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _icons.length,
                    itemBuilder: (context, index) {
                      final icon = _icons[index];
                      return GestureDetector(
                        onTap: () => setState(() => _selectedIcon = icon),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _selectedIcon == icon
                                ? AppColors.primary.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: _selectedIcon == icon
                                ? Border.all(color: AppColors.primary)
                                : Border.all(color: Colors.grey.shade300),
                          ),
                          child: Icon(
                            icon,
                            color: _selectedIcon == icon
                                ? AppColors.primary
                                : Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.gapLg),

                // Save Button
                CustomButton.primary(
                  text: 'حفظ',
                  onPressed: _saveCategory,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveCategory() async {
    if (_formKey.currentState!.validate()) {
      try {
        final category = CategoryEntity(
          id: widget.categoryToEdit?.id ?? const Uuid().v4(),
          name: CategoryName(_nameController.text),
          icon: IconValue(_selectedIcon.codePoint.toString()),
          color: ColorValue('#${_selectedColor.value.toRadixString(16).substring(2)}'),
          type: _selectedType,
        );

        final result = widget.categoryToEdit == null
            ? await ref.read(createCategoryUseCaseProvider).execute(category)
            : await ref.read(updateCategoryUseCaseProvider).execute(category);

        if (result is Success) {
          if (mounted) {
            Navigator.pop(context, true);
          }
        } else {
          // Show error
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('حدث خطأ أثناء حفظ الفئة')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('حدث خطأ: $e')),
          );
        }
      }
    }
  }
}
