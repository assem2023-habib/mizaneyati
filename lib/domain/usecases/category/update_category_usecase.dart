// lib/domain/usecases/category/update_category_usecase.dart
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';
import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';
import '../validation/category_validator.dart';

class UpdateCategoryUseCase {
  final CategoryRepository _categoryRepo;

  UpdateCategoryUseCase(this._categoryRepo);

  Future<Result<void>> call(CategoryEntity category) async {
    // 1. Validation
    final vName = CategoryValidator.validateCategoryName(category.name);
    if (vName is Fail) return vName;

    final vIcon = CategoryValidator.validateIcon(category.icon);
    if (vIcon is Fail) return vIcon;

    final vColor = CategoryValidator.validateColor(category.color);
    if (vColor is Fail) return vColor;

    // 2. Check Existence
    final existsRes = await _categoryRepo.getById(category.id);
    if (existsRes is Fail) return existsRes;

    // 3. Persist
    return await _categoryRepo.update(category);
  }
}
