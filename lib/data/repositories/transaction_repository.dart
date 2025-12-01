import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/transaction_type.dart';
import '../local/app_database.dart';
import '../local/daos/transactions_dao.dart';
import '../local/daos/accounts_dao.dart';

class TransactionRepository {
  final TransactionsDao _transactionsDao;
  final AccountsDao _accountsDao;
  final _uuid = const Uuid();

  TransactionRepository(this._transactionsDao, this._accountsDao);

  // Get all transactions
  Future<List<Transaction>> getAllTransactions() =>
      _transactionsDao.getAllTransactions();

  // Watch all transactions
  Stream<List<Transaction>> watchAllTransactions() =>
      _transactionsDao.watchAllTransactions();

  // Get transactions by date range
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) => _transactionsDao.getTransactionsByDateRange(start, end);

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

    // Create transaction
    final transaction = TransactionsCompanion(
      id: Value(id),
      amount: Value(amount),
      type: Value(type),
      categoryId: Value(categoryId),
      accountId: Value(accountId),
      date: Value(date),
      note: Value(note),
      receiptPath: Value(receiptPath),
      createdAt: Value(DateTime.now()),
    );
    await _transactionsDao.insertTransaction(transaction);

    // Update account balance
    await _updateAccountBalance(accountId, amount, type);

    return id;
  }

  // Update transaction
  Future<bool> updateTransaction({
    required String id,
    double? amount,
    TransactionType? type,
    String? categoryId,
    String? accountId,
    DateTime? date,
    String? note,
    String? receiptPath,
  }) async {
    final transaction = TransactionsCompanion(
      id: Value(id),
      amount: amount != null ? Value(amount) : const Value.absent(),
      type: type != null ? Value(type) : const Value.absent(),
      categoryId: categoryId != null ? Value(categoryId) : const Value.absent(),
      accountId: accountId != null ? Value(accountId) : const Value.absent(),
      date: date != null ? Value(date) : const Value.absent(),
      note: note != null ? Value(note) : const Value.absent(),
      receiptPath: receiptPath != null
          ? Value(receiptPath)
          : const Value.absent(),
    );
    return await _transactionsDao.updateTransaction(transaction);
  }

  // Delete transaction with account balance update
  Future<int> deleteTransaction(String id) async {
    // Get transaction first to update account balance
    final transactions = await _transactionsDao.getAllTransactions();
    final transaction = transactions.firstWhere((t) => t.id == id);

    // Delete transaction
    final result = await _transactionsDao.deleteTransaction(id);

    // Reverse the account balance change
    if (result > 0) {
      final reverseType = transaction.type == TransactionType.expense.name
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
      double newBalance = account.balance;

      if (type == TransactionType.expense) {
        newBalance -= amount;
      } else if (type == TransactionType.income) {
        newBalance += amount;
      }

      await _accountsDao.updateAccount(
        AccountsCompanion(id: Value(accountId), balance: Value(newBalance)),
      );
    }
  }
}
