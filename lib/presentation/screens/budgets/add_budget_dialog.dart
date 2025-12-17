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

    final result = await ref.read(createBudgetUseCaseProvider).call(
      limitAmountMinor: amountMinor,
      categoryId: _selectedCategoryId!,
      startDate: startDate,
      endDate: endDate,
    );

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

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'اختر الشهر',
      // This is a standard date picker, not a month picker, but it works for picking a date within a month.
      // We'll use the month of the picked date.
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'إضافة ميزانية جديدة',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category.id,
                  child: Text(category.name.value),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedCategoryId = value),
              decoration: const InputDecoration(
                labelText: 'الفئة',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
            ),
            const SizedBox(height: 16),
            
            // Amount Field
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'الحد الأقصى (ل.س)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            // Month Picker
            InkWell(
              onTap: _pickMonth,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'الشهر',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  '${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomButton.primary(
                    text: 'حفظ',
                    onPressed: _saveBudget,
                  ),
          ],
        ),
      ),
    );
  }
}
