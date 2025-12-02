// lib/application/providers/database_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/db/app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});
