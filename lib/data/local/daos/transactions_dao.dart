import 'package:drift/drift.dart';
import '../db/app_database.dart';
import '../db/tables.dart';

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

  // Get transaction by ID
  Future<Transaction?> getById(String id) => (select(
    transactions,
  )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  // Get transactions by account
  Future<List<Transaction>> getTransactionsByAccount(
    String accountId, {
    int? limit,
    int? offset,
  }) =>
      (select(transactions)
            ..where((tbl) => tbl.accountId.equals(accountId))
            ..limit(limit ?? -1, offset: offset)
            ..orderBy([
              (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
            ]))
          .get();

  // Get transactions by category
  Future<List<Transaction>> getTransactionsByCategory(
    String categoryId, {
    int? limit,
    int? offset,
  }) =>
      (select(transactions)
            ..where((tbl) => tbl.categoryId.equals(categoryId))
            ..limit(limit ?? -1, offset: offset)
            ..orderBy([
              (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
            ]))
          .get();

  // Get transactions by type
  Future<List<Transaction>> getTransactionsByType(
    TransactionType type, {
    int? limit,
    int? offset,
  }) =>
      (select(transactions)
            ..where(
              (tbl) => tbl.type.equals(type.name),
            ) // Assuming type is stored as string/enum name
            ..limit(limit ?? -1, offset: offset)
            ..orderBy([
              (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
            ]))
          .get();

  // Get recent transactions
  Future<List<Transaction>> getRecentTransactions({int limit = 10}) =>
      (select(transactions)
            ..orderBy([
              (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
            ])
            ..limit(limit))
          .get();

  // Watch transactions by date range
  Stream<List<Transaction>> watchTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) =>
      (select(transactions)
            ..where((tbl) => tbl.date.isBetween(Variable(start), Variable(end)))
            ..orderBy([
              (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
            ]))
          .watch();

  // Watch transactions by account
  Stream<List<Transaction>> watchTransactionsByAccount(String accountId) =>
      (select(transactions)
            ..where((tbl) => tbl.accountId.equals(accountId))
            ..orderBy([
              (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
            ]))
          .watch();

  // Count all transactions
  Future<int> countAll() => select(transactions).get().then(
    (l) => l.length,
  ); // Simple count, optimize later with customExpression if needed

  // Count by account
  Future<int> countByAccount(String accountId) =>
      (select(transactions)..where((tbl) => tbl.accountId.equals(accountId)))
          .get()
          .then((l) => l.length);

  // Count by category
  Future<int> countByCategory(String categoryId) =>
      (select(transactions)..where((tbl) => tbl.categoryId.equals(categoryId)))
          .get()
          .then((l) => l.length);
}
