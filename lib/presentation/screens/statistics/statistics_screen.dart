import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../styles/app_colors.dart';
import '../../styles/app_text_styles.dart';
import '../../styles/app_spacing.dart';
import '../../widgets/gradient_background.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _selectedPeriod = 'شهري'; // 'شهري', 'أسبوعي', 'سنوي'
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground.dashboard(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.paddingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: AppSpacing.gapMd),
                _buildPeriodFilter(),
                const SizedBox(height: AppSpacing.gapLg),
                _buildMonthlySummary(),
                const SizedBox(height: AppSpacing.gapLg),
                _buildCategoryDistribution(),
                const SizedBox(height: AppSpacing.gapLg),
                _buildWeeklyExpensesChart(),
                const SizedBox(height: AppSpacing.gapLg),
                _buildDailyAverageCard(),
                const SizedBox(height: 80), // Bottom padding for nav bar
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('الإحصائيات', style: AppTextStyles.h2),
        IconButton(
          icon: const Icon(Icons.calendar_today, color: AppColors.primaryDark),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildPeriodFilter() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.6)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: ['شهري', 'أسبوعي', 'سنوي'].map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  period,
                  style: AppTextStyles.buttonSmall.copyWith(
                    color: isSelected
                        ? AppColors.primaryDark
                        : AppColors.gray600,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonthlySummary() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'مصاريف',
            '150,000',
            AppColors.expense,
            Icons.arrow_circle_down,
          ),
        ),
        const SizedBox(width: AppSpacing.gapMd),
        Expanded(
          child: _buildSummaryCard(
            'دخل',
            '500,000',
            AppColors.income,
            Icons.arrow_circle_up,
          ),
        ),
        const SizedBox(width: AppSpacing.gapMd),
        Expanded(
          child: _buildSummaryCard(
            'صافي',
            '350,000',
            AppColors.transfer,
            Icons.account_balance_wallet,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                title,
                style: AppTextStyles.bodySmall.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: AppTextStyles.cardAmount.copyWith(
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDistribution() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text('توزيع المصاريف', style: AppTextStyles.h3),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        _touchedIndex = -1;
                        return;
                      }
                      _touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                sectionsSpace: 0,
                centerSpaceRadius: 50,
                sections: [
                  _buildPieSection(0, 45, 'طعام', AppColors.categoryFood),
                  _buildPieSection(
                    1,
                    30,
                    'مواصلات',
                    AppColors.categoryTransport,
                  ),
                  _buildPieSection(2, 15, 'تسوق', AppColors.categoryShopping),
                  _buildPieSection(3, 10, 'أخرى', AppColors.categoryOther),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildLegendItem('طعام', AppColors.categoryFood, '45%'),
              _buildLegendItem('مواصلات', AppColors.categoryTransport, '30%'),
              _buildLegendItem('تسوق', AppColors.categoryShopping, '15%'),
              _buildLegendItem('أخرى', AppColors.categoryOther, '10%'),
            ],
          ),
        ],
      ),
    );
  }

  PieChartSectionData _buildPieSection(
    int index,
    double value,
    String title,
    Color color,
  ) {
    final isTouched = index == _touchedIndex;
    final radius = isTouched ? 60.0 : 50.0;
    return PieChartSectionData(
      color: color,
      value: value,
      title: '',
      radius: radius,
      titleStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      badgeWidget: isTouched
          ? Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(blurRadius: 4, color: Colors.black26),
                ],
              ),
              child: Text(title, style: const TextStyle(fontSize: 10)),
            )
          : null,
    );
  }

  Widget _buildLegendItem(String title, Color color, String percentage) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(title, style: AppTextStyles.bodySmall),
        const SizedBox(width: 4),
        Text(
          percentage,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray400),
        ),
      ],
    );
  }

  Widget _buildWeeklyExpensesChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('مصاريف الأسبوع', style: AppTextStyles.h3),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 20,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.blueGrey,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        rod.toY.round().toString(),
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const titles = [
                          'سبت',
                          'أحد',
                          'إثنين',
                          'ثلاثاء',
                          'أربعاء',
                          'خميس',
                          'جمعة',
                        ];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            titles[value.toInt()],
                            style: const TextStyle(
                              color: Color(0xff7589a2),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _buildBarGroup(0, 5),
                  _buildBarGroup(1, 10),
                  _buildBarGroup(2, 14),
                  _buildBarGroup(3, 15),
                  _buildBarGroup(4, 13),
                  _buildBarGroup(5, 10),
                  _buildBarGroup(6, 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: const LinearGradient(
            colors: [AppColors.expense, Color(0xFFF44336)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: 12,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }

  Widget _buildDailyAverageCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFC107), Color(0xFFFFD54F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFC107).withOpacity(0.35),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'متوسط المصروف اليومي',
                style: AppTextStyles.body.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                '25,000 ل.س',
                style: AppTextStyles.h2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.analytics, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }
}
