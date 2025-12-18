import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_text_styles.dart';
import '../../styles/app_spacing.dart';
import '../../widgets/gradient_background.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../core/utils/result.dart';
import '../../../application/providers/usecases_providers.dart';
import '../../../domain/models/transaction_type.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  String _selectedPeriod = 'شهري'; // 'شهري', 'أسبوعي', 'سنوي'
  int _touchedIndex = -1;
  bool _isLoading = true;
  DateTime _anchorDate = DateTime.now();

  // Data
  double _totalIncome = 0;
  double _totalExpense = 0;
  double _netBalance = 0;
  double _dailyAverage = 0;
  
  // Charts
  Map<String, double> _categoryTotals = {};
  Map<String, Color> _categoryColors = {};
  List<double> _weeklyExpenses = List.filled(7, 0.0); // Sun-Sat or Sat-Fri? 

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // Fetch all transactions (optimized: should filter by date range based on _selectedPeriod)
    // For now, let's load all and filter in memory or just assume "This Month" for simplicity if 'شهري' is selected.
    
    final transactionsResult = await ref.read(getTransactionsUseCaseProvider).execute();
    final categoriesResult = await ref.read(getCategoriesUseCaseProvider).execute();

    if (transactionsResult is Success && categoriesResult is Success) {
      final transactions = (transactionsResult as Success<List<TransactionEntity>>).value;
      final categories = (categoriesResult as Success<List<CategoryEntity>>).value;
      
      _processData(transactions, categories);
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _processData(List<TransactionEntity> transactions, List<CategoryEntity> categories) {
    // 1. Filter by Period (Defaulting to Current Month for 'شهري')
    final now = _anchorDate;
    final filteredTransactions = transactions.where((t) {
      if (_selectedPeriod == 'شهري') {
        return t.date.value.month == now.month && t.date.value.year == now.year;
      } else if (_selectedPeriod == 'سنوي') {
        return t.date.value.year == now.year;
      } else {
        // Weekly: Current week
        // Simple logic: within last 7 days? Or current calendar week?
        // Let's say current calendar week.
        // For simplicity now, let's stick to Month logic being the default and robust one.
        return t.date.value.month == now.month && t.date.value.year == now.year; 
      }
    }).toList();

    double income = 0;
    double expense = 0;
    Map<String, double> catTotals = {};
    List<double> weekDays = List.filled(7, 0.0);

    for (var t in filteredTransactions) {
      final amount = t.amount.toMajor();
      if (t.type == TransactionType.income) {
        income += amount;
      } else if (t.type == TransactionType.expense) {
        expense += amount;
        
        // Category Totals
        catTotals[t.categoryId] = (catTotals[t.categoryId] ?? 0) + amount;
        
        // Weekly (Bar Chart) - Group by weekday (1=Mon, 7=Sun) -> Index 0-6
        // Let's map Mon(1)->0, ..., Sun(7)->6.
        // Or Sat->0 if we want saturday start.
        // The chart labels are "Sat, Sun, Mon...". 
        // Sat=6, Sun=7, Mon=1...
        // Index mapping: Sat->0, Sun->1, Mon->2, Tue->3, Wed->4, Thu->5, Fri->6
        int dayIndex = (t.date.value.weekday + 1) % 7; // Mon(1)->2, Sat(6)->0, Sun(7)->1. 
        // Wait:
        // Sat(6) + 1 = 7 % 7 = 0. Correct.
        // Sun(7) + 1 = 8 % 7 = 1. Correct.
        // Mon(1) + 1 = 2 % 7 = 2. Correct.
        weekDays[dayIndex] += amount;
      }
    }

    // Category Colors Map
    Map<String, Color> catColors = {};
    for (var c in categories) {
      final hexString = c.color.hex.replaceFirst('#', '');
      catColors[c.id] = Color(int.parse('FF$hexString', radix: 16));
    }
    
    // Daily Average
    // Days passed in month so far (or total days if past month)
    int days = now.day; // Approximation for "so far this month"
    if (days == 0) days = 1;
    double avg = expense / days;

    _totalIncome = income;
    _totalExpense = expense;
    _netBalance = income - expense;
    _categoryTotals = catTotals;
    _categoryColors = catColors;
    _weeklyExpenses = weekDays;
    _dailyAverage = avg;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // ... rest of build
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
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _anchorDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.primaryDark,
                      onPrimary: Colors.white,
                      onSurface: AppColors.gray800,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() {
                _anchorDate = picked;
              });
              _loadData();
            }
          },
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
            '${_totalExpense.toStringAsFixed(0)}',
            AppColors.expense,
            Icons.arrow_circle_down,
          ),
        ),
        const SizedBox(width: AppSpacing.gapMd),
        Expanded(
          child: _buildSummaryCard(
            'دخل',
            '${_totalIncome.toStringAsFixed(0)}',
            AppColors.income,
            Icons.arrow_circle_up,
          ),
        ),
        const SizedBox(width: AppSpacing.gapMd),
        Expanded(
          child: _buildSummaryCard(
            'صافي',
            '${_netBalance.toStringAsFixed(0)}',
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
    // Generate sections
    final sections = <PieChartSectionData>[];
    int index = 0;
    _categoryTotals.forEach((id, amount) {
      if (amount > 0) {
        sections.add(_buildPieSection(
          index,
          amount,
          '', // Title hidden here, shown in legend or badge
          _categoryColors[id] ?? Colors.grey,
        ));
        index++;
      }
    });

    if (sections.isEmpty) {
       return const SizedBox.shrink();
    }

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
                sections: sections,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Simple Legend: Show top 4 or generic
          // For now, let's skip complex legend and just rely on chart interactions
          // or build a simple list if needed.
          // To keep it clean, I'll remove the hardcoded legend.
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
    // Determine Max Y for scale
    double maxY = 0;
    for (var val in _weeklyExpenses) {
      if (val > maxY) maxY = val;
    }
    if (maxY == 0) maxY = 100; // Default if empty
    maxY *= 1.2; // Add some buffer

    // Build Bar Groups
    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < 7; i++) {
      barGroups.add(_buildBarGroup(i, _weeklyExpenses[i]));
    }

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
                maxY: maxY,
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
                        // Safety check for index
                        if (value < 0 || value >= titles.length) return const SizedBox.shrink();
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
                barGroups: barGroups,
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
                '${_dailyAverage.toStringAsFixed(0)} ل.س',
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
