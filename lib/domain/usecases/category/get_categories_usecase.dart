import '../../../core/utils/result.dart';
import '../../entities/category_entity.dart';
import '../../repositories/category_repository.dart';

class GetCategoriesUseCase {
  final CategoryRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<Result<List<CategoryEntity>>> execute() async {
    return await repository.getAll();
  }
}
