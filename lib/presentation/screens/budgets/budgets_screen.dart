import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_text_styles.dart';
import '../../styles/app_spacing.dart';
import '../../widgets/gradient_background.dart';

// Domain Imports
import '../../../domain/entities/budget_entity.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../core/utils/result.dart';
import '../../../application/providers/usecases_providers.dart';
import '../../../domain/usecases/budget/get_budget_status_usecase.dart';

class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});

  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  List<BudgetStatus> _budgetStatuses = [];
  Map<String, CategoryEntity> _categoriesMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    setState(() => _isLoading = true);

    // Fetch categories for name lookup
    final categoriesResult = await ref
        .read(getCategoriesUseCaseProvider)
        .execute();
    if (categoriesResult is Success) {
      final categories =
          (categoriesResult as Success<List<CategoryEntity>>).value;
      _categoriesMap = {for (var c in categories) c.id: c};
    }

    // First get all budgets, then get status for each
    final budgetsResult = await ref.read(getBudgetsUseCaseProvider).execute();

    if (budgetsResult is Success) {
      final budgets = (budgetsResult as Success<List<BudgetEntity>>).value;
      final statuses = <BudgetStatus>[];

      for (final budget in budgets) {
        final statusResult = await ref
            .read(getBudgetStatusUseCaseProvider)
            .call(budget.id);
        if (statusResult is Success) {
          statuses.add((statusResult as Success<BudgetStatus>).value);
        }
      }

      if (mounted) {
        setState(() {
          _budgetStatuses = statuses;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: GradientBackground.dashboard(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _budgetStatuses.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد ميزانيات',
                          style: AppTextStyles.bodySecondary,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.paddingMd),
                        itemCount: _budgetStatuses.length,
                        itemBuilder: (context, index) {
                          return _buildBudgetCard(_budgetStatuses[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => const AddBudgetDialog(),
          );
          if (result == true) {
            _loadBudgets();
          }
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

  Widget _buildBudgetCard(BudgetStatus status) {
    final spent = status.spentMinor / 100.0;
    final limit = status.budget.limitAmount.toMajor();
    final percentage = status.progress;
    final isExceeded = status.isExceeded;
    final isWarning = percentage > 0.8 && !isExceeded;

    Color progressColor;
    if (isExceeded) {
      progressColor = AppColors.expense;
    } else if (isWarning) {
      progressColor = AppColors.balance;
    } else {
      progressColor = AppColors.income;
    }

    // Get category name from map
    final categoryName =
        _categoriesMap[status.budget.categoryId]?.name.value ?? 'ميزانية';

    return GestureDetector(
      onTap: () => _showBudgetOptions(status),
      child: Container(
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
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: AppColors.primaryMain,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      categoryName,
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
      ),
    );
  }
}
