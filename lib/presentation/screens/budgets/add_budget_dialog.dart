import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../../domain/entities/budget_entity.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/value_objects/money.dart';
import '../../../domain/value_objects/date_value.dart';
import '../../../core/utils/result.dart';
import '../../../application/providers/usecases_providers.dart';
import '../../../widgets/glassmorphic_container.dart';

class AddBudgetDialog extends ConsumerStatefulWidget {
  final BudgetEntity? budgetToEdit;

  const AddBudgetDialog({super.key, this.budgetToEdit});

  @override
  ConsumerState<AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends ConsumerState<AddBudgetDialog> {
  late TextEditingController _amountController;
  String? _selectedCategoryId;
  List<CategoryEntity> _categories = [];
  bool _isLoading = false;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.budgetToEdit != null
          ? widget.budgetToEdit!.limitAmount.toMajor().toStringAsFixed(0)
          : '',
    );
    _selectedCategoryId = widget.budgetToEdit?.categoryId;
    _selectedDate = widget.budgetToEdit?.startDate.value ?? DateTime.now();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final result = await ref.read(getCategoriesUseCaseProvider).execute();
    if (mounted && result is Success) {
      setState(() {
        _categories = (result as Success<List<CategoryEntity>>).value;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveBudget() async {
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار الفئة')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال مبلغ صحيح')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final amountMinor = (amount * 100).round();
    
    // Calculate start and end of selected month
    final startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final endDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 0, 23, 59, 59);

    Result<dynamic> result;
    if (widget.budgetToEdit == null) {
      result = await ref.read(createBudgetUseCaseProvider).call(
        limitAmountMinor: amountMinor,
        categoryId: _selectedCategoryId!,
        startDate: startDate,
        endDate: endDate,
      );
    } else {
      // Need to create a BudgetEntity for update
      // Assuming UpdateBudgetUseCase takes a BudgetEntity
      final updatedBudget = widget.budgetToEdit!.copyWith(
        limitAmount: (Money.create(amountMinor) as Success<Money>).value,
        categoryId: _selectedCategoryId,
        // Start/End date update logic if needed, but usually budget period is fixed or needs careful handling
        // For now we keep the original dates or update if logic allows
        // Here we use the potentially updated start/end dates
        startDate: (DateValue.create(startDate) as Success<DateValue>).value,
        endDate: (DateValue.create(endDate) as Success<DateValue>).value,
      );
      
      result = await ref.read(updateBudgetUseCaseProvider).execute(updatedBudget);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (result is Success) {
        Navigator.pop(context, true);
      } else {
        // Handle failure (e.g. overlap)
        final failure = (result as Fail).failure;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: ${failure.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassmorphicContainer(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.budgetToEdit == null ? 'إضافة ميزانية' : 'تعديل الميزانية',
                style: AppTextStyles.h3.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                dropdownColor: AppColors.surface,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'الفئة',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name.value),
                  );
                }).toList(),
                onChanged: widget.budgetToEdit == null 
                    ? (value) => setState(() => _selectedCategoryId = value)
                    : null, // Prevent changing category on edit if desired, or allow it
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'الحد الشهري (ل.س)',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('إلغاء', style: TextStyle(color: Colors.white70)),
                      ),
                    ),
                    Expanded(
                      child: CustomButton(
                        text: 'حفظ',
                        onPressed: _saveBudget,
                        backgroundColor: AppColors.primaryMain,
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
