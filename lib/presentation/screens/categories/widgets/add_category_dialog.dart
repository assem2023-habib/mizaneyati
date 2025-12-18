import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../../application/providers/usecases_providers.dart';
import '../../../../core/utils/result.dart';
import '../../../../domain/entities/category_entity.dart';
import '../../../../domain/models/category_type.dart';
import '../../../styles/app_colors.dart';
import '../../../styles/app_text_styles.dart';
import '../../../styles/app_spacing.dart';
import '../../../widgets/glassmorphic_container.dart';

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
  late int _selectedIconCode;
  bool _isLoading = false;

  final List<IconData> _availableIcons = [
    Icons.fastfood,
    Icons.shopping_cart,
    Icons.home,
    Icons.directions_car,
    Icons.school,
    Icons.medical_services,
    Icons.card_giftcard,
    Icons.savings,
    Icons.work,
    Icons.attach_money,
    Icons.movie,
    Icons.flight,
    Icons.pets,
    Icons.fitness_center,
    Icons.shopping_bag,
    Icons.restaurant,
    Icons.coffee,
    Icons.local_gas_station,
    Icons.phone_android,
    Icons.wifi,
  ];

  @override
  void initState() {
    super.initState();
    final category = widget.categoryToEdit;
    _nameController = TextEditingController(text: category?.name.value ?? '');
    _selectedType = category?.type ?? CategoryType.expense;
    _selectedColor = category != null
        ? Color(int.parse(category.color.hex.replaceFirst('#', 'FF'), radix: 16))
        : AppColors.primaryMain;
    _selectedIconCode = category != null
        ? (int.tryParse(category.icon.name) ?? _availableIcons.first.codePoint)
        : _availableIcons.first.codePoint;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    final colorHex = '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}';

    Result<dynamic> result;
    if (widget.categoryToEdit == null) {
      result = await ref.read(createCategoryUseCaseProvider).call(
        name: name,
        type: _selectedType,
        icon: _selectedIconCode.toString(),
        color: colorHex,
      );
    } else {
      result = await ref.read(updateCategoryUseCaseProvider).call(
        id: widget.categoryToEdit!.id,
        name: name,
        type: _selectedType,
        icon: _selectedIconCode.toString(),
        color: colorHex,
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (result is Success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ التصنيف بنجاح')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل الحفظ: ${(result as Fail).failure.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSpacing.paddingMd),
      child: GlassmorphicContainer(
        borderRadius: BorderRadius.circular(24),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.paddingLg),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.categoryToEdit == null ? 'إضافة تصنيف' : 'تعديل تصنيف',
                  style: AppTextStyles.h3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.gapLg),

                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'اسم التصنيف',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.5),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: AppSpacing.gapMd),

                // Type
                DropdownButtonFormField<CategoryType>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'نوع التصنيف',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.5),
                  ),
                  items: CategoryType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(
                        type == CategoryType.income ? 'دخل' : 'مصروف',
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedType = val);
                  },
                ),
                const SizedBox(height: AppSpacing.gapMd),

                // Color Picker
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (c) => AlertDialog(
                        content: SingleChildScrollView(
                          child: BlockPicker(
                            pickerColor: _selectedColor,
                            onColorChanged: (color) {
                              setState(() => _selectedColor = color);
                              Navigator.pop(c);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _selectedColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('لون التصنيف'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.gapMd),

                // Icon Picker (Simple Grid)
                Text('أيقونة', style: AppTextStyles.body),
                const SizedBox(height: 8),
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: _availableIcons.length,
                    itemBuilder: (context, index) {
                      final icon = _availableIcons[index];
                      final isSelected = icon.codePoint == _selectedIconCode;
                      return InkWell(
                        onTap: () => setState(() => _selectedIconCode = icon.codePoint),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? _selectedColor.withOpacity(0.2) : null,
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected ? Border.all(color: _selectedColor, width: 2) : null,
                          ),
                          child: Icon(
                            icon,
                            color: isSelected ? _selectedColor : Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.gapLg),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryMain,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(widget.categoryToEdit == null ? 'إضافة' : 'حفظ'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
