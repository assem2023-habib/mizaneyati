import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';
import 'type_converters.dart';
import '../daos/accounts_dao.dart';
import '../daos/categories_dao.dart';
import '../daos/transactions_dao.dart';
import '../daos/budgets_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Accounts, Categories, Transactions, Budgets],
  daos: [AccountsDao, CategoriesDao, TransactionsDao, BudgetsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'mizaneyati.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
