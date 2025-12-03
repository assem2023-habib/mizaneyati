// lib/domain/usecases/category/delete_category_usecase.dart
import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/category_repository.dart';

class DeleteCategoryUseCase {
  final CategoryRepository _categoryRepo;

  DeleteCategoryUseCase(this._categoryRepo);

  Future<Result<void>> call(String categoryId) async {
    // 1. Get Transaction Count
    final countRes = await _categoryRepo.countTransactions(categoryId);
    if (countRes is Fail) return countRes;
    final count = (countRes as Success).value;

    // 2. Validate Deletion
    if (count > 0) {
      return const Fail(
        ValidationFailure(
          'Cannot delete category with existing transactions',
          code: 'category_has_transactions',
        ),
      );
    }

    // 3. Delete
    return await _categoryRepo.delete(categoryId);
  }
}
