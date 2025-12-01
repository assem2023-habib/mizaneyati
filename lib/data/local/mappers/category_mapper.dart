import 'package:drift/drift.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../core/constants/category_type.dart';
import '../app_database.dart';

extension CategoryMapper on Category {
  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      icon: icon,
      color: color,
      type: CategoryType.values.firstWhere((e) => e.name == type),
    );
  }
}

extension CategoryEntityMapper on CategoryEntity {
  CategoriesCompanion toCompanion() {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      icon: Value(icon),
      color: Value(color),
      type: Value(type),
    );
  }
}
