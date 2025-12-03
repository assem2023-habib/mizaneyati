// lib/domain/usecases/transaction/delete_transaction_usecase.dart
import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../entities/transaction_entity.dart';
import '../../entities/account_entity.dart';
import '../../models/transaction_type.dart';
import '../../repositories/transaction_repository.dart';
import '../../repositories/account_repository.dart';

class DeleteTransactionUseCase {
  final TransactionRepository _txRepo;
  final AccountRepository _accountRepo;

  DeleteTransactionUseCase(this._txRepo, this._accountRepo);

  Future<Result<void>> call(String txId) async {
    // 1. Get Transaction
    final txRes = await _txRepo.getById(txId);
    if (txRes is Fail) return Fail((txRes as Fail).failure);
    final tx = (txRes as Success<TransactionEntity>).value;

    // 2. Fetch Account(s)
    final accRes = await _accountRepo.getById(tx.accountId);
    if (accRes is Fail) return Fail((accRes as Fail).failure);
    AccountEntity account = (accRes as Success<AccountEntity>).value;

    AccountEntity? toAccount;
    if (tx.toAccountId != null) {
      final toAccRes = await _accountRepo.getById(tx.toAccountId!);
      if (toAccRes is Fail) return Fail((toAccRes as Fail).failure);
      toAccount = (toAccRes as Success<AccountEntity>).value;
    }

    // 3. Reverse Balance Effect
    if (tx.type == TransactionType.expense) {
      final res = account.credit(tx.amount); // Refund
      if (res is Fail) return Fail((res as Fail).failure);
      account = (res as Success<AccountEntity>).value;
    } else if (tx.type == TransactionType.income) {
      final res = account.debit(tx.amount); // Take back
      if (res is Fail) return Fail((res as Fail).failure);
      account = (res as Success<AccountEntity>).value;
    } else if (tx.type == TransactionType.transfer) {
      if (toAccount == null) {
        return const Fail(
          ValidationFailure(
            'Transfer destination missing',
            code: 'transfer_dest_missing',
          ),
        );
      }
      // Reverse transfer: Credit source, Debit destination
      final sourceRes = account.credit(tx.amount);
      if (sourceRes is Fail) return Fail((sourceRes as Fail).failure);
      account = (sourceRes as Success<AccountEntity>).value;

      final destRes = toAccount.debit(tx.amount);
      if (destRes is Fail) return Fail((destRes as Fail).failure);
      toAccount = (destRes as Success<AccountEntity>).value;
    }

    // 4. Delete (Atomic operation in Repository)
    return await _txRepo.deleteTransaction(
      txId,
      account: account,
      toAccount: toAccount,
    );
  }
}
