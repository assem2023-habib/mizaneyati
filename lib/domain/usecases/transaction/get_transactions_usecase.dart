// lib/domain/usecases/transaction/get_transactions_usecase.dart
import '../../core/utils/result.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionsUseCase {
  final TransactionRepository _txRepo;

  GetTransactionsUseCase(this._txRepo);

  Future<Result<List<TransactionEntity>>> byDateRange(
    DateTime start,
    DateTime end,
  ) {
    return _txRepo.getByDateRange(start, end);
  }

  Future<Result<List<TransactionEntity>>> recent({int limit = 10}) {
    return _txRepo.getRecent(limit: limit);
  }

  Stream<List<TransactionEntity>> watchByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return _txRepo.watchByDateRange(start, end);
  }
}
