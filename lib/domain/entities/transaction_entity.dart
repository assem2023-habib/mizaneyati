import 'package:meta/meta.dart';
import '../../core/constants/transaction_type.dart';

@immutable
class TransactionEntity {
  final String id;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final String accountId;
  final DateTime date;
  final String? note;
  final String? receiptPath;
  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.amount,
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
    double? amount,
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
      amount: amount ?? this.amount,
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
    'amount': amount,
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
          other.amount == amount &&
          other.type == type &&
          other.categoryId == categoryId &&
          other.accountId == accountId &&
          other.date == date &&
          other.note == note &&
          other.receiptPath == receiptPath &&
          other.createdAt == createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      amount.hashCode ^
      type.hashCode ^
      categoryId.hashCode ^
      accountId.hashCode ^
      date.hashCode ^
      (note?.hashCode ?? 0) ^
      (receiptPath?.hashCode ?? 0) ^
      createdAt.hashCode;
}
