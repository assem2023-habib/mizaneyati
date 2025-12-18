import '../../repositories/category_repository.dart';
import '../../entities/category_entity.dart';
import '../../../core/utils/result.dart';

class GetCategoryByIdUseCase {
  final CategoryRepository _repository;

  GetCategoryByIdUseCase(this._repository);

  Future<Result<CategoryEntity>> call(String id) {
    return _repository.getById(id);
  }
}
