// lib/domain/usecases/account/delete_account_usecase.dart
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';
import '../repositories/account_repository.dart';
import '../validation/account_validator.dart';

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
    final vDelete = AccountValidator.canDeleteAccount(
      transactionsCount: count,
      balanceMinor: account.balanceMinor,
      requireZeroBalance: requireZeroBalance,
    );
    if (vDelete is Fail) return vDelete;

    // 4. Delete
    return await _accountRepo.delete(accountId);
  }
}
