// lib/domain/entities/account_entity.dart
import 'package:meta/meta.dart';
import '../../core/utils/result.dart';
import '../../domain/models/account_type.dart';
import '../value_objects/account_name.dart';
import '../value_objects/money.dart';
import '../value_objects/color_value.dart';
import '../value_objects/icon_value.dart';

@immutable
class AccountEntity {
  final String id;
  final AccountName name;
  final Money balance;
  final AccountType type;
  final ColorValue color;
  final IconValue? icon;
  final bool isActive;
  final DateTime createdAt;

  const AccountEntity({
    required this.id,
    required this.name,
    required this.balance,
    required this.type,
    required this.color,
    this.icon,
    this.isActive = true,
    required this.createdAt,
  });

  AccountEntity copyWith({
    String? id,
    AccountName? name,
    Money? balance,
    AccountType? type,
    ColorValue? color,
    IconValue? icon,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return AccountEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      type: type ?? this.type,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountEntity &&
          other.id == id &&
          other.name == name &&
          other.balance == balance &&
          other.type == type &&
          other.color == color &&
          other.icon == icon &&
          other.isActive == isActive &&
          other.createdAt == createdAt;

  @override
  int get hashCode =>
      Object.hash(id, name, balance, type, color, icon, isActive, createdAt);

  /// Credits the account with the given amount.
  /// Returns a new [AccountEntity] with the updated balance.
  Result<AccountEntity> credit(Money amount) {
    final newBalance = balance + amount;
    return Success(copyWith(balance: newBalance));
  }

  /// Debits the account with the given amount.
  /// Returns a new [AccountEntity] with the updated balance.
  /// Returns [Fail] if the balance becomes negative (optional check, can be enforced here).
  Result<AccountEntity> debit(Money amount) {
    final newBalance = balance - amount;
    // Note: We can enforce non-negative balance here if required by business rules.
    // For now, we allow negative balance but the Validator might check it.
    // However, strict domain rules usually belong here.
    // Let's allow it for now as some accounts (credit cards) can be negative,
    // or overdrafts might be allowed.
    return Success(copyWith(balance: newBalance));
  }
}
