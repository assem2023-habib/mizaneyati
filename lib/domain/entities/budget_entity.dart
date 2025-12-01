import 'package:meta/meta.dart';

@immutable
class BudgetEntity {
  final String id;
  final String categoryId;
  final double limitAmount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  const BudgetEntity({
    required this.id,
    required this.categoryId,
    required this.limitAmount,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  BudgetEntity copyWith({
    String? id,
    String? categoryId,
    double? limitAmount,
    DateTime? startDate,
    DateTime? endDate,
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'categoryId': categoryId,
    'limitAmount': limitAmount,
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
          other.limitAmount == limitAmount &&
          other.startDate == startDate &&
          other.endDate == endDate &&
          other.isActive == isActive;

  @override
  int get hashCode =>
      id.hashCode ^
      categoryId.hashCode ^
      limitAmount.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      isActive.hashCode;
}
