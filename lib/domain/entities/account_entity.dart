import 'package:meta/meta.dart';
import '../../core/constants/account_type.dart';

@immutable
class AccountEntity {
  final String id;
  final String name;
  final double balance;
  final AccountType type;
  final String color;
  final String? icon;
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
    String? name,
    double? balance,
    AccountType? type,
    String? color,
    String? icon,
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'balance': balance,
    'type': type.name,
    'color': color,
    'icon': icon,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
  };

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
      id.hashCode ^
      name.hashCode ^
      balance.hashCode ^
      type.hashCode ^
      color.hashCode ^
      (icon?.hashCode ?? 0) ^
      isActive.hashCode ^
      createdAt.hashCode;
}
