// lib/data/repositories/error_mapper.dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import '../../core/errors/failures.dart';

/// Maps exceptions from Data Layer (Drift/SQLite) to Domain Failures
Failure mapExceptionToFailure(Object e, [StackTrace? stackTrace]) {
  final msg = e.toString();

  // Handle Drift/SQLite specific errors
  if (msg.contains('UNIQUE constraint failed')) {
    return DatabaseFailure(
      'توجد بيانات مكررة (قيد فريد)',
      code: 'db_unique_constraint',
      info: {'error': msg},
    );
  }

  if (msg.contains('FOREIGN KEY constraint failed')) {
    return DatabaseFailure(
      'خطأ في ترابط البيانات (مفتاح أجنبي)',
      code: 'db_foreign_key',
      info: {'error': msg},
    );
  }

  if (e is SqliteException) {
    return DatabaseFailure(
      'خطأ في قاعدة البيانات: ${e.message}',
      code: 'sqlite_error',
      info: {'extendedCode': e.extendedResultCode},
    );
  }

  if (e is DriftWrappedException) {
    return DatabaseFailure(
      'خطأ في عملية قاعدة البيانات',
      code: 'drift_error',
      info: {'cause': e.cause.toString()},
    );
  }

  // Fallback for unknown errors
  return UnknownFailure(
    'حدث خطأ غير متوقع: $msg',
    code: 'unknown_error',
    info: {'stackTrace': stackTrace?.toString()},
  );
}
