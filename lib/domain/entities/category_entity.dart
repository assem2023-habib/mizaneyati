// lib/domain/entities/category_entity.dart
import 'package:meta/meta.dart';
import '../../domain/models/category_type.dart';
import '../value_objects/category_name.dart';
import '../value_objects/icon_value.dart';
import '../value_objects/color_value.dart';

@immutable
class CategoryEntity {
  final String id;
  final CategoryName name;
  final IconValue icon;
  final ColorValue color;
  final CategoryType type;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  CategoryEntity copyWith({
    String? id,
    CategoryName? name,
    IconValue? icon,
    ColorValue? color,
    CategoryType? type,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryEntity &&
          other.id == id &&
          other.name == name &&
          other.icon == icon &&
          other.color == color &&
          other.type == type;

  @override
  int get hashCode => Object.hash(id, name, icon, color, type);
}
