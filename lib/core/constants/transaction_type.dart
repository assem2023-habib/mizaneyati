enum TransactionType {
  expense,
  income,
  transfer;

  String get displayName {
    switch (this) {
      case TransactionType.expense:
        return 'مصروف';
      case TransactionType.income:
        return 'دخل';
      case TransactionType.transfer:
        return 'تحويل';
    }
  }
}
