// lib/domain/usecases/account/delete_account_usecase.dart
import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/account_repository.dart';

class DeleteAccountUseCase {
  final AccountRepository _accountRepo;

  DeleteAccountUseCase(this._accountRepo);

  Future<Result<void>> call(
    String accountId, {
    bool requireZeroBalance = false,
  }) async {
    // 1. Get Account Details
    final accRes = await _accountRepo.getById(accountId);
    if (accRes is Fail) return accRes;
    final account = (accRes as Success).value;

    // 2. Get Transaction Count
    final countRes = await _accountRepo.countTransactions(accountId);
    if (countRes is Fail) return countRes;
    final count = (countRes as Success).value;

    // 3. Validate Deletion
    if (count > 0) {
      return const Fail(
        ValidationFailure(
          'Cannot delete account with existing transactions',
          code: 'account_has_transactions',
        ),
      );
    }

    if (requireZeroBalance && account.balance.minorUnits != 0) {
      return const Fail(
        ValidationFailure(
          'Cannot delete account with non-zero balance',
          code: 'account_non_zero_balance',
        ),
      );
    }

    // 4. Delete
    return await _accountRepo.delete(accountId);
  }
}
