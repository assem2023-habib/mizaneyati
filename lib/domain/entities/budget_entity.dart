import 'package:meta/meta.dart';

@immutable
class BudgetEntity {
  final String id;
  final String categoryId;
  final int limitAmountMinor;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  const BudgetEntity({
    required this.id,
    required this.categoryId,
    required this.limitAmountMinor,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
  });

  BudgetEntity copyWith({
    String? id,
    String? categoryId,
    int? limitAmountMinor,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      limitAmountMinor: limitAmountMinor ?? this.limitAmountMinor,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'categoryId': categoryId,
    'limitAmountMinor': limitAmountMinor,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'isActive': isActive,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetEntity &&
          other.id == id &&
          other.categoryId == categoryId &&
          other.limitAmountMinor == limitAmountMinor &&
          other.startDate == startDate &&
          other.endDate == endDate &&
          other.isActive == isActive;

  @override
  int get hashCode => Object.hash(
    id,
    categoryId,
    limitAmountMinor,
    startDate,
    endDate,
    isActive,
  );
}
