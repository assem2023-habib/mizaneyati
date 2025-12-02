import 'package:drift/drift.dart';
import '../../../domain/entities/account_entity.dart';
import '../app_database.dart';

extension AccountMapper on Account {
  AccountEntity toEntity() {
    return AccountEntity(
      id: id,
      name: name,
      balanceMinor: (balance * 100)
          .toInt(), // DB stores as double (Lira), convert to minor units (qruush)
      type: type, // type is already AccountType from DB
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
      balance: Value(balanceMinor / 100.0), // Convert minor units back to Lira
      type: Value(type),
      color: Value(color),
      icon: Value(icon),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }
}
