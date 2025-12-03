// lib/data/repositories/transaction_repository_impl.dart
import 'package:drift/drift.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/models/transaction_type.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';
import '../local/db/app_database.dart';
import '../local/daos/transactions_dao.dart';
import '../local/daos/accounts_dao.dart';
import '../local/mappers/transaction_mapper.dart';
import '../local/mappers/account_mapper.dart';
import '../local/mappers/error_mapper.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final AppDatabase _db;
  final TransactionsDao _transactionsDao;
  final AccountsDao _accountsDao;

  TransactionRepositoryImpl(this._db)
    : _transactionsDao = _db.transactionsDao,
      _accountsDao = _db.accountsDao;

  @override
  Future<Result<String>> createTransaction(
    TransactionEntity tx, {
    required AccountEntity account,
    AccountEntity? toAccount,
  }) async {
    try {
      // Atomic transaction
      await _db.transaction(() async {
        // 1. Insert Transaction
        final companion = tx.toCompanion();
        await _transactionsDao.insertTransaction(companion);

        // 2. Update Account Balances (using Domain State)
        await _accountsDao.updateAccount(account.toCompanion());

        if (toAccount != null) {
          await _accountsDao.updateAccount(toAccount.toCompanion());
        }
      });

      return Success(tx.id);
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<void>> updateTransaction(
    TransactionEntity tx, {
    required List<AccountEntity> affectedAccounts,
  }) async {
    try {
      await _db.transaction(() async {
        // 1. Update Transaction
        final companion = tx.toCompanion();
        await _transactionsDao.updateTransaction(companion);

        // 2. Update Affected Accounts
        for (final acc in affectedAccounts) {
          await _accountsDao.updateAccount(acc.toCompanion());
        }
      });

      return const Success(null);
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<void>> deleteTransaction(
    String txId, {
    required AccountEntity account,
    AccountEntity? toAccount,
  }) async {
    try {
      await _db.transaction(() async {
        // 1. Delete Transaction
        await _transactionsDao.deleteTransaction(txId);

        // 2. Update Account Balances
        await _accountsDao.updateAccount(account.toCompanion());

        if (toAccount != null) {
          await _accountsDao.updateAccount(toAccount.toCompanion());
        }
      });
      return const Success(null);
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<TransactionEntity>> getById(String txId) async {
    try {
      final tx = await _transactionsDao.getById(txId);
      if (tx == null) {
        return const Fail(
          NotFoundFailure('المعاملة غير موجودة', code: 'tx_not_found'),
        );
      }
      return Success(tx.toEntity());
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<List<TransactionEntity>>> getByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final txs = await _transactionsDao.getTransactionsByDateRange(start, end);
      return Success(txs.map((e) => e.toEntity()).toList());
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<List<TransactionEntity>>> getByAccount(
    String accountId, {
    int? limit,
    int? offset,
  }) async {
    try {
      final txs = await _transactionsDao.getTransactionsByAccount(
        accountId,
        limit: limit,
        offset: offset,
      );
      return Success(txs.map((e) => e.toEntity()).toList());
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<List<TransactionEntity>>> getByCategory(
    String categoryId, {
    int? limit,
    int? offset,
  }) async {
    try {
      final txs = await _transactionsDao.getTransactionsByCategory(
        categoryId,
        limit: limit,
        offset: offset,
      );
      return Success(txs.map((e) => e.toEntity()).toList());
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<List<TransactionEntity>>> getByType(
    TransactionType type, {
    int? limit,
    int? offset,
  }) async {
    try {
      final txs = await _transactionsDao.getTransactionsByType(
        type,
        limit: limit,
        offset: offset,
      );
      return Success(txs.map((e) => e.toEntity()).toList());
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<List<TransactionEntity>>> getPaginated({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      // Using custom query or just getAll with limit if DAO supported it.
      // For now, let's use getRecent which has limit, but we need offset.
      // Let's assume we can add getPaginated to DAO or use custom select.
      // For simplicity, I'll use a custom query here.
      final rows = await _db
          .customSelect(
            'SELECT * FROM transactions ORDER BY date DESC LIMIT ? OFFSET ?',
            variables: [Variable.withInt(limit), Variable.withInt(offset)],
          )
          .get();

      final txs = rows
          .map(
            (row) => Transaction(
              id: row.read<String>('id'),
              amount: row.read<double>('amount'),
              type: TransactionType.values.firstWhere(
                (e) => e.name == row.read<String>('type'),
              ),
              categoryId: row.read<String>('category_id'),
              accountId: row.read<String>('account_id'),
              date: row.read<DateTime>('date'),
              note: row.read<String?>('note'),
              receiptPath: row.read<String?>('receipt_path'),
              createdAt: row.read<DateTime>('created_at'),
            ),
          )
          .toList();

      return Success(txs.map((e) => e.toEntity()).toList());
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }

  @override
  Stream<List<TransactionEntity>> watchAll({int? limit, int? offset}) {
    // DAO watchAll doesn't support limit/offset yet, but we can use it raw
    // or implement specific watcher.
    // For now returning all (be careful with large datasets).
    return _transactionsDao.watchAllTransactions().map(
      (txs) => txs.map((e) => e.toEntity()).toList(),
    );
  }

  @override
  Stream<List<TransactionEntity>> watchByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return _transactionsDao
        .watchTransactionsByDateRange(start, end)
        .map((txs) => txs.map((e) => e.toEntity()).toList());
  }

  @override
  Stream<List<TransactionEntity>> watchByAccount(String accountId) {
    return _transactionsDao
        .watchTransactionsByAccount(accountId)
        .map((txs) => txs.map((e) => e.toEntity()).toList());
  }

  @override
  Future<Result<int>> countAll() async {
    try {
      final count = await _transactionsDao.countAll();
      return Success(count);
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<int>> countByAccount(String accountId) async {
    try {
      final count = await _transactionsDao.countByAccount(accountId);
      return Success(count);
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<int>> countByCategory(String categoryId) async {
    try {
      final count = await _transactionsDao.countByCategory(categoryId);
      return Success(count);
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<int>> getTotalAmountByType(
    TransactionType type,
    DateTime start,
    DateTime end,
  ) async {
    try {
      // Custom query for sum
      final result = await _db
          .customSelect(
            'SELECT SUM(amount) as total FROM transactions WHERE type = ? AND date BETWEEN ? AND ?',
            variables: [
              Variable.withString(type.name),
              Variable.withDateTime(start),
              Variable.withDateTime(end),
            ],
          )
          .getSingle();

      final totalDouble = result.read<double?>('total') ?? 0.0;
      return Success((totalDouble * 100).toInt());
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<List<TransactionEntity>>> getRecent({int limit = 10}) async {
    try {
      final txs = await _transactionsDao.getRecentTransactions(limit: limit);
      return Success(txs.map((e) => e.toEntity()).toList());
    } catch (e, st) {
      return Fail(mapExceptionToFailure(e, st));
    }
  }
}
