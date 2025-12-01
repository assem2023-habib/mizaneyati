import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/account_type.dart';
import '../../domain/entities/account_entity.dart';
import '../local/app_database.dart';
import '../local/daos/accounts_dao.dart';
import '../local/mappers/account_mapper.dart';

class AccountRepository {
  final AccountsDao _accountsDao;
  final _uuid = const Uuid();

  AccountRepository(this._accountsDao);

  // Get all accounts
  Future<List<AccountEntity>> getAllAccounts() async {
    final accounts = await _accountsDao.getAllAccounts();
    return accounts.map((a) => a.toEntity()).toList();
  }

  // Watch all accounts
  Stream<List<AccountEntity>> watchAllAccounts() {
    return _accountsDao.watchAllAccounts().map(
      (accounts) => accounts.map((a) => a.toEntity()).toList(),
    );
  }

  // Get active accounts
  Future<List<AccountEntity>> getActiveAccounts() async {
    final accounts = await _accountsDao.getActiveAccounts();
    return accounts.map((a) => a.toEntity()).toList();
  }

  // Get account by ID
  Future<AccountEntity?> getAccountById(String id) async {
    final account = await _accountsDao.getAccountById(id);
    return account?.toEntity();
  }

  // Create account
  Future<String> createAccount({
    required String name,
    required double balance,
    required AccountType type,
    required String color,
    String? icon,
  }) async {
    final id = _uuid.v4();
    final entity = AccountEntity(
      id: id,
      name: name,
      balance: balance,
      type: type,
      color: color,
      icon: icon,
      isActive: true,
      createdAt: DateTime.now(),
    );

    await _accountsDao.insertAccount(entity.toCompanion());
    return id;
  }

  // Update account
  Future<bool> updateAccount(AccountEntity account) async {
    return await _accountsDao.updateAccount(account.toCompanion());
  }

  // Delete account
  Future<int> deleteAccount(String id) => _accountsDao.deleteAccount(id);

  // Update balance
  Future<bool> updateBalance(String id, double newBalance) async {
    final account = await getAccountById(id);
    if (account != null) {
      final updated = account.copyWith(balance: newBalance);
      return await updateAccount(updated);
    }
    return false;
  }
}
