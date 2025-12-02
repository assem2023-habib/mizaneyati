import 'package:uuid/uuid.dart';
import '../../domain/models/transaction_type.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../core/utils/error_mapper.dart';
import '../../domain/entities/transaction_entity.dart';
import '../local/daos/transactions_dao.dart';
import '../local/daos/accounts_dao.dart';
import '../local/mappers/transaction_mapper.dart';
import '../local/mappers/account_mapper.dart';

class TransactionRepository {
  final TransactionsDao _transactionsDao;
  final AccountsDao _accountsDao;
  final _uuid = const Uuid();

  TransactionRepository(this._transactionsDao, this._accountsDao);

  // Get all transactions
  Future<Result<List<TransactionEntity>>> getAllTransactions() async {
    try {
      final transactions = await _transactionsDao.getAllTransactions();
      final entities = transactions.map((t) => t.toEntity()).toList();
      return Success(entities);
    } on DatabaseException catch (e) {
      return Fail(DatabaseFailure(e.message, code: 'db_error'));
    } catch (e, stackTrace) {
      return Fail(mapDatabaseException(e, stackTrace));
    }
  }

  // Watch all transactions
  Stream<Result<List<TransactionEntity>>> watchAllTransactions() {
    try {
      return _transactionsDao.watchAllTransactions().map((transactions) {
        try {
          final entities = transactions.map((t) => t.toEntity()).toList();
          return Success(entities);
        } catch (e, stackTrace) {
          return Fail<List<TransactionEntity>>(
            mapDatabaseException(e, stackTrace),
          );
        }
      });
    } catch (e, stackTrace) {
      return Stream.value(Fail(mapDatabaseException(e, stackTrace)));
    }
  }

  // Get transactions by date range
  Future<Result<List<TransactionEntity>>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      if (start.isAfter(end)) {
        return const Fail(
          ValidationFailure(
            'تاريخ البداية يجب أن يكون قبل تاريخ النهاية',
            code: 'invalid_date_range',
          ),
        );
      }

      final transactions = await _transactionsDao.getTransactionsByDateRange(
        start,
        end,
      );
      final entities = transactions.map((t) => t.toEntity()).toList();
      return Success(entities);
    } on DatabaseException catch (e) {
      return Fail(DatabaseFailure(e.message, code: 'db_error'));
    } catch (e, stackTrace) {
      return Fail(mapDatabaseException(e, stackTrace));
    }
  }

  // Create transaction with account balance update
  Future<Result<String>> createTransaction({
    required double amount,
    required TransactionType type,
    required String categoryId,
    required String accountId,
    required DateTime date,
    String? note,
    String? receiptPath,
  }) async {
    try {
      // Validation
      if (amount <= 0) {
        return const Fail(
          ValidationFailure(
            'المبلغ يجب أن يكون أكبر من صفر',
            code: 'invalid_amount',
          ),
        );
      }

      final id = _uuid.v4();

      final entity = TransactionEntity(
        id: id,
        amountMinor: (amount * 100).toInt(), // Convert to minor units
        type: type,
        categoryId: categoryId,
        accountId: accountId,
        date: date,
        note: note,
        receiptPath: receiptPath,
        createdAt: DateTime.now(),
      );

      await _transactionsDao.insertTransaction(entity.toCompanion());

      // Update account balance
      final balanceResult = await _updateAccountBalance(
        accountId,
        amount,
        type,
      );
      if (balanceResult is Fail) {
        // Rollback transaction if balance update fails
        await _transactionsDao.deleteTransaction(id);
        return Fail<String>((balanceResult).failure);
      }

      return Success(id);
    } on ValidationException catch (e) {
      return Fail(ValidationFailure(e.message, code: 'validation_error'));
    } on DatabaseException catch (e) {
      return Fail(DatabaseFailure(e.message, code: 'db_error'));
    } catch (e, stackTrace) {
      return Fail(mapDatabaseException(e, stackTrace));
    }
  }

  // Update transaction
  Future<Result<bool>> updateTransaction(TransactionEntity transaction) async {
    try {
      // Validation
      if (transaction.amountMinor <= 0) {
        return const Fail(
          ValidationFailure(
            'المبلغ يجب أن يكون أكبر من صفر',
            code: 'invalid_amount',
          ),
        );
      }

      final result = await _transactionsDao.updateTransaction(
        transaction.toCompanion(),
      );
      return Success(result);
    } on ValidationException catch (e) {
      return Fail(ValidationFailure(e.message, code: 'validation_error'));
    } on DatabaseException catch (e) {
      return Fail(DatabaseFailure(e.message, code: 'db_error'));
    } catch (e, stackTrace) {
      return Fail(mapDatabaseException(e, stackTrace));
    }
  }

  // Delete transaction with account balance update
  Future<Result<int>> deleteTransaction(String id) async {
    try {
      // Get transaction first to update account balance
      final transactionsResult = await getAllTransactions();
      if (transactionsResult is Fail) {
        return Fail<int>((transactionsResult as Fail).failure);
      }

      final transactions =
          (transactionsResult as Success<List<TransactionEntity>>).value;
      final transaction = transactions.where((t) => t.id == id).firstOrNull;

      if (transaction == null) {
        return const Fail(
          NotFoundFailure('العملية غير موجودة', code: 'transaction_not_found'),
        );
      }

      // Delete transaction
      final result = await _transactionsDao.deleteTransaction(id);

      // Reverse the account balance change
      if (result > 0) {
        final reverseType = transaction.type == TransactionType.expense
            ? TransactionType.income
            : TransactionType.expense;
        await _updateAccountBalance(
          transaction.accountId,
          transaction.amountMinor / 100.0, // Convert back to main units
          reverseType,
        );
      }

      return Success(result);
    } on DatabaseException catch (e) {
      return Fail(DatabaseFailure(e.message, code: 'db_error'));
    } catch (e, stackTrace) {
      return Fail(mapDatabaseException(e, stackTrace));
    }
  }

  // Private helper to update account balance
  Future<Result<void>> _updateAccountBalance(
    String accountId,
    double amount,
    TransactionType type,
  ) async {
    try {
      final account = await _accountsDao.getAccountById(accountId);
      if (account == null) {
        return const Fail(
          NotFoundFailure('الحساب غير موجود', code: 'account_not_found'),
        );
      }

      final accountEntity = account.toEntity();
      double newBalance =
          accountEntity.balanceMinor / 100.0; // Convert to main units

      if (type == TransactionType.expense) {
        newBalance -= amount;
      } else if (type == TransactionType.income) {
        newBalance += amount;
      }

      // Check for negative balance
      if (newBalance < 0) {
        return Fail(
          ValidationFailure(
            'الرصيد غير كافٍ',
            code: 'insufficient_balance',
            info: {
              'currentBalance': accountEntity.balanceMinor / 100.0,
              'requiredAmount': amount,
            },
          ),
        );
      }

      final updatedAccount = accountEntity.copyWith(
        balanceMinor: (newBalance * 100).toInt(),
      );
      await _accountsDao.updateAccount(updatedAccount.toCompanion());

      return const Success(null);
    } on DatabaseException catch (e) {
      return Fail(DatabaseFailure(e.message, code: 'db_error'));
    } catch (e, stackTrace) {
      return Fail(mapDatabaseException(e, stackTrace));
    }
  }
}
