import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/custom_fab.dart';
import '../../styles/app_spacing.dart';
import '../../styles/app_colors.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/balance_card.dart';
import 'widgets/quick_actions_row.dart';
import 'widgets/expense_insights_carousel.dart';
import 'widgets/recent_transactions_list.dart';
import 'widgets/category_distribution_card.dart';

// Screens
import '../add_transaction/add_transaction_screen.dart';
import '../accounts/accounts_screen.dart';
import '../transactions_list/transactions_list_screen.dart';
import '../settings/settings_screen.dart';

// Domain & Data
import '../../../domain/entities/account_entity.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/models/transaction_type.dart';
import '../../../core/utils/result.dart';
import '../../../application/providers/usecases_providers.dart';

/// شاشة Dashboard الرئيسية
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  // State
  bool _isLoading = true;
  double _totalBalance = 0;
  List<TransactionData> _recentTransactions = [];
  
  // Insights
  double _monthExpenses = 0;
  double _weekExpenses = 0;
  double _dailyAverage = 0;
  bool _isSpendingIncreasing = false; // Simplified logic for now

  // Category Distribution
  Map<String, double> _categoryTotals = {};
  Map<String, Color> _categoryColors = {};
  double _totalExpenseForDistribution = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // 1. Fetch Accounts for Total Balance
      final accountsResult = await ref.read(getAccountsUseCaseProvider).execute();
      double balance = 0;
      if (accountsResult is Success) {
        final accounts = (accountsResult as Success<List<AccountEntity>>).value;
        balance = accounts.fold(0, (sum, acc) => sum + acc.balance.toMajor());
      }

      // 2. Fetch Categories for Mapping
      final categoriesResult = await ref.read(getCategoriesUseCaseProvider).execute();
      Map<String, CategoryEntity> categoryMap = {};
      if (categoriesResult is Success) {
        final categories = (categoriesResult as Success<List<CategoryEntity>>).value;
        categoryMap = {for (var c in categories) c.id: c};
      }

      // 3. Fetch Transactions for everything else
      final transactionsResult = await ref.read(getTransactionsUseCaseProvider).execute();
      
      List<TransactionData> mappedTransactions = [];
      double mExpenses = 0;
      double wExpenses = 0;
      Map<String, double> catTotals = {};
      Map<String, Color> catColors = {};
      double totalDistExpense = 0;

      if (transactionsResult is Success) {
        final transactions = (transactionsResult as Success<List<TransactionEntity>>).value;
        
        // Sort by date descending
        transactions.sort((a, b) => b.date.value.compareTo(a.date.value));

        // Process for Recent List
        mappedTransactions = transactions.take(5).map((t) {
          final category = categoryMap[t.categoryId];
          Color catColor = AppColors.gray400;
          if (category != null) {
            final hexString = category.color.hex.replaceFirst('#', '');
            catColor = Color(int.parse('FF$hexString', radix: 16));
          }

          return TransactionData(
            categoryName: category?.name.value ?? 'غير معروف',
            categoryColor: catColor,
            categoryIcon: Icons.category, // Placeholder, would need icon mapping
            amount: t.amount.toMajor(),
            isExpense: t.type == TransactionType.expense,
            note: t.note?.value,
            date: t.date.value,
          );
        }).toList();

        // Process for Insights & Distribution
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Monday as start

        for (var t in transactions) {
          if (t.type == TransactionType.expense) {
            final amount = t.amount.toMajor();
            final date = t.date.value;

            // Month Expenses
            if (date.isAfter(startOfMonth) || date.isAtSameMomentAs(startOfMonth)) {
              mExpenses += amount;
            }

            // Week Expenses
            if (date.isAfter(startOfWeek) || date.isAtSameMomentAs(startOfWeek)) {
              wExpenses += amount;
            }

            // Distribution
            final catName = categoryMap[t.categoryId]?.name.value ?? 'أخرى';
            Color cColor = AppColors.gray400;
             if (categoryMap[t.categoryId] != null) {
                final hexString = categoryMap[t.categoryId]!.color.hex.replaceFirst('#', '');
                cColor = Color(int.parse('FF$hexString', radix: 16));
            }

            catTotals[catName] = (catTotals[catName] ?? 0) + amount;
            catColors[catName] = cColor;
            totalDistExpense += amount;
          }
        }
      }

      // Calculate Daily Average (simple: month expenses / day of month)
      final dayOfMonth = DateTime.now().day;
      final avg = dayOfMonth > 0 ? mExpenses / dayOfMonth : 0.0;

      if (mounted) {
        setState(() {
          _totalBalance = balance;
          _recentTransactions = mappedTransactions;
          _monthExpenses = mExpenses;
          _weekExpenses = wExpenses;
          _dailyAverage = avg;
          _categoryTotals = catTotals;
          _categoryColors = catColors;
          _totalExpenseForDistribution = totalDistExpense;
          _isLoading = false;
        });
      }

    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _navigateToAddTransaction(BuildContext context,
      {bool isExpense = true, bool isTransfer = false}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(
          initialType: isTransfer
              ? TransactionType.transfer
              : (isExpense ? TransactionType.expense : TransactionType.income),
        ),
      ),
    );
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: GradientBackground.dashboard(
        child: SizedBox.expand(
          child: Stack(
            children: [
            // المحتوى الرئيسي
            SafeArea(
              bottom: false,
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: AppSpacing.bottomPadding + AppSpacing.paddingLg,
                  ),
                  child: Column(
                    children: [
                      // Header (الرأس الزجاجي)
                      DashboardHeader(
                        onProfileTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SettingsScreen()),
                          );
                        },
                      ),
            
                      const SizedBox(height: AppSpacing.paddingMd),
            
                      // Balance Card (بطاقة الرصيد)
                      BalanceCard(
                        balance: _totalBalance,
                        changePercentage: 0.0, // TODO: Calculate real change
                        isIncrease: true,
                      ),
            
                      const SizedBox(height: AppSpacing.paddingLg),
            
                      // Quick Actions (الأزرار السريعة)
                      QuickActionsRow(
                        onExpenseTap: () => _navigateToAddTransaction(context, isExpense: true),
                        onIncomeTap: () => _navigateToAddTransaction(context, isExpense: false),
                        onTransferTap: () => _navigateToAddTransaction(context, isTransfer: true),
                      ),
            
                      const SizedBox(height: AppSpacing.paddingLg),
            
                      // Expense Insights Carousel (كاروسيل المصاريف)
                      ExpenseInsightsCarousel(
                        monthExpenses: _monthExpenses,
                        weekExpenses: _weekExpenses,
                        dailyAverage: _dailyAverage,
                        isSpendingIncreasing: _isSpendingIncreasing,
                      ),
            
                      const SizedBox(height: AppSpacing.paddingLg),
            
                      // Category Distribution Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.paddingContainer),
                        child: CategoryDistributionCard(
                          categoryTotals: _categoryTotals,
                          categoryColors: _categoryColors,
                          totalExpense: _totalExpenseForDistribution,
                        ),
                      ),
            
                      const SizedBox(height: AppSpacing.paddingLg),
            
                      // Recent Transactions (المعاملات الأخيرة)
                      RecentTransactionsList(
                        transactions: _recentTransactions,
                        onViewAllTap: () async {
                           await Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (_) => const TransactionsListScreen()),
                          );
                          _loadData();
                        },
                      ),
            
                      const SizedBox(height: AppSpacing.paddingLg),
                    ],
                  ),
                ),
              ),
            ),
            
            // FAB (Floating Action Button)
            Positioned(
              bottom: AppSpacing.fabBottomPosition,
              left: 0,
              right: 0,
              child: Center(
                child: CustomFAB(
                  onPressed: () => _navigateToAddTransaction(context),
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}
