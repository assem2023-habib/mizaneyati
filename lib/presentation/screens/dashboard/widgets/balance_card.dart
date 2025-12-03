import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../styles/app_colors.dart';
import '../../../styles/app_text_styles.dart';
import '../../../styles/app_spacing.dart';
import '../../../widgets/wave_painter.dart';
import '../../../../core/constants/app_constants.dart';

/// بطاقة الرصيد الرئيسية (Hero Balance Card)
/// تعرض الرصيد الكلي مع تدرج أخضر وموجات وتوهج
class BalanceCard extends StatelessWidget {
  final double balance;
  final double? changePercentage;
  final bool isIncrease;
  final String currency;

  const BalanceCard({
    super.key,
    required this.balance,
    this.changePercentage,
    this.isIncrease = true,
    this.currency = AppConstants.defaultCurrencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.paddingContainer,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.paddingXl),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppSpacing.radiusBalance),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withOpacity(0.35),
              blurRadius: AppSpacing.shadowMd,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Stack(
          children: [
            // موجات SVG في الأسفل
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: CustomPaint(
                  size: Size(
                    double.infinity,
                    200, // ارتفاع الموجات
                  ),
                  painter: WavePainter(color: AppColors.white, opacity: 0.2),
                ),
              ),
            ),

            // انعكاس ضوء قطري
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusBalance),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.transparent,
                      AppColors.white.withOpacity(0.4),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // المحتوى
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "الرصيد الكلي"
                Text('الرصيد الكلي', style: AppTextStyles.whiteText90),
                const SizedBox(height: AppSpacing.paddingSm),

                // المبلغ
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      NumberFormat('#,###', 'ar').format(balance),
                      style: AppTextStyles.balanceAmount,
                    ),
                    const SizedBox(width: AppSpacing.paddingSm),
                    Text(
                      currency,
                      style: AppTextStyles.whiteText80.copyWith(fontSize: 20),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.paddingMd),

                // نسبة التغيير (إذا كانت موجودة)
                if (changePercentage != null)
                  Row(
                    children: [
                      Icon(
                        isIncrease ? Icons.trending_up : Icons.trending_down,
                        color: AppColors.white,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.paddingXs),
                      Text(
                        '${isIncrease ? '+' : ''}${changePercentage!.toStringAsFixed(1)}%',
                        style: AppTextStyles.whiteText,
                      ),
                      const SizedBox(width: AppSpacing.paddingXs),
                      Text(
                        'vs الشهر الماضي',
                        style: AppTextStyles.whiteText80.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
