import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';
import '../styles/app_spacing.dart';
import '../../core/constants/app_constants.dart';

/// عنصر معاملة واحدة في القائمة
class TransactionListItem extends StatelessWidget {
  final String categoryName;
  final Color categoryColor;
  final IconData categoryIcon;
  final double amount;
  final bool isExpense;
  final String? note;
  final DateTime? date;
  final VoidCallback? onTap;
  final String currency;

  const TransactionListItem({
    super.key,
    required this.categoryName,
    required this.categoryColor,
    required this.categoryIcon,
    required this.amount,
    this.isExpense = true,
    this.note,
    this.date,
    this.onTap,
    this.currency = AppConstants.defaultCurrencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.paddingSm * 1.5),
          child: Row(
            children: [
              // أيقونة الفئة (دائرة مزدوجة)
              _CategoryIcon(color: categoryColor, icon: categoryIcon),
              const SizedBox(width: AppSpacing.gapMd),

              // معلومات المعاملة
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName,
                      style: AppTextStyles.transactionCategory,
                    ),
                    if (note != null || date != null) const SizedBox(height: 2),
                    if (note != null || date != null)
                      Text(
                        note ?? _formatDate(date!),
                        style: AppTextStyles.transactionMeta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              // المبلغ
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${isExpense ? '-' : '+'}${NumberFormat('#,###', 'ar').format(amount)}',
                    style: isExpense
                        ? AppTextStyles.expenseAmount
                        : AppTextStyles.incomeAmount,
                  ),
                  const SizedBox(width: 4),
                  Text(currency, style: AppTextStyles.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMM', 'ar').format(date);
  }
}

/// أيقونة الفئة (دائرة مزدوجة)
class _CategoryIcon extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _CategoryIcon({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.categoryIconOuter,
      height: AppSpacing.categoryIconOuter,
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: AppSpacing.categoryIconInner,
          height: AppSpacing.categoryIconInner,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.white, size: 14),
        ),
      ),
    );
  }
}
