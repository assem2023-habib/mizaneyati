// lib/domain/usecases/transaction/delete_transaction_usecase.dart
// import 'package:mizaneyati/core/utils/result.dart';

import '../../../core/utils/result.dart';
import '../../repositories/transaction_repository.dart';

class DeleteTransactionUseCase {
  final TransactionRepository _txRepo;

  DeleteTransactionUseCase(this._txRepo);

  Future<Result<void>> call(String txId) async {
    // 1. Check existence (Optional, as delete might return not found, but good for explicit error)
    final txRes = await _txRepo.getById(txId);
    if (txRes is Fail) return txRes; // Return error if not found

    // 2. Delete
    // Repository handles reversing the balance effect atomically
    return await _txRepo.deleteTransaction(txId);
  }
}
