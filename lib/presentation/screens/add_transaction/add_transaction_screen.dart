import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' as intl;
import '../../styles/app_colors.dart';
import '../../styles/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/gradient_background.dart';

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
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTypeToggle(),
                      const SizedBox(height: 24),
                      _buildAmountInput(),
                      const SizedBox(height: 24),
                      _buildCategoryDropdown(),
                      const SizedBox(height: 16),
                      _buildAccountDropdown(),
                      const SizedBox(height: 16),
                      _buildDatePicker(),
                      const SizedBox(height: 16),
                      _buildNotesInput(),
                      const SizedBox(height: 16),
                      _buildReceiptUpload(),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: AppTextStyles.buttonSmall.copyWith(
                color: AppColors.gray600,
              ),
            ),
          ),
          Text('إضافة معاملة', style: AppTextStyles.h3),
          const SizedBox(width: 48), // Spacer to balance the "Cancel" button
        ],
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isExpense = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isExpense ? AppColors.expense : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  'مصروف',
                  style: AppTextStyles.button.copyWith(
                    color: _isExpense ? Colors.white : AppColors.gray600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isExpense = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isExpense ? AppColors.income : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  'دخل',
                  style: AppTextStyles.button.copyWith(
                    color: !_isExpense ? Colors.white : AppColors.gray600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF5F5F5)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text('المبلغ', style: AppTextStyles.bodySmall),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: AppTextStyles.balanceAmount.copyWith(fontSize: 32),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '0',
              hintStyle: AppTextStyles.balanceAmount.copyWith(
                fontSize: 32,
                color: AppColors.gray300,
              ),
              suffixText: ' ل.س',
              suffixStyle: AppTextStyles.h3.copyWith(color: AppColors.gray500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray300.withOpacity(0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategoryId,
          hint: Row(
            children: [
              const Icon(
                Icons.category_outlined,
                color: AppColors.gray400,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text('الفئة', style: AppTextStyles.bodySecondary),
            ],
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.gray600),
          items: _categories.map((category) {
            return DropdownMenuItem<String>(
              value: category.id,
              child: Text(category.name.value, style: AppTextStyles.body),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedCategoryId = val),
        ),
      ),
    );
  }

  Widget _buildAccountDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray300.withOpacity(0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedAccountId,
          hint: Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.gray400,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text('الحساب', style: AppTextStyles.bodySecondary),
            ],
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.gray600),
          items: _accounts.map((account) {
            return DropdownMenuItem<String>(
              value: account.id,
              child: Text(account.name.value, style: AppTextStyles.body),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedAccountId = val),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gray300.withOpacity(0.5)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.gray400,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              intl.DateFormat('yyyy-MM-dd').format(_selectedDate),
              style: AppTextStyles.body,
            ),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down, color: AppColors.gray600),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray300.withOpacity(0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: _notesController,
        maxLines: 3,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'ملاحظات...',
          hintStyle: AppTextStyles.bodySecondary,
          icon: const Icon(Icons.notes, color: AppColors.gray400, size: 20),
        ),
        style: AppTextStyles.body,
      ),
    );
  }

  Widget _buildReceiptUpload() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.gray300.withOpacity(0.5),
            style: BorderStyle.solid,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _receiptImage != null
                  ? Icons.check_circle
                  : Icons.camera_alt_outlined,
              color: _receiptImage != null
                  ? AppColors.primaryMain
                  : AppColors.gray600,
            ),
            const SizedBox(width: 8),
            Text(
              _receiptImage != null ? 'تم إضافة الصورة' : 'إضافة صورة الإيصال',
              style: AppTextStyles.buttonSmall.copyWith(
                color: _receiptImage != null
                    ? AppColors.primaryMain
                    : AppColors.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
