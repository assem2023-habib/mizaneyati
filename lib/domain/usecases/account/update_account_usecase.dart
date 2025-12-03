// lib/domain/usecases/account/update_account_usecase.dart
import '../../../core/utils/result.dart';
import '../../entities/account_entity.dart';
import '../../repositories/account_repository.dart';
import '../../value_objects/account_name.dart';
import '../../value_objects/money.dart';
import '../../value_objects/color_value.dart';
import '../../value_objects/icon_value.dart';
import '../../models/account_type.dart';

class UpdateAccountUseCase {
  final AccountRepository _accountRepo;

  UpdateAccountUseCase(this._accountRepo);

  Future<Result<void>> call({
    required String id,
    String? name,
    int? balanceMinor,
    AccountType? type,
    String? color,
    String? icon,
    bool? isActive,
  }) async {
    // 1. Check Existence & Get Old Entity
    final oldAccountRes = await _accountRepo.getById(id);
    if (oldAccountRes is Fail) return Fail((oldAccountRes as Fail).failure);
    final oldAccount = (oldAccountRes as Success<AccountEntity>).value;

    // 2. Create Value Objects for updated fields (Validation)
    AccountName? newName;
    if (name != null) {
      final res = AccountName.create(name);
      if (res is Fail) return Fail((res as Fail).failure);
      newName = (res as Success<AccountName>).value;
    }

    Money? newBalance;
    if (balanceMinor != null) {
      final res = Money.create(balanceMinor);
      if (res is Fail) return Fail((res as Fail).failure);
      newBalance = (res as Success<Money>).value;
    }

    ColorValue? newColor;
    if (color != null) {
      final res = ColorValue.create(color);
      if (res is Fail) return Fail((res as Fail).failure);
      newColor = (res as Success<ColorValue>).value;
    }

    IconValue? newIcon;
    if (icon != null) {
      final res = IconValue.create(icon);
      if (res is Fail) return Fail((res as Fail).failure);
      newIcon = (res as Success<IconValue>).value;
    }

    // 3. Update Entity
    final updatedAccount = oldAccount.copyWith(
      name: newName,
      balance: newBalance,
      type: type,
      color: newColor,
      icon: newIcon,
      isActive: isActive,
    );

    // 4. Persist
    return await _accountRepo.update(updatedAccount);
  }
}
