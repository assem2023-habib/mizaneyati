import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../styles/app_colors.dart';
import '../../../../styles/app_text_styles.dart';
import '../../../../styles/app_spacing.dart';

class CategoryDistributionCard extends StatefulWidget {
  final Map<String, double> categoryTotals;
  final Map<String, Color> categoryColors;
  final double totalExpense;

  const CategoryDistributionCard({
    super.key,
    required this.categoryTotals,
    required this.categoryColors,
    required this.totalExpense,
  });

  @override
  State<CategoryDistributionCard> createState() =>
      _CategoryDistributionCardState();
}

class _CategoryDistributionCardState extends State<CategoryDistributionCard> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.totalExpense == 0) {
      return const SizedBox.shrink(); // Don't show if no expenses
    }

    // Sort categories by amount (descending)
    final sortedEntries = widget.categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Take top 4 and group others
    final topEntries = sortedEntries.take(4).toList();
    // In a real app, you might group the rest into "Other", 
    // but for now let's just show top 4 to keep UI clean or all if small number.
    
    // Let's actually show all for now, but limit the list height
    final displayEntries = sortedEntries; 

    return Container(
      padding: const EdgeInsets.all(AppSpacing.paddingLg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF0F0F0)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'توزيع المصاريف',
            style: AppTextStyles.h3.copyWith(color: AppColors.primaryDark),
          ),
          const SizedBox(height: AppSpacing.gapLg),
          Row(
            children: [
              // Chart Section
              Expanded(
                flex: 3,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse
                                .touchedSection!
                                .touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                      sections: _showingSections(displayEntries),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.gapMd),
              // Legend Section
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: displayEntries.map((entry) {
                    final percentage = (entry.value / widget.totalExpense) * 100;
                    final color = widget.categoryColors[entry.key] ?? AppColors.gray400;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.key,
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${percentage.toStringAsFixed(0)}%',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _showingSections(
    List<MapEntry<String, double>> entries,
  ) {
    return List.generate(entries.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 50.0 : 40.0;
      final entry = entries[i];
      final color = widget.categoryColors[entry.key] ?? AppColors.gray400;
      final percentage = (entry.value / widget.totalExpense) * 100;

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: isTouched ? '${percentage.toStringAsFixed(0)}%' : '',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: isTouched ? null : _Badge(
          entry.key, 
          size: 30, 
          borderColor: color,
        ),
        badgePositionPercentageOffset: .98,
      );
    });
  }
}

class _Badge extends StatelessWidget {
  const _Badge(
    this.text, {
    required this.size,
    required this.borderColor,
  });
  final String text;
  final double size;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, 2),
            blurRadius: 3,
          ),
        ],
      ),
      padding: const EdgeInsets.all(2), // Adjust padding
      child: Center(
        child: Text(
           text.isNotEmpty ? text[0] : '?', // First letter as icon
           style: TextStyle(
             fontSize: size * 0.5,
             fontWeight: FontWeight.bold,
             color: borderColor,
           ),
        ),
      ),
    );
  }
}
