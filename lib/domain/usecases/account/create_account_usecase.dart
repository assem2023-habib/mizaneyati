// lib/domain/usecases/account/create_account_usecase.dart
import 'package:uuid/uuid.dart';
import '../../../core/utils/result.dart';
import '../../entities/account_entity.dart';
import '../../models/account_type.dart';
import '../../repositories/account_repository.dart';
import '../../value_objects/account_name.dart';
import '../../value_objects/money.dart';
import '../../value_objects/color_value.dart';
import '../../value_objects/icon_value.dart';

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
    // 1. Create Value Objects (Validation happens here)
    final nameResult = AccountName.create(name);
    if (nameResult is Fail) return Fail((nameResult as Fail).failure);

    final balanceResult = Money.create(balanceMinor);
    if (balanceResult is Fail) return Fail((balanceResult as Fail).failure);

    final colorResult = ColorValue.create(color);
    if (colorResult is Fail) return Fail((colorResult as Fail).failure);

    Result<IconValue>? iconResult;
    if (icon != null) {
      iconResult = IconValue.create(icon);
      if (iconResult is Fail) return Fail((iconResult as Fail).failure);
    }

    // 2. Build Entity
    final id = _uuid.v4();
    final account = AccountEntity(
      id: id,
      name: (nameResult as Success<AccountName>).value,
      balance: (balanceResult as Success<Money>).value,
      type: type,
      color: (colorResult as Success<ColorValue>).value,
      icon: iconResult != null
          ? (iconResult as Success<IconValue>).value
          : null,
      isActive: true,
      createdAt: DateTime.now(),
    );

    // 3. Persist
    return await _accountRepo.create(account);
  }
}
