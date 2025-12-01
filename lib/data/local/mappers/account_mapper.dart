import 'package:drift/drift.dart';
import '../../../domain/entities/account_entity.dart';
import '../../../core/constants/account_type.dart';
import '../app_database.dart';

extension AccountMapper on Account {
  AccountEntity toEntity() {
    return AccountEntity(
      id: id,
      name: name,
      balance: balance,
      type: AccountType.values.firstWhere((e) => e.name == type),
      color: color,
      icon: icon,
      isActive: isActive,
      createdAt: createdAt,
    );
  }
}

extension AccountEntityMapper on AccountEntity {
  AccountsCompanion toCompanion() {
    return AccountsCompanion(
      id: Value(id),
      name: Value(name),
      balance: Value(balance),
      type: Value(type),
      color: Value(color),
      icon: Value(icon),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }
}
