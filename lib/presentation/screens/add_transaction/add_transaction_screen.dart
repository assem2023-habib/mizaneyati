import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/gradient_background.dart';

// Widget Imports
import 'widgets/widgets.dart';

// Domain Imports
import '../../../domain/entities/account_entity.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/models/transaction_type.dart';
import '../../../core/utils/result.dart';
import '../../../application/providers/usecases_providers.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  bool _isExpense = true;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _selectedCategoryId;
  String? _selectedAccountId;
  DateTime _selectedDate = DateTime.now();
  File? _receiptImage;

  List<CategoryEntity> _categories = [];
  List<AccountEntity> _accounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final categoriesResult = await ref
        .read(getCategoriesUseCaseProvider)
        .execute();
    final accountsResult = await ref.read(getAccountsUseCaseProvider).execute();

    if (mounted) {
      setState(() {
        if (categoriesResult is Success) {
          _categories =
              (categoriesResult as Success<List<CategoryEntity>>).value;
        }
        if (accountsResult is Success) {
          _accounts = (accountsResult as Success<List<AccountEntity>>).value;
        }
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _receiptImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryDark,
              onPrimary: Colors.white,
              onSurface: AppColors.gray800,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('الرجاء إدخال المبلغ')));
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('الرجاء اختيار الفئة')));
      return;
    }

    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('الرجاء اختيار الحساب')));
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('المبلغ غير صالح')));
      return;
    }

    // Convert to minor units (e.g., cents/piasters)
    final amountMinor = (amount).round();

    final type = _isExpense ? TransactionType.expense : TransactionType.income;

    final result = await ref
        .read(addTransactionUseCaseProvider)
        .call(
          amountMinor: amountMinor,
          type: type,
          categoryId: _selectedCategoryId!,
          accountId: _selectedAccountId!,
          date: _selectedDate,
          note: _notesController.text.isNotEmpty ? _notesController.text : null,
          receiptPath: _receiptImage?.path,
        );

    if (mounted) {
      if (result is Success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ المعاملة بنجاح'),
            backgroundColor: AppColors.primaryMain,
          ),
        );
        Navigator.pop(context);
      } else {
        final failure = (result as Fail).failure;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${failure.message}'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: GradientBackground(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.white, AppColors.backgroundLighter],
        ),
        child: SafeArea(
          child: Column(
            children: [
              const AddTransactionHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TransactionTypeToggle(
                        isExpense: _isExpense,
                        onChanged: (value) =>
                            setState(() => _isExpense = value),
                      ),
                      const SizedBox(height: 24),
                      AmountInputField(controller: _amountController),
                      const SizedBox(height: 24),
                      _buildCategoryDropdown(),
                      const SizedBox(height: 16),
                      _buildAccountDropdown(),
                      const SizedBox(height: 16),
                      DatePickerField(
                        selectedDate: _selectedDate,
                        onTap: () => _selectDate(context),
                      ),
                      const SizedBox(height: 16),
                      NotesInputField(controller: _notesController),
                      const SizedBox(height: 16),
                      ReceiptUploadButton(
                        receiptImage: _receiptImage,
                        onTap: _pickImage,
                      ),
                      const SizedBox(height: 32),
                      CustomButton.primary(
                        text: 'حفظ المعاملة',
                        onPressed: _saveTransaction,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return StyledDropdownField<String>(
      value: _selectedCategoryId,
      hintText: 'الفئة',
      hintIcon: Icons.category_outlined,
      items: _categories.map((category) {
        return DropdownMenuItem<String>(
          value: category.id,
          child: Text(category.name.value, style: AppTextStyles.body),
        );
      }).toList(),
      onChanged: (val) => setState(() => _selectedCategoryId = val),
    );
  }

  Widget _buildAccountDropdown() {
    return StyledDropdownField<String>(
      value: _selectedAccountId,
      hintText: 'الحساب',
      hintIcon: Icons.account_balance_wallet_outlined,
      items: _accounts.map((account) {
        return DropdownMenuItem<String>(
          value: account.id,
          child: Text(account.name.value, style: AppTextStyles.body),
        );
      }).toList(),
      onChanged: (val) => setState(() => _selectedAccountId = val),
    );
  }
}
