import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../../styles/app_colors.dart';
import '../../styles/app_text_styles.dart';
import '../../styles/app_spacing.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/transaction_list_item.dart';

// Domain Imports
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/account_entity.dart';
import '../../../core/utils/result.dart';
import '../../../application/providers/usecases_providers.dart';

class TransactionsListScreen extends ConsumerStatefulWidget {
  const TransactionsListScreen({super.key});

  @override
  ConsumerState<TransactionsListScreen> createState() =>
      _TransactionsListScreenState();
}

class _TransactionsListScreenState
    extends ConsumerState<TransactionsListScreen> {
  String _selectedFilter = 'الكل'; // 'الكل', 'مصاريف', 'دخل'
  List<TransactionEntity> _transactions = [];
  Map<String, CategoryEntity> _categoriesMap = {};
  Map<String, AccountEntity> _accountsMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // 1. Fetch Dependencies (Categories & Accounts)
    final categoriesResult = await ref
        .read(getCategoriesUseCaseProvider)
        .execute();
    final accountsResult = await ref.read(getAccountsUseCaseProvider).execute();

    if (categoriesResult is Success) {
      final categories =
          (categoriesResult as Success<List<CategoryEntity>>).value;
      _categoriesMap = {for (var c in categories) c.id: c};
    }

    if (accountsResult is Success) {
      final accounts = (accountsResult as Success<List<AccountEntity>>).value;
      _accountsMap = {for (var a in accounts) a.id: a};
    }

    // 2. Fetch Transactions
    await _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    final result = await ref
        .read(getTransactionsUseCaseProvider)
        .recent(limit: 50);

    if (mounted) {
      setState(() {
        if (result is Success) {
          _transactions = (result as Success<List<TransactionEntity>>).value;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteTransaction(String id) async {
    final result = await ref.read(deleteTransactionUseCaseProvider).call(id);
    if (mounted) {
      if (result is Success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف المعاملة'),
            backgroundColor: AppColors.primaryMain,
          ),
        );
        _fetchTransactions();
      } else {
        final failure = (result as Fail).failure;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${failure.message}'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }

  List<TransactionEntity> get _filteredTransactions {
    if (_selectedFilter == 'مصاريف') {
      return _transactions.where((t) => t.type.name == 'expense').toList();
    } else if (_selectedFilter == 'دخل') {
      return _transactions.where((t) => t.type.name == 'income').toList();
    }
    return _transactions;
  }

  Map<String, List<TransactionEntity>> get _groupedTransactions {
    final grouped = <String, List<TransactionEntity>>{};
    for (var t in _filteredTransactions) {
      final date = t.date.value;
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: GradientBackground.dashboard(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildFilterBar(),
              Expanded(
                child: _transactions.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد معاملات',
                          style: AppTextStyles.bodySecondary,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.paddingMd),
                        itemCount: _groupedTransactions.length,
                        itemBuilder: (context, index) {
                          final key = _groupedTransactions.keys.elementAt(
                            index,
                          );
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
                              ...transactions.map((t) {
                                final category = _categoriesMap[t.categoryId];
                                final categoryName =
                                    category?.name.value ?? 'غير معروف';
                                Color categoryColor = AppColors.gray400;
                                if (category != null) {
                                  final hexString = category.color.hex
                                      .replaceFirst('#', '');
                                  categoryColor = Color(
                                    int.parse('FF$hexString', radix: 16),
                                  );
                                }
                                const categoryIcon = Icons.category;

                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.paddingSm,
                                  ),
                                  child: Dismissible(
                                    key: ValueKey(t.id),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
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
                                    onDismissed: (direction) =>
                                        _deleteTransaction(t.id),
                                    child: TransactionListItem(
                                      categoryName: categoryName,
                                      categoryColor: categoryColor,
                                      categoryIcon: categoryIcon,
                                      amount: t.amount.toMajor(),
                                      isExpense: t.type.name == 'expense',
                                      date: t.date.value,
                                      onTap: () {},
                                    ),
                                  ),
                                );
                              }),
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
