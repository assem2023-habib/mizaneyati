import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../../styles/app_colors.dart';
import '../../styles/app_text_styles.dart';
import '../../styles/app_spacing.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/transaction_list_item.dart';

class TransactionsListScreen extends StatefulWidget {
  const TransactionsListScreen({super.key});

  @override
  State<TransactionsListScreen> createState() => _TransactionsListScreenState();
}

class _TransactionsListScreenState extends State<TransactionsListScreen> {
  String _selectedFilter = 'الكل'; // 'الكل', 'مصاريف', 'دخل'

  // Dummy data for demonstration
  final List<Map<String, dynamic>> _transactions = [
    {
      'category': 'طعام',
      'amount': 5000.0,
      'isExpense': true,
      'date': DateTime.now(),
      'icon': Icons.fastfood,
      'color': AppColors.categoryFood,
    },
    {
      'category': 'مواصلات',
      'amount': 2000.0,
      'isExpense': true,
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'icon': Icons.directions_car,
      'color': AppColors.categoryTransport,
    },
    {
      'category': 'راتب',
      'amount': 500000.0,
      'isExpense': false,
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'icon': Icons.attach_money,
      'color': AppColors.categorySalary,
    },
  ];

  List<Map<String, dynamic>> get _filteredTransactions {
    if (_selectedFilter == 'مصاريف') {
      return _transactions.where((t) => t['isExpense'] == true).toList();
    } else if (_selectedFilter == 'دخل') {
      return _transactions.where((t) => t['isExpense'] == false).toList();
    }
    return _transactions;
  }

  Map<String, List<Map<String, dynamic>>> get _groupedTransactions {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (var t in _filteredTransactions) {
      final date = t['date'] as DateTime;
      final key = _getDateKey(date);
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(t);
    }
    return grouped;
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'اليوم';
    if (dateOnly == yesterday) return 'أمس';
    return intl.DateFormat('d MMMM yyyy', 'ar').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground.dashboard(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildFilterBar(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.paddingMd),
                  itemCount: _groupedTransactions.length,
                  itemBuilder: (context, index) {
                    final key = _groupedTransactions.keys.elementAt(index);
                    final transactions = _groupedTransactions[key]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.paddingSm,
                          ),
                          child: Text(
                            key,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.gray600,
                            ),
                          ),
                        ),
                        ...transactions.map(
                          (t) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.paddingSm,
                            ),
                            child: Dismissible(
                              key: ValueKey(t.hashCode),
                              background: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFFC107),
                                      Color(0xFFFFD54F),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                              ),
                              secondaryBackground: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFE53935),
                                      Color(0xFFF44336),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 20),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              child: TransactionListItem(
                                categoryName: t['category'],
                                categoryColor: t['color'],
                                categoryIcon: t['icon'],
                                amount: t['amount'],
                                isExpense: t['isExpense'],
                                date: t['date'],
                                onTap: () {
                                  // Navigate to details
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.paddingMd),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('المعاملات', style: AppTextStyles.h2),
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.primaryDark),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.paddingMd),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('الكل'),
          const SizedBox(width: AppSpacing.gapSm),
          _buildFilterChip('مصاريف', activeColor: AppColors.expense),
          const SizedBox(width: AppSpacing.gapSm),
          _buildFilterChip('دخل', activeColor: AppColors.income),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {Color? activeColor}) {
    final isSelected = _selectedFilter == label;
    final color = activeColor ?? AppColors.primaryMain;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [color, color.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
          border: isSelected ? null : Border.all(color: Colors.white),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.buttonSmall.copyWith(
            color: isSelected ? Colors.white : AppColors.gray600,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
