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
}
