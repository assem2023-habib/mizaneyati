// lib/domain/repositories/account_repository.dart
import '../entities/account_entity.dart';
import '../../core/utils/result.dart';

/// Abstract repository for Account operations
///
/// This defines the contract that the data layer must implement.
/// All mutation methods return Future<Result<T>> for error handling.
/// Reactive queries return Stream for real-time updates.
abstract class AccountRepository {
  /// Creates a new account and returns its ID
  Future<Result<String>> create(AccountEntity account);

  /// Updates an existing account
  Future<Result<void>> update(AccountEntity account);

  /// Deletes an account by ID
  Future<Result<void>> delete(String accountId);

  /// Gets an account by ID
  Future<Result<AccountEntity>> getById(String accountId);

  /// Gets all accounts
  Future<Result<List<AccountEntity>>> getAll();

  /// Gets all active accounts
  Future<Result<List<AccountEntity>>> getActiveAccounts();

  /// Watches all accounts for real-time updates
  Stream<List<AccountEntity>> watchAll();

  /// Watches active accounts for real-time updates
  Stream<List<AccountEntity>> watchActiveAccounts();

  /// Counts transactions for an account
  Future<Result<int>> countTransactions(String accountId);

  /// Adjusts account balance by a delta (can be negative)
  ///
  /// This is used internally by transaction operations
  Future<Result<void>> adjustBalance(String accountId, int deltaMinor);

  /// Gets total balance across all active accounts
  Future<Result<int>> getTotalBalance();
}
