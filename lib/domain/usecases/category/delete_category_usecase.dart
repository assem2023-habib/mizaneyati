// lib/domain/usecases/category/delete_category_usecase.dart
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';
import '../repositories/category_repository.dart';
import '../validation/category_validator.dart';

class DeleteCategoryUseCase {
  final CategoryRepository _categoryRepo;

  DeleteCategoryUseCase(this._categoryRepo);

  Future<Result<void>> call(String categoryId) async {
    // 1. Get Transaction Count
    final countRes = await _categoryRepo.countTransactions(categoryId);
    if (countRes is Fail) return countRes;
    final count = (countRes as Success).value;

    // 2. Validate Deletion
    final vDelete = CategoryValidator.canDeleteCategory(
      transactionsCount: count,
    );
    if (vDelete is Fail) return vDelete;

    // 3. Delete
    return await _categoryRepo.delete(categoryId);
  }
}
