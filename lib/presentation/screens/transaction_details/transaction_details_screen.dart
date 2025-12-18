import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../add_transaction/add_transaction_screen.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_text_styles.dart';
import '../../styles/app_spacing.dart';

// Domain Imports
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/account_entity.dart';
import '../../../domain/models/transaction_type.dart';
import '../../../core/utils/result.dart';
import '../../../application/providers/usecases_providers.dart';

/// شاشة تفاصيل المعاملة
/// التصميم مبني على SCREENS_DOCUMENTATION.md
class TransactionDetailsScreen extends ConsumerStatefulWidget {
  final String transactionId;

  const TransactionDetailsScreen({super.key, required this.transactionId});

  @override
  ConsumerState<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState
    extends ConsumerState<TransactionDetailsScreen> {
  TransactionEntity? _transaction;
  CategoryEntity? _category;
  AccountEntity? _account;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactionDetails();
  }

  Future<void> _loadTransactionDetails() async {
    final result = await ref.read(getTransactionsUseCaseProvider).execute();

    if (result is Success<List<TransactionEntity>>) {
      try {
        final transaction = result.value.firstWhere(
          (t) => t.id == widget.transactionId,
          orElse: () => throw Exception('Transaction not found'),
        );
        setState(() {
          _transaction = transaction;
        });

        // Load Category
        final categoryResult = await ref
            .read(getCategoryByIdUseCaseProvider)
            .call(_transaction!.categoryId);
        
        if (categoryResult is Success) {
          setState(() {
            _category = (categoryResult as Success).value;
          });
        }

        // Load Account
        final accountResult = await ref
            .read(getAccountByIdUseCaseProvider)
            .call(_transaction!.accountId);
        
        if (accountResult is Success) {
          setState(() {
            _account = (accountResult as Success).value;
          });
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_transaction == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.gray400),
              const SizedBox(height: 16),
              Text('المعاملة غير موجودة', style: AppTextStyles.bodySecondary),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('العودة'),
              ),
            ],
          ),
        ),
      );
    }

    final isExpense = _transaction!.type == TransactionType.expense;
    final amountColor = isExpense ? AppColors.expense : AppColors.income;
    final amountPrefix = isExpense ? '-' : '+';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.paddingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // زر الرجوع والعنوان
                _buildHeader(context),
                const SizedBox(height: AppSpacing.gapLg),

                // البطاقة الرئيسية
                _buildMainCard(amountColor, amountPrefix),
                const SizedBox(height: AppSpacing.gapMd),

                // أزرار الإجراءات
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// بناء الهيدر (زر الرجوع + العنوان)
  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4B5563)),
          label: Text(
            'رجوع',
            style: AppTextStyles.body.copyWith(color: const Color(0xFF4B5563)),
          ),
        ),
        const SizedBox(height: AppSpacing.gapSm),
        Center(child: Text('تفاصيل المعاملة', style: AppTextStyles.h1)),
      ],
    );
  }

  /// بناء البطاقة الرئيسية
  Widget _buildMainCard(Color amountColor, String amountPrefix) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: AppColors.cardGradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // المبلغ (Hero)
          _buildAmountSection(amountColor, amountPrefix),
          const SizedBox(height: 32),

          // صفوف التفاصيل
          _buildDetailsSection(),

          // صورة الإيصال (إن وجدت)
          if (_transaction!.receiptPath != null) ...[
            const SizedBox(height: 16),
            _buildReceiptSection(),
          ],
        ],
      ),
    );
  }

  /// قسم المبلغ
  Widget _buildAmountSection(Color amountColor, String amountPrefix) {
    return Column(
      children: [
        Text(
          'المبلغ',
          style: AppTextStyles.bodySecondary.copyWith(
            color: const Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$amountPrefix${_transaction!.amount.toMajor().toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: amountColor,
          ),
        ),
        Text(
          'ل.س',
          style: AppTextStyles.bodySecondary.copyWith(color: AppColors.gray500),
        ),
      ],
    );
  }

  /// قسم التفاصيل
  Widget _buildDetailsSection() {
    return Column(
      children: [
        // الفئة
        _buildDetailRow(
          icon: Icons.label_outline,
          label: 'الفئة',
          value: _category?.name.value ?? 'غير معروف',
        ),
        const SizedBox(height: 12),

        // الحساب
        _buildDetailRow(
          icon: Icons.account_balance_wallet_outlined,
          label: 'الحساب',
          value: _account?.name.value ?? 'غير معروف',
        ),
        const SizedBox(height: 12),

        // التاريخ
        _buildDetailRow(
          icon: Icons.calendar_today_outlined,
          label: 'التاريخ',
          value: _formatDate(_transaction!.date.value),
        ),

        // الملاحظات (إن وجدت)
        if (_transaction!.note.value?.isNotEmpty ?? false) ...[
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.notes_outlined,
            label: 'ملاحظات',
            value: _transaction!.note.value ?? '',
          ),
        ],
      ],
    );
  }

  /// صف تفاصيل واحد
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryDark),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gray500,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.body.copyWith(color: AppColors.gray800),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// قسم صورة الإيصال
  Widget _buildReceiptSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_outlined,
                size: 20,
                color: AppColors.primaryDark,
              ),
              const SizedBox(width: 16),
              Text(
                'صورة الإيصال',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gray500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(
              File(_transaction!.receiptPath!),
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 100,
                  color: AppColors.gray50,
                  child: Center(
                    child: Text(
                      'لا يمكن عرض الصورة',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.gray400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// أزرار الإجراءات (تعديل وحذف)
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // زر التعديل
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.balance.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: فتح شاشة التعديل
              },
              icon: const Icon(Icons.edit_outlined, color: Colors.white),
              label: Text('تعديل', style: AppTextStyles.button),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.balance,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // زر الحذف
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.expense.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => _showDeleteConfirmation(context),
              icon: const Icon(Icons.delete_outlined, color: Colors.white),
              label: Text('حذف', style: AppTextStyles.button),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.expense,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// حوار تأكيد الحذف
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المعاملة'),
        content: const Text('هل أنت متأكد من حذف هذه المعاملة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // إغلاق الحوار
              await _deleteTransaction();
            },
            child: Text('حذف', style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );
  }

  /// حذف المعاملة
  Future<void> _deleteTransaction() async {
    final result = await ref
        .read(deleteTransactionUseCaseProvider)
        .call(_transaction!.id);

    if (mounted) {
      if (result is Success) {
        Navigator.pop(context); // العودة للقائمة
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم حذف المعاملة بنجاح')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('حدث خطأ أثناء الحذف')));
      }
    }
  }

  /// تنسيق التاريخ
  String _formatDate(DateTime date) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
