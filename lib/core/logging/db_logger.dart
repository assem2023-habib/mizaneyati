// lib/core/logging/db_logger.dart

import 'dart:developer' as developer;
import 'package:logger/logger.dart';

/// Database logger for tracking SQL queries, errors, and performance
///
/// Uses singleton pattern for easy access throughout the app.
/// Logs to both console (via logger package) and developer log.
///
/// Usage:
/// ```dart
/// DbLogger().logQuery('SELECT * FROM accounts', params: {'id': '123'});
/// DbLogger().logError('Failed to insert', error, stackTrace);
/// ```
class DbLogger {
  // Singleton instance
  DbLogger._internal() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0, // No method stack trace in logs
        errorMethodCount: 5, // Show stack trace for errors
        lineLength: 80,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      level: _getLogLevel(),
    );
  }

  static final DbLogger _instance = DbLogger._internal();
  factory DbLogger() => _instance;

  late final Logger _logger;

  /// Threshold for detecting slow queries (in milliseconds)
  static const int slowQueryThresholdMs = 200;

  /// Get log level based on build mode
  /// In release mode, only show warnings and errors
  Level _getLogLevel() {
    // You can add environment-based configuration here
    // For now, always use debug in development
    return Level.debug;
  }

  /// Log a SQL query with optional parameters and duration
  ///
  /// Example:
  /// ```dart
  /// DbLogger().logQuery(
  ///   'SELECT * FROM accounts WHERE id = ?',
  ///   params: {'id': accountId},
  ///   duration: Duration(milliseconds: 45),
  /// );
  /// ```
  void logQuery(
    String sql, {
    Map<String, Object?>? params,
    Duration? duration,
  }) {
    final msg = StringBuffer();
    msg.writeln('📊 SQL Query: $sql');
    if (params != null && params.isNotEmpty) {
      msg.writeln('   Params: $params');
    }
    if (duration != null) {
      msg.writeln('   Duration: ${duration.inMilliseconds}ms');

      // Check for slow queries
      if (duration.inMilliseconds > slowQueryThresholdMs) {
        logWarning(
          '⚠️ Slow query detected: ${duration.inMilliseconds}ms - $sql',
        );
      }
    }

    _logger.d(msg.toString());
    developer.log(
      msg.toString(),
      name: 'mizaneyati.db.query',
      time: DateTime.now(),
    );
  }

  /// Log general information messages
  ///
  /// Example:
  /// ```dart
  /// DbLogger().logInfo('Database opened successfully', {'version': 1});
  /// ```
  void logInfo(String message, [Map<String, Object?>? meta]) {
    final msg = '📝 $message${meta != null ? ' | Meta: $meta' : ''}';
    _logger.i(msg);
    developer.log(msg, name: 'mizaneyati.db.info', time: DateTime.now());
  }

  /// Log errors with full stack trace and context
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   // database operation
  /// } catch (e, st) {
  ///   DbLogger().logError('Failed to insert account', e, st, {'accountId': id});
  /// }
  /// ```
  void logError(
    String message,
    Object? error, [
    StackTrace? stackTrace,
    Map<String, Object?>? meta,
  ]) {
    final msg = '❌ $message${meta != null ? ' | Meta: $meta' : ''}';
    _logger.e(msg, error: error, stackTrace: stackTrace);
    developer.log(
      msg,
      name: 'mizaneyati.db.error',
      error: error,
      stackTrace: stackTrace,
      time: DateTime.now(),
    );
  }

  /// Log warning messages
  ///
  /// Example:
  /// ```dart
  /// DbLogger().logWarning('Account balance is negative');
  /// ```
  void logWarning(String message) {
    final msg = '⚠️ $message';
    _logger.w(msg);
    developer.log(msg, name: 'mizaneyati.db.warn', time: DateTime.now());
  }

  /// Log debug messages (only in debug mode)
  void logDebug(String message) {
    final msg = '🐛 $message';
    _logger.d(msg);
    developer.log(msg, name: 'mizaneyati.db.debug', time: DateTime.now());
  }

  /// Log migration events
  ///
  /// Example:
  /// ```dart
  /// DbLogger().logMigration('Migrating from version 1 to 2');
  /// ```
  void logMigration(String message, {int? fromVersion, int? toVersion}) {
    final msg =
        '🔄 Migration: $message'
        '${fromVersion != null ? ' (v$fromVersion → v${toVersion ?? "?"})' : ''}';
    _logger.i(msg);
    developer.log(msg, name: 'mizaneyati.db.migration', time: DateTime.now());
  }
}
