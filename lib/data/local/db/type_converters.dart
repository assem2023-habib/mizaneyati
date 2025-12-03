import 'package:drift/drift.dart';
import '../../../domain/models/account_type.dart';
import '../../../domain/models/category_type.dart';
import '../../../domain/models/transaction_type.dart';

class AccountTypeConverter extends TypeConverter<AccountType, String> {
  const AccountTypeConverter();

  @override
  AccountType fromSql(String fromDb) {
    return AccountType.values.firstWhere(
      (e) => e.name == fromDb,
      orElse: () => AccountType.other,
    );
  }

  @override
  String toSql(AccountType value) {
    return value.name;
  }
}

class CategoryTypeConverter extends TypeConverter<CategoryType, String> {
  const CategoryTypeConverter();

  @override
  CategoryType fromSql(String fromDb) {
    return CategoryType.values.firstWhere(
      (e) => e.name == fromDb,
      orElse: () => CategoryType.expense,
    );
  }

  @override
  String toSql(CategoryType value) {
    return value.name;
  }
}

class TransactionTypeConverter extends TypeConverter<TransactionType, String> {
  const TransactionTypeConverter();

  @override
  TransactionType fromSql(String fromDb) {
    return TransactionType.values.firstWhere(
      (e) => e.name == fromDb,
      orElse: () => TransactionType.expense,
    );
  }

  @override
  String toSql(TransactionType value) {
    return value.name;
  }
}
