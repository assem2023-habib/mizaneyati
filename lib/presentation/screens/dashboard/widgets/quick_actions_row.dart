import 'package:flutter/material.dart';
import '../../../styles/app_spacing.dart';
import '../../../widgets/quick_action_button.dart';

/// صف الأزرار السريعة (Quick Actions Row)
/// يحتوي على 3 أزرار: مصروف، دخل، تحويل
class QuickActionsRow extends StatelessWidget {
  final VoidCallback onExpenseTap;
  final VoidCallback onIncomeTap;
  final VoidCallback onTransferTap;

  const QuickActionsRow({
    super.key,
    required this.onExpenseTap,
    required this.onIncomeTap,
    required this.onTransferTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.paddingContainer,
        vertical: AppSpacing.paddingLg,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          QuickActionButton.expense(onPressed: onExpenseTap),
          QuickActionButton.income(onPressed: onIncomeTap),
          QuickActionButton.transfer(onPressed: onTransferTap),
        ],
      ),
    );
  }
}
