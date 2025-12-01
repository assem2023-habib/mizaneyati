// lib/data/local/daos/accounts_dao_example.dart
//
// مثال توضيحي لكيفية دمج DbLogger في DAOs
// يمكنك نسخ هذا النمط واستخدامه في DAOs الموجودة

import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';
import '../../../core/logging/db_logger.dart';

/// مثال على DAO مع تكامل DbLogger
///
/// يوضح:
/// 1. تسجيل الاستعلامات مع قياس الوقت
/// 2. اكتشاف الاستعلامات البطيئة
/// 3. تسجيل الأخطاء مع السياق الكامل
@DriftAccessor(tables: [Accounts])
class AccountsDaoExample extends DatabaseAccessor<AppDatabase>
    with _$AccountsDaoExampleMixin {
  AccountsDaoExample(AppDatabase db) : super(db);

  /// الحصول على جميع الحسابات مع logging
  Future<List<Account>> getAllAccountsWithLogging() async {
    final sw = Stopwatch()..start();

    try {
      // تنفيذ الاستعلام
      final result = await select(accounts).get();

      sw.stop();

      // تسجيل الاستعلام
      DbLogger().logQuery('SELECT * FROM accounts', duration: sw.elapsed);

      // تحذير للاستعلامات البطيئة
      if (sw.elapsedMilliseconds > DbLogger.slowQueryThresholdMs) {
        DbLogger().logWarning(
          'Slow query detected: getAllAccounts took ${sw.elapsedMilliseconds}ms',
        );
      }

      return result;
    } catch (e, st) {
      // تسجيل الخطأ
      DbLogger().logError('Error fetching all accounts', e, st, {
        'operation': 'getAllAccounts',
      });
      rethrow;
    }
  }

  /// الحصول على حساب بواسطة ID مع logging
  Future<Account?> getAccountByIdWithLogging(String id) async {
    final sw = Stopwatch()..start();

    try {
      final result = await (select(
        accounts,
      )..where((a) => a.id.equals(id))).getSingleOrNull();

      sw.stop();

      DbLogger().logQuery(
        'SELECT * FROM accounts WHERE id = ?',
        params: {'id': id},
        duration: sw.elapsed,
      );

      if (sw.elapsedMilliseconds > DbLogger.slowQueryThresholdMs) {
        DbLogger().logWarning(
          'Slow query: getAccountById took ${sw.elapsedMilliseconds}ms',
        );
      }

      return result;
    } catch (e, st) {
      DbLogger().logError('Error fetching account by id', e, st, {
        'accountId': id,
      });
      rethrow;
    }
  }

  /// إدراج حساب جديد مع logging
  Future<int> insertAccountWithLogging(AccountsCompanion account) async {
    final sw = Stopwatch()..start();

    try {
      DbLogger().logDebug('Inserting new account: ${account.name.value}');

      final result = await into(accounts).insert(account);

      sw.stop();

      DbLogger().logQuery(
        'INSERT INTO accounts VALUES (...)',
        params: {
          'name': account.name.value,
          'balance': account.balance.value,
          'type': account.type.value,
        },
        duration: sw.elapsed,
      );

      DbLogger().logInfo('Account created successfully', {
        'accountId': account.id.value,
        'name': account.name.value,
      });

      return result;
    } catch (e, st) {
      DbLogger().logError('Error inserting account', e, st, {
        'accountName': account.name.value,
      });
      rethrow;
    }
  }

  /// تحديث حساب مع logging
  Future<bool> updateAccountWithLogging(AccountsCompanion account) async {
    final sw = Stopwatch()..start();

    try {
      DbLogger().logDebug('Updating account: ${account.id.value}');

      final result = await update(accounts).replace(account);

      sw.stop();

      DbLogger().logQuery(
        'UPDATE accounts SET ... WHERE id = ?',
        params: {'id': account.id.value},
        duration: sw.elapsed,
      );

      if (result) {
        DbLogger().logInfo('Account updated successfully', {
          'accountId': account.id.value,
        });
      } else {
        DbLogger().logWarning(
          'Account update affected 0 rows (account may not exist)',
        );
      }

      return result;
    } catch (e, st) {
      DbLogger().logError('Error updating account', e, st, {
        'accountId': account.id.value,
      });
      rethrow;
    }
  }

  /// حذف حساب مع logging
  Future<int> deleteAccountWithLogging(String id) async {
    final sw = Stopwatch()..start();

    try {
      DbLogger().logDebug('Deleting account: $id');

      final result = await (delete(
        accounts,
      )..where((a) => a.id.equals(id))).go();

      sw.stop();

      DbLogger().logQuery(
        'DELETE FROM accounts WHERE id = ?',
        params: {'id': id},
        duration: sw.elapsed,
      );

      if (result > 0) {
        DbLogger().logInfo('Account deleted successfully', {
          'accountId': id,
          'rowsAffected': result,
        });
      } else {
        DbLogger().logWarning('Delete affected 0 rows (account may not exist)');
      }

      return result;
    } catch (e, st) {
      DbLogger().logError('Error deleting account', e, st, {'accountId': id});
      rethrow;
    }
  }

  /// استعلام مخصص معقد مع logging
  Future<List<Map<String, dynamic>>> getAccountSummaryWithLogging() async {
    final sw = Stopwatch()..start();

    try {
      // استعلام مخصص معقد
      final query = '''
        SELECT 
          a.id,
          a.name,
          a.balance,
          COUNT(t.id) as transaction_count,
          COALESCE(SUM(CASE WHEN t.type = 'expense' THEN t.amount ELSE 0 END), 0) as total_expenses,
          COALESCE(SUM(CASE WHEN t.type = 'income' THEN t.amount ELSE 0 END), 0) as total_income
        FROM accounts a
        LEFT JOIN transactions t ON a.id = t.account_id
        WHERE a.is_active = 1
        GROUP BY a.id
        ORDER BY a.created_at DESC
      ''';

      final result = await customSelect(query).get();

      sw.stop();

      DbLogger().logQuery(
        'Complex account summary query',
        duration: sw.elapsed,
      );

      // تحذير خاص للاستعلامات المعقدة
      if (sw.elapsedMilliseconds > 100) {
        DbLogger().logWarning(
          'Complex query took ${sw.elapsedMilliseconds}ms - consider optimization or caching',
        );
      }

      return result.map((row) => row.data).toList();
    } catch (e, st) {
      DbLogger().logError('Error in account summary query', e, st, {
        'operation': 'getAccountSummary',
      });
      rethrow;
    }
  }
}

// معالج Transaction (صفقة قاعدة بيانات) يمكن استخدامه مع الـ mixin
mixin _$AccountsDaoExampleMixin on DatabaseAccessor<AppDatabase> {
  $AccountsTable get accounts => attachedDatabase.accounts;
}
