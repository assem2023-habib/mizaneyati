import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../../domain/models/account_type.dart';
import '../../../domain/entities/account_entity.dart';
import '../../../domain/value_objects/money.dart';
import '../../../domain/value_objects/color_value.dart';
import '../../../domain/value_objects/account_name.dart';
import '../../../core/utils/result.dart';
import '../../../application/providers/usecases_providers.dart';

class AddAccountDialog extends ConsumerStatefulWidget {
  final AccountEntity? accountToEdit;

  const AddAccountDialog({super.key, this.accountToEdit});

  @override
  ConsumerState<AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends ConsumerState<AddAccountDialog> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  AccountType _selectedType = AccountType.cash;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.accountToEdit != null) {
      _nameController.text = widget.accountToEdit!.name.value;
      _balanceController.text = widget.accountToEdit!.balance.toMajor().toStringAsFixed(2);
      _selectedType = widget.accountToEdit!.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _saveAccount() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال اسم الحساب')),
      );
      return;
    }

    final balance = double.tryParse(_balanceController.text);
    if (balance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال رصيد صحيح')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Convert to minor units (e.g. 10.50 -> 1050)
    final balanceMinor = (balance * 100).round();
    
    final Result result;
    if (widget.accountToEdit != null) {
      result = await ref.read(updateAccountUseCaseProvider).call(
        id: widget.accountToEdit!.id,
        name: _nameController.text,
        balanceMinor: balanceMinor,
        type: _selectedType,
        color: _getColorForType(_selectedType),
      );
    } else {
      result = await ref.read(createAccountUseCaseProvider).call(
        name: _nameController.text,
        balanceMinor: balanceMinor, 
        type: _selectedType,
        color: _getColorForType(_selectedType),
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (result is Success) {
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء إضافة الحساب')),
        );
      }
    }
  }

  String _getColorForType(AccountType type) {
    switch (type) {
      case AccountType.bank:
        return '#2196F3'; // Blue
      case AccountType.card:
        return '#9C27B0'; // Purple
      case AccountType.wallet:
        return '#FF9800'; // Orange
      case AccountType.cash:
      default:
        return '#4CAF50'; // Green
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
              'إضافة حساب جديد',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'اسم الحساب',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance_wallet),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _balanceController,
              decoration: const InputDecoration(
                labelText: 'الرصيد الابتدائي',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            const Text('نوع الحساب:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: AccountType.values.map((type) {
                final isSelected = _selectedType == type;
                return ChoiceChip(
                  label: Text(type.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedType = type);
                  },
                  selectedColor: AppColors.primaryMain,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomButton.primary(
                    text: 'حفظ',
                    onPressed: _saveAccount,
                  ),
          ],
        ),
      ),
    );
  }
}
