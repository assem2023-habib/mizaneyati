// lib/data/local/mappers/transaction_mapper.dart
import 'package:drift/drift.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/value_objects/money.dart';
import '../../../domain/value_objects/date_value.dart';
import '../../../domain/value_objects/note_value.dart';
import '../../../core/utils/result.dart';
import '../db/app_database.dart';

extension TransactionMapper on Transaction {
  TransactionEntity toEntity() {
    // DB stores amount as double (Lira), convert to minor units (qruush)
    final amountResult = Money.create((amount * 100).toInt());
    final dateResult = DateValue.create(date);
    final noteResult = NoteValue.create(note);

    T getValueOrThrow<T>(Result<T> result, String field) {
      if (result is Success<T>) return result.value;
      throw Exception(
        'Data corruption in DB for field $field: ${(result as Fail).failure.message}',
      );
    }

    return TransactionEntity(
      id: id,
      amount: getValueOrThrow(amountResult, 'amount'),
      type: type,
      categoryId: categoryId,
      accountId: accountId,
      toAccountId: toAccountId,
      date: getValueOrThrow(dateResult, 'date'),
      note: getValueOrThrow(noteResult, 'note'),
      receiptPath: receiptPath,
      createdAt: createdAt,
    );
  }
}

extension TransactionEntityMapper on TransactionEntity {
  TransactionsCompanion toCompanion() {
    return TransactionsCompanion(
      id: Value(id),
      amount: Value(
        amount.toMajor(),
      ), // Convert minor units back to Lira (double)
      type: Value(type),
      categoryId: Value(categoryId),
      accountId: Value(accountId),
      date: Value(date.value),
      note: Value(note.value),
      receiptPath: Value(receiptPath),
      createdAt: Value(createdAt),
    );
  }
}
