import 'package:flutter/material.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/custom_fab.dart';
import '../../styles/app_spacing.dart';
import '../../styles/app_colors.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/balance_card.dart';
import 'widgets/quick_actions_row.dart';
import 'widgets/expense_insights_carousel.dart';
import 'widgets/recent_transactions_list.dart';

/// شاشة Dashboard الرئيسية
/// التصميم مبني بالكامل على المواصفات من SCREENS_DOCUMENTATION.md
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground.dashboard(
        child: Stack(
          children: [
            // المحتوى الرئيسي
            SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: AppSpacing.bottomPadding + AppSpacing.paddingLg,
                ),
                child: Column(
                  children: [
                    // Header (الرأس الزجاجي)
                    DashboardHeader(
                      onProfileTap: () {
                        // TODO: الانتقال إلى صفحة الملف الشخصي
                      },
                    ),

                    const SizedBox(height: AppSpacing.paddingMd),

                    // Balance Card (بطاقة الرصيد)
                    const BalanceCard(
                      balance: 900000, // TODO: ربط بالبيانات الحقيقية
                      changePercentage: 5.2,
                      isIncrease: true,
                    ),

                    const SizedBox(height: AppSpacing.paddingLg),

                    // Quick Actions (الأزرار السريعة)
                    QuickActionsRow(
                      onExpenseTap: () {
                        // TODO: فتح شاشة إضافة مصروف
                      },
                      onIncomeTap: () {
                        // TODO: فتح شاشة إضافة دخل
                      },
                      onTransferTap: () {
                        // TODO: فتح شاشة التحويل
                      },
                    ),

                    const SizedBox(height: AppSpacing.paddingLg),

                    // Expense Insights Carousel (كاروسيل المصاريف)
                    const ExpenseInsightsCarousel(
                      monthExpenses: 450000, // TODO: ربط بالبيانات الحقيقية
                      weekExpenses: 120000,
                      dailyAverage: 15000,
                      isSpendingIncreasing: true,
                    ),

                    const SizedBox(height: AppSpacing.paddingLg),

                    // TODO: Category Distribution Card (بطاقة توزيع الفئات)
                    // سيتم إضافتها لاحقاً مع Donut Chart
                    const SizedBox(height: AppSpacing.paddingLg),

                    // Recent Transactions (المعاملات الأخيرة)
                    RecentTransactionsList(
                      transactions: _getSampleTransactions(),
                      onViewAllTap: () {
                        // TODO: الانتقال إلى شاشة جميع المعاملات
                      },
                    ),

                    const SizedBox(height: AppSpacing.paddingLg),
                  ],
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
                  onPressed: () {
                    // TODO: فتح شاشة إضافة معاملة
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بيانات تجريبية للمعاملات
  List<TransactionData> _getSampleTransactions() {
    return const [
      TransactionData(
        categoryName: 'طعام',
        categoryColor: AppColors.categoryFood,
        categoryIcon: Icons.restaurant,
        amount: 25000,
        isExpense: true,
        note: 'غداء في المطعم',
        date: null,
      ),
      TransactionData(
        categoryName: 'مواصلات',
        categoryColor: AppColors.categoryTransport,
        categoryIcon: Icons.directions_car,
        amount: 15000,
        isExpense: true,
        note: 'بنزين',
        date: null,
      ),
      TransactionData(
        categoryName: 'راتب',
        categoryColor: AppColors.categorySalary,
        categoryIcon: Icons.work,
        amount: 500000,
        isExpense: false,
        note: 'راتب الشهر',
        date: null,
      ),
    ];
  }
}
