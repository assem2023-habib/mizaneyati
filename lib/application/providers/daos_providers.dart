// lib/application/providers/daos_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/daos/accounts_dao.dart';
import '../../data/local/daos/categories_dao.dart';
import '../../data/local/daos/transactions_dao.dart';
import '../../data/local/daos/budgets_dao.dart';
import 'database_provider.dart';

final accountsDaoProvider = Provider<AccountsDao>((ref) {
  return ref.watch(databaseProvider).accountsDao;
});

final categoriesDaoProvider = Provider<CategoriesDao>((ref) {
  return ref.watch(databaseProvider).categoriesDao;
});

final transactionsDaoProvider = Provider<TransactionsDao>((ref) {
  return ref.watch(databaseProvider).transactionsDao;
});

final budgetsDaoProvider = Provider<BudgetsDao>((ref) {
  return ref.watch(databaseProvider).budgetsDao;
});
