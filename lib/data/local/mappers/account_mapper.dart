// lib/data/local/mappers/account_mapper.dart
import 'package:drift/drift.dart';
import '../../../domain/entities/account_entity.dart';
import '../../../domain/value_objects/account_name.dart';
import '../../../domain/value_objects/money.dart';
import '../../../domain/value_objects/color_value.dart';
import '../../../domain/value_objects/icon_value.dart';
import '../../../core/utils/result.dart';
import '../db/app_database.dart';

extension AccountMapper on Account {
  AccountEntity toEntity() {
    // We assume DB data is valid. If not, we force unwrap or use fallback.
    // Ideally, we should log warnings if data is invalid.

    final nameResult = AccountName.create(name);
    // DB stores balance as double (Lira), convert to minor units (qruush)
    final balanceResult = Money.create((balance * 100).toInt());
    final colorResult = ColorValue.create(color);
    final iconResult = icon != null ? IconValue.create(icon!) : null;

    // Helper to get value or throw (Data Integrity Check)
    T getValueOrThrow<T>(Result<T> result, String field) {
      if (result is Success<T>) return result.value;
      // In a real app, we might return a default or log this.
      // For strict domain, we throw.
      throw Exception(
        'Data corruption in DB for field $field: ${(result as Fail).failure.message}',
      );
    }

    return AccountEntity(
      id: id,
      name: getValueOrThrow(nameResult, 'name'),
      balance: getValueOrThrow(balanceResult, 'balance'),
      type: type,
      color: getValueOrThrow(colorResult, 'color'),
      icon: iconResult != null ? getValueOrThrow(iconResult, 'icon') : null,
      isActive: isActive,
      createdAt: createdAt,
    );
  }
}

extension AccountEntityMapper on AccountEntity {
  AccountsCompanion toCompanion() {
    return AccountsCompanion(
      id: Value(id),
      name: Value(name.value),
      balance: Value(
        balance.toMajor(),
      ), // Convert minor units back to Lira (double)
      type: Value(type),
      color: Value(color.hex), // Note: ColorValue uses .hex
      icon: Value(icon?.name), // IconValue uses .name
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }
}
