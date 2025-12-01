import 'package:drift/drift.dart';
import '../errors/failures.dart';

/// Maps SQLite/Drift exceptions to domain Failures
Failure mapDatabaseException(Object e, [StackTrace? stackTrace]) {
  final msg = e.toString();

  // UNIQUE constraint violation
  if (msg.contains('UNIQUE constraint failed')) {
    return const DatabaseFailure(
      'عنصر مكرر موجود بالفعل',
      code: 'unique_constraint',
    );
  }

  // FOREIGN KEY constraint violation
  if (msg.contains('FOREIGN KEY constraint failed')) {
    return const DatabaseFailure(
      'لا يمكن حذف هذا العنصر لأنه مرتبط بعناصر أخرى',
      code: 'foreign_key_constraint',
    );
  }

  // NOT NULL constraint violation
  if (msg.contains('NOT NULL constraint failed')) {
    return const DatabaseFailure('حقل مطلوب فارغ', code: 'not_null_constraint');
  }

  // Drift wrapped exception
  if (e is DriftWrappedException) {
    return DatabaseFailure(
      'خطأ في قاعدة البيانات',
      code: 'drift_wrapped',
      info: {'error': e.toString()},
    );
  }

  // Generic database error
  return DatabaseFailure(
    'خطأ في قاعدة البيانات',
    code: 'db_unknown',
    info: {
      'error': msg,
      if (stackTrace != null) 'stack': stackTrace.toString(),
    },
  );
}
