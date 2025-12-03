// lib/data/local/mappers/category_mapper.dart
import 'package:drift/drift.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/value_objects/category_name.dart';
import '../../../domain/value_objects/icon_value.dart';
import '../../../domain/value_objects/color_value.dart';
import '../../../core/utils/result.dart';
import '../db/app_database.dart';

extension CategoryMapper on Category {
  CategoryEntity toEntity() {
    final nameResult = CategoryName.create(name);
    final iconResult = IconValue.create(icon);
    final colorResult = ColorValue.create(color);

    T getValueOrThrow<T>(Result<T> result, String field) {
      if (result is Success<T>) return result.value;
      throw Exception(
        'Data corruption in DB for field $field: ${(result as Fail).failure.message}',
      );
    }

    return CategoryEntity(
      id: id,
      name: getValueOrThrow(nameResult, 'name'),
      icon: getValueOrThrow(iconResult, 'icon'),
      color: getValueOrThrow(colorResult, 'color'),
      type: type,
    );
  }
}

extension CategoryEntityMapper on CategoryEntity {
  CategoriesCompanion toCompanion() {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name.value),
      icon: Value(icon.name), // IconValue uses .name
      color: Value(color.hex), // ColorValue uses .hex
      type: Value(type),
    );
  }
}
