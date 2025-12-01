import 'package:meta/meta.dart';
import '../../core/constants/category_type.dart';

@immutable
class CategoryEntity {
  final String id;
  final String name;
  final String icon;
  final String color;
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
    String? name,
    String? icon,
    String? color,
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon,
    'color': color,
    'type': type.name,
  };

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
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      icon.hashCode ^
      color.hashCode ^
      type.hashCode;
}
