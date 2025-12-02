// lib/domain/usecases/transaction/update_transaction_usecase.dart
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';
import '../entities/transaction_entity.dart';
import '../models/transaction_type.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/account_repository.dart';
import '../repositories/category_repository.dart';
import '../validation/transaction_validator.dart';
import '../validation/account_validator.dart';

class UpdateTransactionUseCase {
  final TransactionRepository _txRepo;
  final AccountRepository _accountRepo;
  final CategoryRepository _categoryRepo;

  UpdateTransactionUseCase(this._txRepo, this._accountRepo, this._categoryRepo);

  Future<Result<void>> call(TransactionEntity tx) async {
    // 1. Basic Validation
    final vAmount = TransactionValidator.validateAmount(tx.amountMinor);
    if (vAmount is Fail) return vAmount;

    final vDate = TransactionValidator.validateNotFutureDate(tx.date);
    if (vDate is Fail) return vDate;

    final vNote = TransactionValidator.validateNote(tx.note);
    if (vNote is Fail) return vNote;

    // 2. Existence Checks
    // Check if transaction exists
    final oldTxRes = await _txRepo.getById(tx.id);
    if (oldTxRes is Fail) return oldTxRes;
    // final oldTx = (oldTxRes as Success).value; // might be needed for complex logic validation

    // Check Account
    final accRes = await _accountRepo.getById(tx.accountId);
    if (accRes is Fail) return accRes;
    final account = (accRes as Success).value;

    final vAccActive = AccountValidator.validateAccountActive(
      account.isActive,
      accountId: tx.accountId,
    );
    if (vAccActive is Fail) return vAccActive;

    // Check Category
    final catRes = await _categoryRepo.getById(tx.categoryId);
    if (catRes is Fail) return catRes;
    final category = (catRes as Success).value;

    final vCatMatch = TransactionValidator.validateCategoryForTransaction(
      tx.type,
      category.type,
    );
    if (vCatMatch is Fail) return vCatMatch;

    // Note: For updates, we rely on the repository to handle the balance reversal and re-application atomically.
    // However, we might want to check if the new state would cause negative balance if that's a hard rule.
    // This is complex because we need to know the net effect.
    // For simplicity and performance, we let the repository handle the atomic update,
    // and if the DB constraints or repository logic fails (e.g. negative balance check), it returns a Fail.

    // But we can do a "soft" check here if we want to be proactive,
    // though it requires knowing the old amount which we have in `oldTx`.

    // 3. Persist
    return await _txRepo.updateTransaction(tx);
  }
}
