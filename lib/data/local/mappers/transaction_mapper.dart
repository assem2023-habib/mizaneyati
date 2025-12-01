import 'package:drift/drift.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../core/constants/transaction_type.dart';
import '../app_database.dart';

extension TransactionMapper on Transaction {
  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      amount: amount,
      type: TransactionType.values.firstWhere((e) => e.name == type),
      categoryId: categoryId,
      accountId: accountId,
      date: date,
      note: note,
      receiptPath: receiptPath,
      createdAt: createdAt,
    );
  }
}

extension TransactionEntityMapper on TransactionEntity {
  TransactionsCompanion toCompanion() {
    return TransactionsCompanion(
      id: Value(id),
      amount: Value(amount),
      type: Value(type),
      categoryId: Value(categoryId),
      accountId: Value(accountId),
      date: Value(date),
      note: Value(note),
      receiptPath: Value(receiptPath),
      createdAt: Value(createdAt),
    );
  }
}
