import 'package:drift/drift.dart';
import '../../../domain/entities/category_entity.dart';
import '../app_database.dart';

extension CategoryMapper on Category {
  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      icon: icon,
      color: color,
      type: type, // type is already CategoryType from DB
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
