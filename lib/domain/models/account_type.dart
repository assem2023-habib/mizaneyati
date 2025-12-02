enum AccountType {
  cash,
  bank,
  card,
  wallet,
  other;

  String get displayName {
    switch (this) {
      case AccountType.cash:
        return 'نقد';
      case AccountType.bank:
        return 'حساب بنكي';
      case AccountType.card:
        return 'بطاقة';
      case AccountType.wallet:
        return 'محفظة';
      case AccountType.other:
        return 'آخر';
    }
  }
}
