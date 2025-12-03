// lib/domain/entities/budget_entity.dart
import 'package:meta/meta.dart';
import '../value_objects/money.dart';
import '../value_objects/date_value.dart';

@immutable
class BudgetEntity {
  final String id;
  final String categoryId;
  final Money limitAmount;
  final DateValue startDate;
  final DateValue endDate;
  final bool isActive;

  const BudgetEntity({
    required this.id,
    required this.categoryId,
    required this.limitAmount,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
  });

  BudgetEntity copyWith({
    String? id,
    String? categoryId,
    Money? limitAmount,
    DateValue? startDate,
    DateValue? endDate,
    bool? isActive,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      limitAmount: limitAmount ?? this.limitAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetEntity &&
          other.id == id &&
          other.categoryId == categoryId &&
          other.limitAmount == limitAmount &&
          other.startDate == startDate &&
          other.endDate == endDate &&
          other.isActive == isActive;

  @override
  int get hashCode =>
      Object.hash(id, categoryId, limitAmount, startDate, endDate, isActive);
}
