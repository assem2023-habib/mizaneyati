import 'package:meta/meta.dart';
import '../../domain/models/account_type.dart';

@immutable
class AccountEntity {
  final String id;
  final String name;
  final int balanceMinor; // store amount in minor units (e.g. qruush)
  final AccountType type;
  final String color;
  final String? icon;
  final bool isActive;
  final DateTime createdAt;

  const AccountEntity({
    required this.id,
    required this.name,
    required this.balanceMinor,
    required this.type,
    required this.color,
    this.icon,
    this.isActive = true,
    required this.createdAt,
  });

  AccountEntity copyWith({
    String? id,
    String? name,
    int? balanceMinor,
    AccountType? type,
    String? color,
    String? icon,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return AccountEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      balanceMinor: balanceMinor ?? this.balanceMinor,
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
    'balanceMinor': balanceMinor,
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
          other.balanceMinor == balanceMinor &&
          other.type == type &&
          other.color == color &&
          other.icon == icon &&
          other.isActive == isActive &&
          other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    balanceMinor,
    type,
    color,
    icon,
    isActive,
    createdAt,
  );
}
