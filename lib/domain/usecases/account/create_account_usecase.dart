// lib/domain/usecases/account/create_account_usecase.dart
import 'package:uuid/uuid.dart';
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';
import '../entities/account_entity.dart';
import '../models/account_type.dart';
import '../repositories/account_repository.dart';
import '../validation/account_validator.dart';

class CreateAccountUseCase {
  final AccountRepository _accountRepo;
  final Uuid _uuid = const Uuid();

  CreateAccountUseCase(this._accountRepo);

  Future<Result<String>> call({
    required String name,
    required int balanceMinor,
    required AccountType type,
    required String color,
    String? icon,
  }) async {
    // 1. Validation
    final vName = AccountValidator.validateAccountName(name);
    if (vName is Fail) return vName;

    final vBalance = AccountValidator.validateBalance(balanceMinor);
    if (vBalance is Fail) return vBalance;

    final vColor = AccountValidator.validateColor(color);
    if (vColor is Fail) return vColor;

    // 2. Build Entity
    final id = _uuid.v4();
    final account = AccountEntity(
      id: id,
      name: name.trim(),
      balanceMinor: balanceMinor,
      type: type,
      color: color,
      icon: icon,
      isActive: true,
      createdAt: DateTime.now(),
    );

    // 3. Persist
    return await _accountRepo.create(account);
  }
}
