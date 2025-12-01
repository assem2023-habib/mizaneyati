import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'transactions_dao.g.dart';

@DriftAccessor(tables: [Transactions, Categories, Accounts])
class TransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoMixin {
  TransactionsDao(AppDatabase db) : super(db);

  // Get all transactions
  Future<List<Transaction>> getAllTransactions() => select(transactions).get();

  // Watch all transactions
  Stream<List<Transaction>> watchAllTransactions() =>
      select(transactions).watch();

  // Get transactions by date range
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) => (select(
    transactions,
  )..where((tbl) => tbl.date.isBetween(Variable(start), Variable(end)))).get();

  // Insert transaction
  Future<int> insertTransaction(TransactionsCompanion transaction) =>
      into(transactions).insert(transaction);

  // Update transaction
  Future<bool> updateTransaction(TransactionsCompanion transaction) =>
      update(transactions).replace(transaction);

  // Delete transaction
  Future<int> deleteTransaction(String id) =>
      (delete(transactions)..where((tbl) => tbl.id.equals(id))).go();
}
