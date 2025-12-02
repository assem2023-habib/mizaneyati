// lib/domain/usecases/transaction/add_transaction_usecase.dart
import 'package:uuid/uuid.dart';
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';
import '../entities/transaction_entity.dart';
import '../models/transaction_type.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/account_repository.dart';
import '../repositories/category_repository.dart';
import '../validation/transaction_validator.dart';
import '../validation/account_validator.dart';

class AddTransactionUseCase {
  final TransactionRepository _txRepo;
  final AccountRepository _accountRepo;
  final CategoryRepository _categoryRepo;
  final Uuid _uuid = const Uuid();

  AddTransactionUseCase(this._txRepo, this._accountRepo, this._categoryRepo);

  Future<Result<String>> call({
    required int amountMinor,
    required TransactionType type,
    required String categoryId,
    required String accountId,
    required DateTime date,
    String? note,
    String? receiptPath,
    String? toAccountId, // Required for transfer
  }) async {
    // 1. Basic Validation
    final vAmount = TransactionValidator.validateAmount(amountMinor);
    if (vAmount is Fail) return vAmount;

    final vDate = TransactionValidator.validateNotFutureDate(date);
    if (vDate is Fail) return vDate;

    final vNote = TransactionValidator.validateNote(note);
    if (vNote is Fail) return vNote;

    if (type == TransactionType.transfer) {
      final vTransfer = TransactionValidator.validateTransferAccounts(
        fromAccountId: accountId,
        toAccountId: toAccountId,
      );
      if (vTransfer is Fail) return vTransfer;
    }

    // 2. Existence & State Checks (Async)

    // Check Source Account
    final accRes = await _accountRepo.getById(accountId);
    if (accRes is Fail) return accRes;
    final account = (accRes as Success).value;

    final vAccActive = AccountValidator.validateAccountActive(
      account.isActive,
      accountId: accountId,
    );
    if (vAccActive is Fail) return vAccActive;

    // For expense/transfer, check sufficient balance
    if (type == TransactionType.expense || type == TransactionType.transfer) {
      final vBalance = AccountValidator.validateSufficientBalance(
        currentBalanceMinor: account.balanceMinor,
        requiredAmountMinor: amountMinor,
        accountId: accountId,
      );
      if (vBalance is Fail) return vBalance;
    }

    // Check Category (not needed for transfer if we treat transfers as category-less or specific category)
    // Assuming transfers might use a system category or null, but here we require categoryId for all.
    // If your logic allows null category for transfer, adjust accordingly.
    // Based on your requirements: "validateCategoryMatches"

    final catRes = await _categoryRepo.getById(categoryId);
    if (catRes is Fail) return catRes;
    final category = (catRes as Success).value;

    final vCatMatch = TransactionValidator.validateCategoryForTransaction(
      type,
      category.type,
    );
    if (vCatMatch is Fail) return vCatMatch;

    // Check Destination Account (for Transfer)
    if (type == TransactionType.transfer && toAccountId != null) {
      final toAccRes = await _accountRepo.getById(toAccountId);
      if (toAccRes is Fail) return toAccRes;
      final toAccount = (toAccRes as Success).value;

      final vToAccActive = AccountValidator.validateAccountActive(
        toAccount.isActive,
        accountId: toAccountId,
      );
      if (vToAccActive is Fail) return vToAccActive;
    }

    // 3. Build Entity
    final txId = _uuid.v4();
    final txEntity = TransactionEntity(
      id: txId,
      amountMinor: amountMinor,
      type: type,
      categoryId: categoryId,
      accountId: accountId,
      date: date,
      note: note,
      receiptPath: receiptPath,
      createdAt: DateTime.now(),
    );

    // 4. Persist (Atomic operation in Repository)
    return await _txRepo.createTransaction(txEntity, toAccountId: toAccountId);
  }
}
