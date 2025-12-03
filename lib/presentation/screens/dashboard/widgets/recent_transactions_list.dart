import 'package:flutter/material.dart';
import '../../../styles/app_colors.dart';
import '../../../styles/app_text_styles.dart';
import '../../../styles/app_spacing.dart';
import '../../../widgets/glassmorphic_container.dart';
import '../../../widgets/transaction_list_item.dart';

/// قائمة المعاملات الأخيرة (Recent Transactions List)
/// تعرض آخر 5 معاملات مع زر "عرض الكل"
class RecentTransactionsList extends StatelessWidget {
  final List<TransactionData> transactions;
  final VoidCallback? onViewAllTap;

  const RecentTransactionsList({
    super.key,
    required this.transactions,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayTransactions = transactions.take(5).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.paddingContainer,
      ),
      child: Column(
        children: [
          // العنوان مع زر "عرض الكل"
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.paddingSm * 1.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('المعاملات الأخيرة', style: AppTextStyles.h3),
                if (onViewAllTap != null)
                  TextButton(
                    onPressed: onViewAllTap,
                    child: Text(
                      'عرض الكل',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // الحاوية الزجاجية
          GlassmorphicContainer(
            padding: const EdgeInsets.all(AppSpacing.paddingMd),
            child: displayTransactions.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(AppSpacing.paddingXl),
                    child: Center(
                      child: Text(
                        'لا توجد معاملات بعد',
                        style: AppTextStyles.bodySecondary,
                      ),
                    ),
                  )
                : Column(
                    children: List.generate(
                      displayTransactions.length,
                      (index) => Padding(
                        padding: EdgeInsets.only(
                          bottom: index < displayTransactions.length - 1
                              ? AppSpacing.paddingSm * 1.5
                              : 0,
                        ),
                        child: TransactionListItem(
                          categoryName: displayTransactions[index].categoryName,
                          categoryColor:
                              displayTransactions[index].categoryColor,
                          categoryIcon: displayTransactions[index].categoryIcon,
                          amount: displayTransactions[index].amount,
                          isExpense: displayTransactions[index].isExpense,
                          note: displayTransactions[index].note,
                          date: displayTransactions[index].date,
                          onTap: displayTransactions[index].onTap,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// بيانات معاملة واحدة
class TransactionData {
  final String categoryName;
  final Color categoryColor;
  final IconData categoryIcon;
  final double amount;
  final bool isExpense;
  final String? note;
  final DateTime? date;
  final VoidCallback? onTap;

  const TransactionData({
    required this.categoryName,
    required this.categoryColor,
    required this.categoryIcon,
    required this.amount,
    this.isExpense = true,
    this.note,
    this.date,
    this.onTap,
  });
}
