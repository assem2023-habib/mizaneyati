// lib/domain/usecases/category/create_category_usecase.dart
import 'package:uuid/uuid.dart';
import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../entities/category_entity.dart';
import '../../models/category_type.dart';
import '../../repositories/category_repository.dart';
import '../../value_objects/category_name.dart';
import '../../value_objects/icon_value.dart';
import '../../value_objects/color_value.dart';

class CreateCategoryUseCase {
  final CategoryRepository _categoryRepo;
  final Uuid _uuid = const Uuid();

  CreateCategoryUseCase(this._categoryRepo);

  Future<Result<String>> call({
    required String name,
    required String icon,
    required String color,
    required CategoryType type,
  }) async {
    // 1. Create Value Objects (Validation)
    final nameResult = CategoryName.create(name);
    if (nameResult is Fail) return Fail((nameResult as Fail).failure);

    final iconResult = IconValue.create(icon);
    if (iconResult is Fail) return Fail((iconResult as Fail).failure);

    final colorResult = ColorValue.create(color);
    if (colorResult is Fail) return Fail((colorResult as Fail).failure);

    // 2. Business Validation
    // Check Uniqueness
    final existsRes = await _categoryRepo.existsByName(name);
    if (existsRes is Fail) return Fail((existsRes as Fail).failure);
    final exists = (existsRes as Success<bool>).value;

    if (exists) {
      return const Fail(
        ValidationFailure(
          'Category name already exists',
          code: 'category_name_duplicate',
        ),
      );
    }

    // 3. Build Entity
    final id = _uuid.v4();
    final category = CategoryEntity(
      id: id,
      name: (nameResult as Success<CategoryName>).value,
      icon: (iconResult as Success<IconValue>).value,
      color: (colorResult as Success<ColorValue>).value,
      type: type,
    );

    // 3. Persist
    return await _categoryRepo.create(category);
  }
}
