// lib/data/repositories/account_repository_impl.dart
import 'package:drift/drift.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/repositories/account_repository.dart';
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';
import '../local/db/app_database.dart';
import '../local/daos/accounts_dao.dart';
import '../local/mappers/account_mapper.dart';
import '../local/mappers/error_mapper.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountsDao _accountsDao;
  final AppDatabase _db; // Needed for transactions if required later

  AccountRepositoryImpl(this._db) : _accountsDao = _db.accountsDao;

  @override
  Future<Result<String>> create(AccountEntity account) async {
    try {
      final companion = account.toCompanion();
      await _accountsDao.insertAccount(companion);
      return Success(account.id);
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<void>> update(AccountEntity account) async {
    try {
      final companion = account.toCompanion();
      final result = await _accountsDao.updateAccount(companion);
      if (!result) {
        return const Fail(
          NotFoundFailure('الحساب غير موجود', code: 'account_not_found'),
        );
      }
      return const Success(null);
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<void>> delete(String accountId) async {
    try {
      final result = await _accountsDao.deleteAccount(accountId);
      if (result == 0) {
        return const Fail(
          NotFoundFailure('الحساب غير موجود', code: 'account_not_found'),
        );
      }
      return const Success(null);
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<AccountEntity>> getById(String accountId) async {
    try {
      final account = await _accountsDao.getAccountById(accountId);
      if (account == null) {
        return const Fail(
          NotFoundFailure('الحساب غير موجود', code: 'account_not_found'),
        );
      }
      return Success(account.toEntity());
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<List<AccountEntity>>> getAll() async {
    try {
      final accounts = await _accountsDao.getAllAccounts();
      return Success(accounts.map((e) => e.toEntity()).toList());
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<List<AccountEntity>>> getActiveAccounts() async {
    try {
      final accounts = await _accountsDao.getActiveAccounts();
      return Success(accounts.map((e) => e.toEntity()).toList());
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }

  @override
  Stream<List<AccountEntity>> watchAll() {
    return _accountsDao.watchAllAccounts().map(
      (accounts) => accounts.map((e) => e.toEntity()).toList(),
    );
  }

  @override
  Stream<List<AccountEntity>> watchActiveAccounts() {
    return _accountsDao.watchActiveAccounts().map(
      (accounts) => accounts.map((e) => e.toEntity()).toList(),
    );
  }

  @override
  Future<Result<int>> countTransactions(String accountId) async {
    try {
      // Accessing transactions table via custom query or TransactionsDao if available
      // Since we don't have direct access to TransactionsDao here easily without circular dependency or passing it in,
      // we can use the db instance to query.
      final count = await _db
          .customSelect(
            'SELECT COUNT(*) as c FROM transactions WHERE account_id = ?',
            variables: [Variable.withString(accountId)],
          )
          .map((row) => row.read<int>('c'))
          .getSingle();

      return Success(count);
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<void>> adjustBalance(String accountId, int deltaMinor) async {
    try {
      await _accountsDao.updateBalance(accountId, deltaMinor);
      return const Success(null);
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<int>> getTotalBalance() async {
    try {
      final accounts = await _accountsDao.getActiveAccounts();
      final total = accounts.fold(
        0,
        (sum, acc) => sum + ((acc.balance * 100).round()),
      );
      return Success(total);
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }
}
