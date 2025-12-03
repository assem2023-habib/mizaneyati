// lib/domain/entities/transaction_entity.dart
import 'package:meta/meta.dart';
import '../../domain/models/transaction_type.dart';
import '../value_objects/money.dart';
import '../value_objects/date_value.dart';
import '../value_objects/note_value.dart';

@immutable
class TransactionEntity {
  final String id;
  final Money amount;
  final TransactionType type;
  final String categoryId;
  final String accountId;
  final String? toAccountId; // For transfers
  final DateValue date;
  final NoteValue note;
  final String? receiptPath;
  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.accountId,
    this.toAccountId,
    required this.date,
    required this.note,
    this.receiptPath,
    required this.createdAt,
  });

  TransactionEntity copyWith({
    String? id,
    Money? amount,
    TransactionType? type,
    String? categoryId,
    String? accountId,
    String? toAccountId,
    DateValue? date,
    NoteValue? note,
    String? receiptPath,
    DateTime? createdAt,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      date: date ?? this.date,
      note: note ?? this.note,
      receiptPath: receiptPath ?? this.receiptPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionEntity &&
          other.id == id &&
          other.amount == amount &&
          other.type == type &&
          other.categoryId == categoryId &&
          other.accountId == accountId &&
          other.toAccountId == toAccountId &&
          other.date == date &&
          other.note == note &&
          other.receiptPath == receiptPath &&
          other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(
    id,
    amount,
    type,
    categoryId,
    accountId,
    toAccountId,
    date,
    note,
    receiptPath,
    createdAt,
  );
}
