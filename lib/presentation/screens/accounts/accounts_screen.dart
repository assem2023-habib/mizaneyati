import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_text_styles.dart';
import '../../styles/app_spacing.dart';
import '../../widgets/gradient_background.dart';

// Domain Imports
import '../../../domain/entities/account_entity.dart';
import '../../../domain/models/account_type.dart';
import '../../../core/utils/result.dart';
import '../../../application/providers/usecases_providers.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  List<AccountEntity> _accounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);

    final result = await ref.read(getAccountsUseCaseProvider).execute();

    if (mounted) {
      setState(() {
        if (result is Success) {
          _accounts = (result as Success<List<AccountEntity>>).value;
        }
        _isLoading = false;
      });
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
                child: _accounts.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد حسابات',
                          style: AppTextStyles.bodySecondary,
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(AppSpacing.paddingMd),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: AppSpacing.gapMd,
                              mainAxisSpacing: AppSpacing.gapMd,
                              childAspectRatio: 0.85,
                            ),
                        itemCount: _accounts.length,
                        itemBuilder: (context, index) {
                          final account = _accounts[index];
                          return _buildAccountCard(account);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Show add account dialog
        },
        backgroundColor: AppColors.primaryDark,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'إضافة حساب',
          style: AppTextStyles.buttonSmall.copyWith(color: Colors.white),
        ),
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
          Text('الحسابات', style: AppTextStyles.h2),
        ],
      ),
    );
  }

  Widget _buildAccountCard(AccountEntity account) {
    final type = account.type;
    Gradient gradient;
    IconData icon;

    switch (type) {
      case AccountType.bank:
        gradient = const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        icon = Icons.account_balance;
        break;
      case AccountType.card:
        gradient = const LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFF6A1B9A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        icon = Icons.credit_card;
        break;
      case AccountType.cash:
      default:
        gradient = const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        icon = Icons.attach_money;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (gradient.colors.first).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                account.name.value,
                style: AppTextStyles.body.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${account.balance.toMajor().toStringAsFixed(0)} ل.س',
                style: AppTextStyles.h3.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
