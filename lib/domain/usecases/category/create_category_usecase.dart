// lib/domain/usecases/category/create_category_usecase.dart
import 'package:uuid/uuid.dart';
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';
import '../entities/category_entity.dart';
import '../models/category_type.dart';
import '../repositories/category_repository.dart';
import '../validation/category_validator.dart';

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
    // 1. Validation
    final vName = CategoryValidator.validateCategoryName(name);
    if (vName is Fail) return vName;

    final vIcon = CategoryValidator.validateIcon(icon);
    if (vIcon is Fail) return vIcon;

    final vColor = CategoryValidator.validateColor(color);
    if (vColor is Fail) return vColor;

    // 2. Build Entity
    final id = _uuid.v4();
    final category = CategoryEntity(
      id: id,
      name: name.trim(),
      icon: icon,
      color: color,
      type: type,
    );

    // 3. Persist
    return await _categoryRepo.create(category);
  }
}
