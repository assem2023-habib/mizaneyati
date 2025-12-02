import 'package:drift/drift.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../app_database.dart';

extension TransactionMapper on Transaction {
  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      amountMinor: (amount * 100)
          .toInt(), // DB stores as double (Lira), convert to minor units (qruush)
      type: type, // type is already TransactionType from DB
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
      amount: Value(amountMinor / 100.0), // Convert minor units back to Lira
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
