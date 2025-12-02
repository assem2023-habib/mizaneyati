import 'package:meta/meta.dart';
import '../../domain/models/transaction_type.dart';

@immutable
class TransactionEntity {
  final String id;
  final int amountMinor; // store as minor units
  final TransactionType type;
  final String categoryId;
  final String accountId;
  final DateTime date;
  final String? note;
  final String? receiptPath;
  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.amountMinor,
    required this.type,
    required this.categoryId,
    required this.accountId,
    required this.date,
    this.note,
    this.receiptPath,
    required this.createdAt,
  });

  TransactionEntity copyWith({
    String? id,
    int? amountMinor,
    TransactionType? type,
    String? categoryId,
    String? accountId,
    DateTime? date,
    String? note,
    String? receiptPath,
    DateTime? createdAt,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      amountMinor: amountMinor ?? this.amountMinor,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      date: date ?? this.date,
      note: note ?? this.note,
      receiptPath: receiptPath ?? this.receiptPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'amountMinor': amountMinor,
    'type': type.name,
    'categoryId': categoryId,
    'accountId': accountId,
    'date': date.toIso8601String(),
    'note': note,
    'receiptPath': receiptPath,
    'createdAt': createdAt.toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionEntity &&
          other.id == id &&
          other.amountMinor == amountMinor &&
          other.type == type &&
          other.categoryId == categoryId &&
          other.accountId == accountId &&
          other.date == date &&
          other.note == note &&
          other.receiptPath == receiptPath &&
          other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(
    id,
    amountMinor,
    type,
    categoryId,
    accountId,
    date,
    note,
    receiptPath,
    createdAt,
  );
}
