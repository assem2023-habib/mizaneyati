import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../styles/app_colors.dart';
import '../../../styles/app_text_styles.dart';
import '../../../styles/app_spacing.dart';

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

    // Group into "Other" if more than 5 categories
    final List<MapEntry<String, double>> displayEntries;
    if (sortedEntries.length > 5) {
      final topEntries = sortedEntries.take(4).toList();
      final otherEntries = sortedEntries.skip(4);
      
      final double otherTotal = otherEntries.fold(0, (sum, item) => sum + item.value);
      
      displayEntries = [
        ...topEntries,
        MapEntry('أخرى', otherTotal),
      ];
    } else {
      displayEntries = sortedEntries;
    } 

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
                child: _buildLegend(displayEntries),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _showingSections(
      List<MapEntry<String, double>> entries) {
    return List.generate(entries.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 14.0;
      final radius = isTouched ? 55.0 : 45.0;
      final entry = entries[i];
      final percentage = (entry.value / widget.totalExpense * 100);
      
      final color = entry.key == 'أخرى' 
          ? Colors.grey 
          : widget.categoryColors[entry.key] ?? AppColors.gray400;

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black26, blurRadius: 2)],
        ),
      );
    });
  }

  Widget _buildLegend(List<MapEntry<String, double>> entries) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: entries.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final color = item.key == 'أخرى' 
            ? Colors.grey 
            : widget.categoryColors[item.key] ?? AppColors.gray400;
            
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.key,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: index == touchedIndex ? FontWeight.bold : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
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
