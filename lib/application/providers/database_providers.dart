import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/db/app_database.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../data/repositories/budget_repository_impl.dart';

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
  final database = ref.watch(databaseProvider);
  return AccountRepositoryImpl(database);
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return CategoryRepositoryImpl(database);
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return TransactionRepositoryImpl(database);
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return BudgetRepositoryImpl(database);
});

// Stream Providers for reactive data
final accountsStreamProvider = StreamProvider((ref) {
  final repository = ref.watch(accountRepositoryProvider);
  return repository.watchAll();
});

final categoriesStreamProvider = StreamProvider((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return repository.watchAll();
});

final transactionsStreamProvider = StreamProvider((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.watchAll();
});

final budgetsStreamProvider = StreamProvider((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  return repository.watchAll();
});
