import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'accounts_dao.g.dart';

@DriftAccessor(tables: [Accounts])
class AccountsDao extends DatabaseAccessor<AppDatabase>
    with _$AccountsDaoMixin {
  AccountsDao(AppDatabase db) : super(db);

  // Get all accounts
  Future<List<Account>> getAllAccounts() => select(accounts).get();

  // Watch all accounts
  Stream<List<Account>> watchAllAccounts() => select(accounts).watch();

  // Get account by ID
  Future<Account?> getAccountById(String id) =>
      (select(accounts)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  // Insert account
  Future<int> insertAccount(AccountsCompanion account) =>
      into(accounts).insert(account);

  // Update account
  Future<bool> updateAccount(AccountsCompanion account) =>
      update(accounts).replace(account);

  // Delete account
  Future<int> deleteAccount(String id) =>
      (delete(accounts)..where((tbl) => tbl.id.equals(id))).go();

  // Get active accounts
  Future<List<Account>> getActiveAccounts() =>
      (select(accounts)..where((tbl) => tbl.isActive.equals(true))).get();

  // Watch active accounts
  Stream<List<Account>> watchActiveAccounts() =>
      (select(accounts)..where((tbl) => tbl.isActive.equals(true))).watch();

  // Update balance (atomic update helper)
  Future<void> updateBalance(String id, int deltaMinor) async {
    // Note: This should ideally be part of a transaction block in the repository
    // But we can provide a helper here.
    // However, Drift doesn't support "UPDATE accounts SET balance = balance + delta" directly in Dart API easily without custom query
    // or reading first.
    // Custom query is better for atomicity if not inside a transaction block, but inside transaction block read-modify-write is fine.
    // Let's use custom query for efficiency.
    await customStatement(
      'UPDATE accounts SET balance_minor = balance_minor + ? WHERE id = ?',
      [deltaMinor, id],
    );
  }
}
