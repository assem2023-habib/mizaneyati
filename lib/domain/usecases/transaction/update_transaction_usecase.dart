// lib/domain/usecases/transaction/update_transaction_usecase.dart
import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../entities/transaction_entity.dart';
import '../../entities/account_entity.dart';
import '../../models/transaction_type.dart';
import '../../models/category_type.dart';
import '../../repositories/transaction_repository.dart';
import '../../repositories/account_repository.dart';
import '../../repositories/category_repository.dart';
import '../../value_objects/money.dart';
import '../../value_objects/date_value.dart';
import '../../value_objects/note_value.dart';

class UpdateTransactionUseCase {
  final TransactionRepository _txRepo;
  final AccountRepository _accountRepo;
  final CategoryRepository _categoryRepo;

  UpdateTransactionUseCase(this._txRepo, this._accountRepo, this._categoryRepo);

  Future<Result<void>> call({
    required String transactionId,
    int? amountMinor,
    TransactionType? type,
    String? categoryId,
    String? accountId,
    String? toAccountId, // Added for transfer updates
    DateTime? date,
    String? note,
    String? receiptPath,
  }) async {
    // 1. Get Old Transaction
    final oldTxRes = await _txRepo.getById(transactionId);
    if (oldTxRes is Fail) return Fail((oldTxRes as Fail).failure);
    final oldTx = (oldTxRes as Success<TransactionEntity>).value;

    // 2. Identify all involved accounts
    final Set<String> accountIds = {};
    accountIds.add(oldTx.accountId);
    if (oldTx.toAccountId != null) accountIds.add(oldTx.toAccountId!);

    final newAccountId = accountId ?? oldTx.accountId;
    accountIds.add(newAccountId);

    final newToAccountId = toAccountId ?? oldTx.toAccountId;
    if (newToAccountId != null) accountIds.add(newToAccountId);

    // 3. Fetch all involved accounts
    final Map<String, AccountEntity> accounts = {};
    for (final id in accountIds) {
      final res = await _accountRepo.getById(id);
      if (res is Fail) return Fail((res as Fail).failure);
      accounts[id] = (res as Success<AccountEntity>).value;
    }

    // 4. Create Value Objects for updated fields (Validation)
    Money? newAmountVO;
    if (amountMinor != null) {
      final res = Money.create(amountMinor);
      if (res is Fail) return Fail((res as Fail).failure);
      newAmountVO = (res as Success<Money>).value;
    }

    DateValue? newDate;
    if (date != null) {
      final res = DateValue.create(date);
      if (res is Fail) return Fail((res as Fail).failure);
      newDate = (res as Success<DateValue>).value;
    }

    NoteValue? newNote;
    if (note != null) {
      final res = NoteValue.create(note);
      if (res is Fail) return Fail((res as Fail).failure);
      newNote = (res as Success<NoteValue>).value;
    }

    // 5. Business Validation
    // Check Account Active Status (for new accounts)
    if (accountId != null) {
      if (!accounts[accountId]!.isActive) {
        return const Fail(
          ValidationFailure('Account is not active', code: 'account_inactive'),
        );
      }
    }
    if (toAccountId != null) {
      if (!accounts[toAccountId]!.isActive) {
        return const Fail(
          ValidationFailure(
            'Destination account is not active',
            code: 'to_account_inactive',
          ),
        );
      }
    }

    // Check Category if changed
    if (categoryId != null) {
      final catRes = await _categoryRepo.getById(categoryId);
      if (catRes is Fail) return Fail((catRes as Fail).failure);
      final category = (catRes as Success).value;

      // Validate category type matches transaction type
      final txType = type ?? oldTx.type;
      if (txType != TransactionType.transfer) {
        final expectedCategoryType = txType == TransactionType.income
            ? CategoryType.income
            : CategoryType.expense;
        if (category.type != expectedCategoryType) {
          return const Fail(
            ValidationFailure(
              'Category type does not match transaction type',
              code: 'category_type_mismatch',
            ),
          );
        }
      }
    }

    // 6. Calculate Balance Updates
    // We must perform updates sequentially on the account objects in the map.

    // A. Reverse Old Transaction
    if (oldTx.type == TransactionType.expense) {
      final acc = accounts[oldTx.accountId]!;
      final res = acc.credit(oldTx.amount); // Refund
      if (res is Fail) return Fail((res as Fail).failure);
      accounts[oldTx.accountId] = (res as Success<AccountEntity>).value;
    } else if (oldTx.type == TransactionType.income) {
      final acc = accounts[oldTx.accountId]!;
      final res = acc.debit(oldTx.amount); // Take back
      if (res is Fail) return Fail((res as Fail).failure);
      accounts[oldTx.accountId] = (res as Success<AccountEntity>).value;
    } else if (oldTx.type == TransactionType.transfer) {
      // Reverse transfer: Credit source, Debit destination
      final source = accounts[oldTx.accountId]!;
      final dest = accounts[oldTx.toAccountId]!;

      final sourceRes = source.credit(oldTx.amount);
      if (sourceRes is Fail) return Fail((sourceRes as Fail).failure);
      accounts[oldTx.accountId] = (sourceRes as Success<AccountEntity>).value;

      final destRes = dest.debit(oldTx.amount);
      if (destRes is Fail) return Fail((destRes as Fail).failure);
      accounts[oldTx.toAccountId!] = (destRes as Success<AccountEntity>).value;
    }

    // B. Apply New Transaction
    final finalType = type ?? oldTx.type;
    final finalAmount = newAmountVO ?? oldTx.amount;
    final finalAccountId = accountId ?? oldTx.accountId;
    final finalToAccountId = toAccountId ?? oldTx.toAccountId;

    if (finalType == TransactionType.expense) {
      final acc = accounts[finalAccountId]!;
      final res = acc.debit(finalAmount);
      if (res is Fail) return Fail((res as Fail).failure);
      accounts[finalAccountId] = (res as Success<AccountEntity>).value;
    } else if (finalType == TransactionType.income) {
      final acc = accounts[finalAccountId]!;
      final res = acc.credit(finalAmount);
      if (res is Fail) return Fail((res as Fail).failure);
      accounts[finalAccountId] = (res as Success<AccountEntity>).value;
    } else if (finalType == TransactionType.transfer) {
      if (finalToAccountId == null) {
        return const Fail(
          ValidationFailure(
            'Transfer destination missing',
            code: 'transfer_dest_missing',
          ),
        );
      }
      // Debit source
      final source = accounts[finalAccountId]!;
      final sourceRes = source.debit(finalAmount);
      if (sourceRes is Fail) return Fail((sourceRes as Fail).failure);
      accounts[finalAccountId] = (sourceRes as Success<AccountEntity>).value;

      // Credit destination
      final dest = accounts[finalToAccountId]!;
      final destRes = dest.credit(finalAmount);
      if (destRes is Fail) return Fail((destRes as Fail).failure);
      accounts[finalToAccountId] = (destRes as Success<AccountEntity>).value;
    }

    // 7. Update Entity
    final updatedTx = oldTx.copyWith(
      amount: newAmountVO,
      type: type,
      categoryId: categoryId,
      accountId: accountId,
      toAccountId: toAccountId,
      date: newDate,
      note: newNote,
      receiptPath: receiptPath,
    );

    // 8. Persist
    return await _txRepo.updateTransaction(
      updatedTx,
      affectedAccounts: accounts.values.toList(),
    );
  }
}
