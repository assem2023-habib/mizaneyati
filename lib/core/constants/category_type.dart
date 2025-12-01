enum CategoryType {
  expense,
  income;

  String get displayName {
    switch (this) {
      case CategoryType.expense:
        return 'مصروف';
      case CategoryType.income:
        return 'دخل';
    }
  }
}
