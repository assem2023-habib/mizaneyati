// lib/data/local/mappers/budget_mapper.dart
import 'package:drift/drift.dart';
import '../../../domain/entities/budget_entity.dart';
import '../../../domain/value_objects/money.dart';
import '../../../domain/value_objects/date_value.dart';
import '../../../core/utils/result.dart';
import '../db/app_database.dart';

extension BudgetMapper on Budget {
  BudgetEntity toEntity() {
    // DB stores limitAmount as double (Lira), convert to minor units
    final limitResult = Money.create((limitAmount * 100).toInt());
    final startResult = DateValue.create(startDate);
    final endResult = DateValue.create(endDate);

    T getValueOrThrow<T>(Result<T> result, String field) {
      if (result is Success<T>) return result.value;
      throw Exception(
        'Data corruption in DB for field $field: ${(result as Fail).failure.message}',
      );
    }

    return BudgetEntity(
      id: id,
      categoryId: categoryId,
      limitAmount: getValueOrThrow(limitResult, 'limitAmount'),
      startDate: getValueOrThrow(startResult, 'startDate'),
      endDate: getValueOrThrow(endResult, 'endDate'),
      isActive: isActive,
    );
  }
}

extension BudgetEntityMapper on BudgetEntity {
  BudgetsCompanion toCompanion() {
    return BudgetsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      limitAmount: Value(limitAmount.toMajor()),
      startDate: Value(startDate.value),
      endDate: Value(endDate.value),
      isActive: Value(isActive),
    );
  }
}
