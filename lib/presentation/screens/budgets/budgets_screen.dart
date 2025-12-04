import 'package:flutter/material.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_text_styles.dart';
import '../../styles/app_spacing.dart';
import '../../widgets/gradient_background.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for budgets
    final List<Map<String, dynamic>> budgets = [
      {
        'category': 'طعام',
        'spent': 125000.0,
        'limit': 200000.0,
        'icon': Icons.restaurant,
      },
      {
        'category': 'تسوق',
        'spent': 180000.0,
        'limit': 150000.0,
        'icon': Icons.shopping_bag,
      },
      {
        'category': 'مواصلات',
        'spent': 45000.0,
        'limit': 50000.0,
        'icon': Icons.directions_car,
      },
    ];

    return Scaffold(
      body: GradientBackground.dashboard(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.paddingMd),
                  itemCount: budgets.length,
                  itemBuilder: (context, index) {
                    final budget = budgets[index];
                    return _buildBudgetCard(budget);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Show add budget dialog
        },
        backgroundColor: AppColors.primaryDark,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.paddingMd),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text('الميزانيات', style: AppTextStyles.h2),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(Map<String, dynamic> budget) {
    final spent = budget['spent'] as double;
    final limit = budget['limit'] as double;
    final percentage = spent / limit;
    final isExceeded = percentage > 1.0;
    final isWarning = percentage > 0.8 && !isExceeded;

    Color progressColor;
    if (isExceeded) {
      progressColor = AppColors.expense;
    } else if (isWarning) {
      progressColor = AppColors.balance;
    } else {
      progressColor = AppColors.income;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.gapMd),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: isExceeded
            ? Border.all(color: AppColors.expense.withOpacity(0.5))
            : Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMain.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      budget['icon'],
                      color: AppColors.primaryMain,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    budget['category'],
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isExceeded) ...[
                    const SizedBox(width: 8),
                    Text(
                      '(تجاوز!)',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.expense,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                '${(percentage * 100).toStringAsFixed(1)}%',
                style: AppTextStyles.body.copyWith(
                  color: progressColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${spent.toStringAsFixed(0)} ل.س',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isExceeded ? AppColors.expense : AppColors.gray800,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${limit.toStringAsFixed(0)} ل.س',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gray600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage > 1.0 ? 1.0 : percentage,
              backgroundColor: AppColors.gray200,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
