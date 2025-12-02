import 'package:drift/drift.dart';
import '../../../domain/entities/budget_entity.dart';
import '../app_database.dart';

extension BudgetMapper on Budget {
  BudgetEntity toEntity() {
    return BudgetEntity(
      id: id,
      categoryId: categoryId,
      limitAmountMinor: (limitAmount * 100)
          .toInt(), // DB stores as double (Lira), convert to minor units (qruush)
      startDate: startDate,
      endDate: endDate,
      isActive: isActive,
    );
  }
}

extension BudgetEntityMapper on BudgetEntity {
  BudgetsCompanion toCompanion() {
    return BudgetsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      limitAmount: Value(
        limitAmountMinor / 100.0,
      ), // Convert minor units back to Lira
      startDate: Value(startDate),
      endDate: Value(endDate),
      isActive: Value(isActive),
    );
  }
}
