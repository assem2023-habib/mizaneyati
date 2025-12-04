import '../../../core/utils/result.dart';
import '../../entities/account_entity.dart';
import '../../repositories/account_repository.dart';

class GetAccountsUseCase {
  final AccountRepository repository;

  GetAccountsUseCase(this.repository);

  Future<Result<List<AccountEntity>>> execute() async {
    return await repository.getAll();
  }
}
