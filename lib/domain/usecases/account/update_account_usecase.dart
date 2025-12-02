// lib/domain/usecases/account/update_account_usecase.dart
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';
import '../entities/account_entity.dart';
import '../repositories/account_repository.dart';
import '../validation/account_validator.dart';

class UpdateAccountUseCase {
  final AccountRepository _accountRepo;

  UpdateAccountUseCase(this._accountRepo);

  Future<Result<void>> call(AccountEntity account) async {
    // 1. Validation
    final vName = AccountValidator.validateAccountName(account.name);
    if (vName is Fail) return vName;

    final vBalance = AccountValidator.validateBalance(account.balanceMinor);
    if (vBalance is Fail) return vBalance;

    final vColor = AccountValidator.validateColor(account.color);
    if (vColor is Fail) return vColor;

    // 2. Check Existence
    final existsRes = await _accountRepo.getById(account.id);
    if (existsRes is Fail) return existsRes;

    // 3. Persist
    return await _accountRepo.update(account);
  }
}
