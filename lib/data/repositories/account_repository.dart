import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/account_type.dart';
import '../local/app_database.dart';
import '../local/daos/accounts_dao.dart';
import '../local/tables.dart';

class AccountRepository {
  final AccountsDao _accountsDao;
  final _uuid = const Uuid();

  AccountRepository(this._accountsDao);

  // Get all accounts
  Future<List<Account>> getAllAccounts() => _accountsDao.getAllAccounts();

  // Watch all accounts
  Stream<List<Account>> watchAllAccounts() => _accountsDao.watchAllAccounts();

  // Get active accounts
  Future<List<Account>> getActiveAccounts() => _accountsDao.getActiveAccounts();

  // Get account by ID
  Future<Account?> getAccountById(String id) => _accountsDao.getAccountById(id);

  // Create account
  Future<String> createAccount({
    required String name,
    required double balance,
    required AccountType type,
    required String color,
    String? icon,
  }) async {
    final id = _uuid.v4();
    final account = AccountsCompanion(
      id: Value(id),
      name: Value(name),
      balance: Value(balance),
      type: Value(type),
      color: Value(color),
      icon: Value(icon),
      isActive: const Value(true),
      createdAt: Value(DateTime.now()),
    );
    await _accountsDao.insertAccount(account);
    return id;
  }

  // Update account
  Future<bool> updateAccount({
    required String id,
    String? name,
    double? balance,
    AccountType? type,
    String? color,
    String? icon,
    bool? isActive,
  }) async {
    final account = AccountsCompanion(
      id: Value(id),
      name: name != null ? Value(name) : const Value.absent(),
      balance: balance != null ? Value(balance) : const Value.absent(),
      type: type != null ? Value(type) : const Value.absent(),
      color: color != null ? Value(color) : const Value.absent(),
      icon: icon != null ? Value(icon) : const Value.absent(),
      isActive: isActive != null ? Value(isActive) : const Value.absent(),
    );
    return await _accountsDao.updateAccount(account);
  }

  // Delete account
  Future<int> deleteAccount(String id) => _accountsDao.deleteAccount(id);

  // Update balance
  Future<bool> updateBalance(String id, double newBalance) async {
    return await updateAccount(id: id, balance: newBalance);
  }
}
