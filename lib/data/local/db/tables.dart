import 'package:drift/drift.dart';

// Export enums so generated code can access them
export '../../../domain/models/account_type.dart';
export '../../../domain/models/category_type.dart';
export '../../../domain/models/transaction_type.dart';

import 'type_converters.dart';

class Accounts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get balance => real().withDefault(const Constant(0.0))();
  TextColumn get type => text().map(const AccountTypeConverter())();
  TextColumn get color => text()();
  TextColumn get icon => text().nullable()(); // Added icon
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true))(); // Added isActive
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get icon => text()();
  TextColumn get color => text()();
  TextColumn get type => text().map(const CategoryTypeConverter())();

  @override
  Set<Column> get primaryKey => {id};
}

class Transactions extends Table {
  TextColumn get id => text()();
  RealColumn get amount => real()();
  TextColumn get type => text().map(const TransactionTypeConverter())();
  TextColumn get categoryId => text().references(Categories, #id)();
  TextColumn get accountId => text().references(Accounts, #id)();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
  TextColumn get receiptPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT',
    'FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE RESTRICT',
  ];
}

class Budgets extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text().references(Categories, #id)();
  RealColumn get limitAmount => real()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
