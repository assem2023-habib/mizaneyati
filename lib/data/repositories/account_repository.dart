import 'package:uuid/uuid.dart';
import '../../domain/models/account_type.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../core/utils/error_mapper.dart';
import '../../domain/entities/account_entity.dart';
import '../local/daos/accounts_dao.dart';
import '../local/mappers/account_mapper.dart';

class AccountRepository {
  final AccountsDao _accountsDao;
  final _uuid = const Uuid();

  AccountRepository(this._accountsDao);

  // Get all accounts
  Future<Result<List<AccountEntity>>> getAllAccounts() async {
    try {
      final accounts = await _accountsDao.getAllAccounts();
      final entities = accounts.map((a) => a.toEntity()).toList();
      return Success(entities);
    } on DatabaseException catch (e) {
      return Fail(DatabaseFailure(e.message, code: 'db_error'));
    } catch (e, stackTrace) {
      return Fail(mapDatabaseException(e, stackTrace));
    }
  }

  // Watch all accounts
  Stream<Result<List<AccountEntity>>> watchAllAccounts() {
    try {
      return _accountsDao.watchAllAccounts().map((accounts) {
        try {
          final entities = accounts.map((a) => a.toEntity()).toList();
          return Success(entities);
        } catch (e, stackTrace) {
          return Fail<List<AccountEntity>>(mapDatabaseException(e, stackTrace));
        }
      });
    } catch (e, stackTrace) {
      return Stream.value(Fail(mapDatabaseException(e, stackTrace)));
    }
  }

  // Get active accounts
  Future<Result<List<AccountEntity>>> getActiveAccounts() async {
    try {
      final accounts = await _accountsDao.getActiveAccounts();
      final entities = accounts.map((a) => a.toEntity()).toList();
      return Success(entities);
    } on DatabaseException catch (e) {
      return Fail(DatabaseFailure(e.message, code: 'db_error'));
    } catch (e, stackTrace) {
      return Fail(mapDatabaseException(e, stackTrace));
    }
  }

  // Get account by ID
  Future<Result<AccountEntity>> getAccountById(String id) async {
    try {
      final account = await _accountsDao.getAccountById(id);
      if (account == null) {
        return const Fail(
          NotFoundFailure('الحساب غير موجود', code: 'account_not_found'),
        );
      }
      return Success(account.toEntity());
    } on DatabaseException catch (e) {
      return Fail(DatabaseFailure(e.message, code: 'db_error'));
    } catch (e, stackTrace) {
      return Fail(mapDatabaseException(e, stackTrace));
    }
  }

  // Create account
  Future<Result<String>> createAccount({
    required String name,
    required double balance,
    required AccountType type,
    required String color,
    String? icon,
  }) async {
    try {
      // Validation
      if (name.trim().isEmpty) {
        return const Fail(
          ValidationFailure('اسم الحساب مطلوب', code: 'empty_name'),
        );
      }

      if (balance < 0) {
        return const Fail(
          ValidationFailure(
            'الرصيد لا يمكن أن يكون سالباً',
            code: 'negative_balance',
          ),
        );
      }

      final id = _uuid.v4();
      final entity = AccountEntity(
        id: id,
        name: name,
        balanceMinor: (balance * 100).toInt(), // Convert to minor units
        type: type,
        color: color,
        icon: icon,
        isActive: true,
        createdAt: DateTime.now(),
      );

      await _accountsDao.insertAccount(entity.toCompanion());
      return Success(id);
    } on ValidationException catch (e) {
      return Fail(ValidationFailure(e.message, code: 'validation_error'));
    } on DatabaseException catch (e) {
      return Fail(DatabaseFailure(e.message, code: 'db_error'));
    } catch (e, stackTrace) {
      return Fail(mapDatabaseException(e, stackTrace));
    }
  }

  // Update account
  Future<Result<bool>> updateAccount(AccountEntity account) async {
    try {
      // Validation
      if (account.name.trim().isEmpty) {
        return const Fail(
          ValidationFailure('اسم الحساب مطلوب', code: 'empty_name'),
        );
      }

      final result = await _accountsDao.updateAccount(account.toCompanion());
      return Success(result);
    } on ValidationException catch (e) {
      return Fail(ValidationFailure(e.message, code: 'validation_error'));
    } on DatabaseException catch (e) {
      return Fail(DatabaseFailure(e.message, code: 'db_error'));
    } catch (e, stackTrace) {
      return Fail(mapDatabaseException(e, stackTrace));
    }
  }

  // Delete account
  Future<Result<int>> deleteAccount(String id) async {
    try {
      final result = await _accountsDao.deleteAccount(id);
      if (result == 0) {
        return const Fail(
          NotFoundFailure('الحساب غير موجود', code: 'account_not_found'),
        );
      }
      return Success(result);
    } on DatabaseException catch (e) {
      return Fail(DatabaseFailure(e.message, code: 'db_error'));
    } catch (e, stackTrace) {
      return Fail(mapDatabaseException(e, stackTrace));
    }
  }

  // Update balance
  Future<Result<bool>> updateBalance(String id, double newBalance) async {
    try {
      if (newBalance < 0) {
        return const Fail(
          ValidationFailure(
            'الرصيد لا يمكن أن يكون سالباً',
            code: 'negative_balance',
          ),
        );
      }

      final accountResult = await getAccountById(id);
      if (accountResult is Fail) {
        return Fail<bool>((accountResult as Fail).failure);
      }

      final account = (accountResult as Success<AccountEntity>).value;
      final updated = account.copyWith(
        balanceMinor: (newBalance * 100).toInt(),
      );
      return await updateAccount(updated);
    } on DatabaseException catch (e) {
      return Fail(DatabaseFailure(e.message, code: 'db_error'));
    } catch (e, stackTrace) {
      return Fail(mapDatabaseException(e, stackTrace));
    }
  }
}
