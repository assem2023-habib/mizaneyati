import '../../repositories/account_repository.dart';
import '../../entities/account_entity.dart';
import '../../../core/utils/result.dart';

class GetAccountByIdUseCase {
  final AccountRepository _repository;

  GetAccountByIdUseCase(this._repository);

  Future<Result<AccountEntity>> call(String id) {
    return _repository.getById(id);
  }
}
