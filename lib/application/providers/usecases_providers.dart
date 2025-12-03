// lib/application/providers/usecases_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'repositories_providers.dart';

// Transaction UseCases
import '../../domain/usecases/transaction/add_transaction_usecase.dart';
import '../../domain/usecases/transaction/update_transaction_usecase.dart';
import '../../domain/usecases/transaction/delete_transaction_usecase.dart';
import '../../domain/usecases/transaction/get_transactions_usecase.dart';

// Account UseCases
import '../../domain/usecases/account/create_account_usecase.dart';
import '../../domain/usecases/account/update_account_usecase.dart';
import '../../domain/usecases/account/delete_account_usecase.dart';

// Category UseCases
import '../../domain/usecases/category/create_category_usecase.dart';
import '../../domain/usecases/category/update_category_usecase.dart';
import '../../domain/usecases/category/delete_category_usecase.dart';

// Budget UseCases
import '../../domain/usecases/budget/create_budget_usecase.dart';
import '../../domain/usecases/budget/get_budget_status_usecase.dart';

// --- Transaction UseCases ---

final addTransactionUseCaseProvider = Provider<AddTransactionUseCase>((ref) {
  return AddTransactionUseCase(
    ref.watch(transactionRepositoryProvider),
    ref.watch(accountRepositoryProvider),
    ref.watch(categoryRepositoryProvider),
  );
});

final updateTransactionUseCaseProvider = Provider<UpdateTransactionUseCase>((
  ref,
) {
  return UpdateTransactionUseCase(
    ref.watch(transactionRepositoryProvider),
    ref.watch(accountRepositoryProvider),
    ref.watch(categoryRepositoryProvider),
  );
});

final deleteTransactionUseCaseProvider = Provider<DeleteTransactionUseCase>((
  ref,
) {
  return DeleteTransactionUseCase(
    ref.watch(transactionRepositoryProvider),
    ref.watch(accountRepositoryProvider),
  );
});

final getTransactionsUseCaseProvider = Provider<GetTransactionsUseCase>((ref) {
  return GetTransactionsUseCase(ref.watch(transactionRepositoryProvider));
});

// --- Account UseCases ---

final createAccountUseCaseProvider = Provider<CreateAccountUseCase>((ref) {
  return CreateAccountUseCase(ref.watch(accountRepositoryProvider));
});

final updateAccountUseCaseProvider = Provider<UpdateAccountUseCase>((ref) {
  return UpdateAccountUseCase(ref.watch(accountRepositoryProvider));
});

final deleteAccountUseCaseProvider = Provider<DeleteAccountUseCase>((ref) {
  return DeleteAccountUseCase(ref.watch(accountRepositoryProvider));
});

// --- Category UseCases ---

final createCategoryUseCaseProvider = Provider<CreateCategoryUseCase>((ref) {
  return CreateCategoryUseCase(ref.watch(categoryRepositoryProvider));
});

final updateCategoryUseCaseProvider = Provider<UpdateCategoryUseCase>((ref) {
  return UpdateCategoryUseCase(ref.watch(categoryRepositoryProvider));
});

final deleteCategoryUseCaseProvider = Provider<DeleteCategoryUseCase>((ref) {
  return DeleteCategoryUseCase(ref.watch(categoryRepositoryProvider));
});

// --- Budget UseCases ---

final createBudgetUseCaseProvider = Provider<CreateBudgetUseCase>((ref) {
  return CreateBudgetUseCase(
    ref.watch(budgetRepositoryProvider),
    ref.watch(categoryRepositoryProvider),
  );
});

final getBudgetStatusUseCaseProvider = Provider<GetBudgetStatusUseCase>((ref) {
  return GetBudgetStatusUseCase(ref.watch(budgetRepositoryProvider));
});
