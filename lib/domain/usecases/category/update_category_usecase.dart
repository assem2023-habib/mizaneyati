// lib/domain/usecases/category/update_category_usecase.dart
import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../entities/category_entity.dart';
import '../../models/category_type.dart';
import '../../repositories/category_repository.dart';
import '../../value_objects/category_name.dart';
import '../../value_objects/icon_value.dart';
import '../../value_objects/color_value.dart';

class UpdateCategoryUseCase {
  final CategoryRepository _categoryRepo;

  UpdateCategoryUseCase(this._categoryRepo);

  Future<Result<void>> call({
    required String id,
    String? name,
    String? icon,
    String? color,
    CategoryType? type,
  }) async {
    // 1. Check Existence & Get Old Entity
    final oldCategoryRes = await _categoryRepo.getById(id);
    if (oldCategoryRes is Fail) return Fail((oldCategoryRes as Fail).failure);
    final oldCategory = (oldCategoryRes as Success<CategoryEntity>).value;

    // 2. Create Value Objects for updated fields
    CategoryName? newName;
    if (name != null) {
      final res = CategoryName.create(name);
      if (res is Fail) return Fail((res as Fail).failure);
      newName = (res as Success<CategoryName>).value;
    }

    IconValue? newIcon;
    if (icon != null) {
      final res = IconValue.create(icon);
      if (res is Fail) return Fail((res as Fail).failure);
      newIcon = (res as Success<IconValue>).value;
    }

    ColorValue? newColor;
    if (color != null) {
      final res = ColorValue.create(color);
      if (res is Fail) return Fail((res as Fail).failure);
      newColor = (res as Success<ColorValue>).value;
    }

    // 3. Update Entity
    final updatedCategory = oldCategory.copyWith(
      name: newName,
      icon: newIcon,
      color: newColor,
      type: type,
    );

    // 4. Persist
    return await _categoryRepo.update(updatedCategory);
  }
}
