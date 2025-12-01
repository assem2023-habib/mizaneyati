import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/app_database.dart';
import '../../data/repositories/account_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/repositories/budget_repository.dart';

// Database Provider
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(() => database.close());
  return database;
});

// DAO Providers
final accountsDaoProvider = Provider((ref) {
  final database = ref.watch(databaseProvider);
  return database.accountsDao;
});

final categoriesDaoProvider = Provider((ref) {
  final database = ref.watch(databaseProvider);
  return database.categoriesDao;
});

final transactionsDaoProvider = Provider((ref) {
  final database = ref.watch(databaseProvider);
  return database.transactionsDao;
});

final budgetsDaoProvider = Provider((ref) {
  final database = ref.watch(databaseProvider);
  return database.budgetsDao;
});

// Repository Providers
final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  final accountsDao = ref.watch(accountsDaoProvider);
  return AccountRepository(accountsDao);
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final categoriesDao = ref.watch(categoriesDaoProvider);
  return CategoryRepository(categoriesDao);
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final transactionsDao = ref.watch(transactionsDaoProvider);
  final accountsDao = ref.watch(accountsDaoProvider);
  return TransactionRepository(transactionsDao, accountsDao);
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final budgetsDao = ref.watch(budgetsDaoProvider);
  return BudgetRepository(budgetsDao);
});

// Stream Providers for reactive data
final accountsStreamProvider = StreamProvider((ref) {
  final repository = ref.watch(accountRepositoryProvider);
  return repository.watchAllAccounts();
});

final categoriesStreamProvider = StreamProvider((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return repository.watchAllCategories();
});

final transactionsStreamProvider = StreamProvider((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.watchAllTransactions();
});

final budgetsStreamProvider = StreamProvider((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  return repository.watchAllBudgets();
});
