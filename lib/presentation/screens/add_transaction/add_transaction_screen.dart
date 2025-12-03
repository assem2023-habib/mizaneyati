import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' as intl;
import '../../styles/app_colors.dart';
import '../../styles/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/gradient_background.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  bool _isExpense = true;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String? _selectedCategory;
  String? _selectedAccount;
  DateTime _selectedDate = DateTime.now();
  File? _receiptImage;

  final List<String> _categories = [
    'طعام',
    'مواصلات',
    'تسوق',
    'ترفيه',
    'صحة',
    'راتب',
    'فواتير',
    'تعليم',
    'أخرى',
  ];

  final List<String> _accounts = ['نقدي', 'بنك', 'بطاقة ائتمان'];

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
            colorScheme: ColorScheme.light(
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

  @override
  Widget build(BuildContext context) {
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
                      _buildDropdownField(
                        label: 'الفئة',
                        value: _selectedCategory,
                        items: _categories,
                        onChanged: (val) =>
                            setState(() => _selectedCategory = val),
                        icon: Icons.category_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField(
                        label: 'الحساب',
                        value: _selectedAccount,
                        items: _accounts,
                        onChanged: (val) =>
                            setState(() => _selectedAccount = val),
                        icon: Icons.account_balance_wallet_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildDatePicker(),
                      const SizedBox(height: 16),
                      _buildNotesInput(),
                      const SizedBox(height: 16),
                      _buildReceiptUpload(),
                      const SizedBox(height: 32),
                      CustomButton.primary(
                        text: 'حفظ المعاملة',
                        onPressed: () {
                          // TODO: Implement save logic
                          Navigator.pop(context);
                        },
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

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray300.withOpacity(0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Row(
            children: [
              Icon(icon, color: AppColors.gray400, size: 20),
              const SizedBox(width: 12),
              Text(label, style: AppTextStyles.bodySecondary),
            ],
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.gray600),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: AppTextStyles.body),
            );
          }).toList(),
          onChanged: onChanged,
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
