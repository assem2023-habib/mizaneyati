import 'package:flutter/material.dart';
import '../../../styles/app_spacing.dart';
import 'insight_card.dart';

/// كاروسيل أفقي قابل للتمرير لبطاقات الـ Insights
/// يحتوي على 4 بطاقات: مصاريف الشهر، الأسبوع، المتوسط اليومي، اتجاه المصاريف
class ExpenseInsightsCarousel extends StatelessWidget {
  final double monthExpenses;
  final double weekExpenses;
  final double dailyAverage;
  final bool isSpendingIncreasing;

  const ExpenseInsightsCarousel({
    super.key,
    required this.monthExpenses,
    required this.weekExpenses,
    required this.dailyAverage,
    this.isSpendingIncreasing = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.paddingContainer,
        ),
        children: [
          // بطاقة 1 - مصاريف الشهر
          InsightCard.monthExpenses(
            amount: monthExpenses,
            // TODO: إضافة LineChart لاحقاً
          ),
          const SizedBox(width: AppSpacing.gapMd),

          // بطاقة 2 - مصاريف الأسبوع
          InsightCard.weekExpenses(
            amount: weekExpenses,
            // TODO: إضافة BarChart لاحقاً
          ),
          const SizedBox(width: AppSpacing.gapMd),

          // بطاقة 3 - متوسط المصروف اليومي
          InsightCard.dailyAverage(
            amount: dailyAverage,
            // TODO: إضافة Circular Progress لاحقاً
          ),
          const SizedBox(width: AppSpacing.gapMd),

          // بطاقة 4 - اتجاه المصاريف
          InsightCard.spendingTrend(
            trendText: isSpendingIncreasing ? 'ارتفاع' : 'انخفاض',
            isIncrease: isSpendingIncreasing,
          ),
        ],
      ),
    );
  }
}
