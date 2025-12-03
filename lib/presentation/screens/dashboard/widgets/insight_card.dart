import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../styles/app_colors.dart';
import '../../../styles/app_text_styles.dart';
import '../../../styles/app_spacing.dart';
import '../../../../core/constants/app_constants.dart';

/// بطاقة Insight (بطاقات الكاروسيل)
/// تُستخدم في: Carousel المصاريف (مصاريف الشهر، الأسبوع، المتوسط، الاتجاه)
class InsightCard extends StatelessWidget {
  final String title;
  final double amount;
  final String currency;
  final Widget? chart;
  final Color amountColor;
  final IconData? trendIcon;

  const InsightCard({
    super.key,
    required this.title,
    required this.amount,
    this.currency = AppConstants.defaultCurrencySymbol,
    this.chart,
    this.amountColor = AppColors.expense,
    this.trendIcon,
  });

  /// بطاقة مصاريف الشهر
  factory InsightCard.monthExpenses({required double amount, Widget? chart}) {
    return InsightCard(
      title: 'مصاريف هذا الشهر',
      amount: amount,
      chart: chart,
      amountColor: AppColors.expense,
    );
  }

  /// بطاقة مصاريف الأسبوع
  factory InsightCard.weekExpenses({required double amount, Widget? chart}) {
    return InsightCard(
      title: 'مصاريف هذا الأسبوع',
      amount: amount,
      chart: chart,
      amountColor: AppColors.expense,
    );
  }

  /// بطاقة متوسط المصروف اليومي
  factory InsightCard.dailyAverage({required double amount, Widget? chart}) {
    return InsightCard(
      title: 'متوسط المصروف اليومي',
      amount: amount,
      chart: chart,
      amountColor: AppColors.balance,
    );
  }

  /// بطاقة اتجاه المصاريف
  factory InsightCard.spendingTrend({
    required String trendText,
    required bool isIncrease,
  }) {
    return InsightCard(
      title: 'اتجاه المصاريف',
      amount: 0,
      amountColor: isIncrease ? AppColors.expense : AppColors.income,
      trendIcon: isIncrease ? Icons.trending_up : Icons.trending_down,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.carouselCardWidth,
      padding: const EdgeInsets.all(AppSpacing.paddingCard),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: AppSpacing.shadowLg,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Text(
            title,
            style: AppTextStyles.bodySecondary.copyWith(fontSize: 14),
          ),
          const SizedBox(height: AppSpacing.paddingSm),

          // المبلغ أو الأيقونة
          if (trendIcon != null)
            Row(
              children: [
                Icon(trendIcon, color: amountColor, size: 32),
                const SizedBox(width: AppSpacing.paddingSm),
                Text(
                  trendIcon == Icons.trending_up ? 'ارتفاع' : 'انخفاض',
                  style: AppTextStyles.trendAmount.copyWith(color: amountColor),
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  NumberFormat('#,###', 'ar').format(amount),
                  style: AppTextStyles.cardAmount.copyWith(color: amountColor),
                ),
                const SizedBox(width: 4),
                Text(currency, style: AppTextStyles.bodySmall),
              ],
            ),

          // الرسم البياني (إذا كان موجوداً)
          if (chart != null) ...[
            const SizedBox(height: AppSpacing.paddingMd),
            Expanded(child: chart!),
          ],
        ],
      ),
    );
  }
}
