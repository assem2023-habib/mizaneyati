// lib/domain/repositories/transaction_repository.dart
import '../entities/transaction_entity.dart';
import '../entities/account_entity.dart';
import '../models/transaction_type.dart';
import '../../core/utils/result.dart';

/// Abstract repository for Transaction operations
///
/// This defines the contract that the data layer must implement.
/// All mutation methods return Future<Result<T>> for error handling.
/// Transactions must be atomic (insert + balance updates together).
abstract class TransactionRepository {
  /// Creates a new transaction and updates account balances atomically
  ///
  /// [account] is the source account with the updated balance (after debit/credit).
  /// For transfers, [toAccount] must be provided with its updated balance.
  /// This operation must be executed in a database transaction to ensure
  /// that both the transaction record and account balances are updated together.
  Future<Result<String>> createTransaction(
    TransactionEntity tx, {
    required AccountEntity account,
    AccountEntity? toAccount,
  });

  /// Updates an existing transaction
  ///
  /// [affectedAccounts] contains all accounts that had their balances modified
  /// during this operation (e.g. old source, new source, old dest, new dest).
  ///
  /// Must reverse old transaction effects and apply new ones atomically.
  Future<Result<void>> updateTransaction(
    TransactionEntity tx, {
    required List<AccountEntity> affectedAccounts,
  });

  /// Deletes a transaction and reverses its effects on account balances
  ///
  /// [account] is the account with the balance reversed (original amount added back/deducted).
  /// [toAccount] is the destination account with balance reversed (if transfer).
  ///
  /// Must be atomic - delete record and update balances together.
  Future<Result<void>> deleteTransaction(
    String txId, {
    required AccountEntity account,
    AccountEntity? toAccount,
  });

  /// Gets a transaction by ID
  Future<Result<TransactionEntity>> getById(String txId);

  /// Gets transactions by date range
  Future<Result<List<TransactionEntity>>> getByDateRange(
    DateTime start,
    DateTime end,
  );

  /// Gets transactions for a specific account
  Future<Result<List<TransactionEntity>>> getByAccount(
    String accountId, {
    int? limit,
    int? offset,
  });

  /// Gets transactions for a specific category
  Future<Result<List<TransactionEntity>>> getByCategory(
    String categoryId, {
    int? limit,
    int? offset,
  });

  /// Gets transactions by type (income, expense, transfer)
  Future<Result<List<TransactionEntity>>> getByType(
    TransactionType type, {
    int? limit,
    int? offset,
  });

  /// Gets paginated transactions
  Future<Result<List<TransactionEntity>>> getPaginated({
    int limit = 50,
    int offset = 0,
  });

  /// Watches all transactions for real-time updates
  Stream<List<TransactionEntity>> watchAll({int? limit, int? offset});

  /// Watches transactions by date range
  Stream<List<TransactionEntity>> watchByDateRange(
    DateTime start,
    DateTime end,
  );

  /// Watches transactions for a specific account
  Stream<List<TransactionEntity>> watchByAccount(String accountId);

  /// Counts all transactions
  Future<Result<int>> countAll();

  /// Counts transactions for a specific account
  Future<Result<int>> countByAccount(String accountId);

  /// Counts transactions for a specific category
  Future<Result<int>> countByCategory(String categoryId);

  /// Gets total amount by type in a date range
  Future<Result<int>> getTotalAmountByType(
    TransactionType type,
    DateTime start,
    DateTime end,
  );

  /// Gets recent transactions
  Future<Result<List<TransactionEntity>>> getRecent({int limit = 10});
}
