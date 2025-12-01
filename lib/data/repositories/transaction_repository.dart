import 'package:uuid/uuid.dart';
import '../../core/constants/transaction_type.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/account_entity.dart';
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
  Future<List<TransactionEntity>> getAllTransactions() async {
    final transactions = await _transactionsDao.getAllTransactions();
    return transactions.map((t) => t.toEntity()).toList();
  }

  // Watch all transactions
  Stream<List<TransactionEntity>> watchAllTransactions() {
    return _transactionsDao.watchAllTransactions().map(
      (transactions) => transactions.map((t) => t.toEntity()).toList(),
    );
  }

  // Get transactions by date range
  Future<List<TransactionEntity>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final transactions = await _transactionsDao.getTransactionsByDateRange(
      start,
      end,
    );
    return transactions.map((t) => t.toEntity()).toList();
  }

  // Create transaction with account balance update
  Future<String> createTransaction({
    required double amount,
    required TransactionType type,
    required String categoryId,
    required String accountId,
    required DateTime date,
    String? note,
    String? receiptPath,
  }) async {
    final id = _uuid.v4();

    final entity = TransactionEntity(
      id: id,
      amount: amount,
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
    await _updateAccountBalance(accountId, amount, type);

    return id;
  }

  // Update transaction
  Future<bool> updateTransaction(TransactionEntity transaction) async {
    return await _transactionsDao.updateTransaction(transaction.toCompanion());
  }

  // Delete transaction with account balance update
  Future<int> deleteTransaction(String id) async {
    // Get transaction first to update account balance
    final transactions = await getAllTransactions();
    final transaction = transactions.firstWhere((t) => t.id == id);

    // Delete transaction
    final result = await _transactionsDao.deleteTransaction(id);

    // Reverse the account balance change
    if (result > 0) {
      final reverseType = transaction.type == TransactionType.expense
          ? TransactionType.income
          : TransactionType.expense;
      await _updateAccountBalance(
        transaction.accountId,
        transaction.amount,
        reverseType,
      );
    }

    return result;
  }

  // Private helper to update account balance
  Future<void> _updateAccountBalance(
    String accountId,
    double amount,
    TransactionType type,
  ) async {
    final account = await _accountsDao.getAccountById(accountId);
    if (account != null) {
      final accountEntity = account.toEntity();
      double newBalance = accountEntity.balance;

      if (type == TransactionType.expense) {
        newBalance -= amount;
      } else if (type == TransactionType.income) {
        newBalance += amount;
      }

      final updatedAccount = accountEntity.copyWith(balance: newBalance);
      await _accountsDao.updateAccount(updatedAccount.toCompanion());
    }
  }
}
