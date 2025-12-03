// lib/domain/usecases/transaction/add_transaction_usecase.dart
import 'package:uuid/uuid.dart';
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
    String? toAccountId,
  }) async {
    // 1. Create Value Objects (Validation)
    final amountResult = Money.create(amountMinor);
    if (amountResult is Fail) return Fail((amountResult as Fail).failure);

    final dateResult = DateValue.create(date);
    if (dateResult is Fail) return Fail((dateResult as Fail).failure);

    final noteResult = NoteValue.create(note);
    if (noteResult is Fail) return Fail((noteResult as Fail).failure);

    // 2. Business Validation
    if (type == TransactionType.transfer &&
        (toAccountId == null || toAccountId == accountId)) {
      return const Fail(
        ValidationFailure(
          'Transfer requires valid distinct destination account',
          code: 'invalid_transfer',
        ),
      );
    }

    // Check Source Account
    final accRes = await _accountRepo.getById(accountId);
    if (accRes is Fail) return Fail((accRes as Fail).failure);
    final account = (accRes as Success).value;

    if (!account.isActive) {
      return const Fail(
        ValidationFailure('Account is not active', code: 'account_inactive'),
      );
    }

    // Check balance for expense/transfer
    if (type == TransactionType.expense || type == TransactionType.transfer) {
      if (account.balance.minorUnits < amountMinor) {
        return const Fail(
          ValidationFailure(
            'Insufficient balance',
            code: 'insufficient_balance',
          ),
        );
      }
    }

    // Check Category
    final catRes = await _categoryRepo.getById(categoryId);
    if (catRes is Fail) return Fail((catRes as Fail).failure);
    final category = (catRes as Success).value;

    // Validate category type matches transaction type (not applicable for transfer)
    if (type != TransactionType.transfer) {
      final expectedCategoryType = type == TransactionType.income
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

    // Check Destination Account (for Transfer)
    AccountEntity? toAccount;
    if (type == TransactionType.transfer) {
      if (toAccountId == null) {
        return const Fail(
          ValidationFailure(
            'Transfer requires valid destination account',
            code: 'transfer_destination_missing',
          ),
        );
      }

      final toAccRes = await _accountRepo.getById(toAccountId);
      if (toAccRes is Fail) return Fail((toAccRes as Fail).failure);
      toAccount = (toAccRes as Success<AccountEntity>).value;

      if (!toAccount.isActive) {
        return const Fail(
          ValidationFailure(
            'Destination account is not active',
            code: 'to_account_inactive',
          ),
        );
      }
    }

    // 3. Business Logic: Update Balances
    AccountEntity updatedAccount = account;
    AccountEntity? updatedToAccount;
    final moneyAmount = (amountResult as Success<Money>).value;

    if (type == TransactionType.expense) {
      final res = account.debit(moneyAmount);
      if (res is Fail) return Fail((res).failure);
      updatedAccount = (res as Success<AccountEntity>).value;
    } else if (type == TransactionType.income) {
      final res = account.credit(moneyAmount);
      if (res is Fail) return Fail((res).failure);
      updatedAccount = (res as Success<AccountEntity>).value;
    } else if (type == TransactionType.transfer) {
      // Debit source
      final debitRes = account.debit(moneyAmount);
      if (debitRes is Fail) return Fail((debitRes).failure);
      updatedAccount = (debitRes as Success<AccountEntity>).value;

      // Credit destination
      if (toAccount != null) {
        final creditRes = toAccount.credit(moneyAmount);
        if (creditRes is Fail) return Fail((creditRes as Fail).failure);
        updatedToAccount = (creditRes as Success<AccountEntity>).value;
      }
    }

    // 4. Build Entity
    final txId = _uuid.v4();
    final txEntity = TransactionEntity(
      id: txId,
      amount: moneyAmount,
      type: type,
      categoryId: categoryId,
      accountId: accountId,
      toAccountId: toAccountId,
      date: (dateResult as Success<DateValue>).value,
      note: (noteResult as Success<NoteValue>).value,
      receiptPath: receiptPath,
      createdAt: DateTime.now(),
    );

    // 5. Persist (Atomic operation in Repository)
    return await _txRepo.createTransaction(
      txEntity,
      account: updatedAccount,
      toAccount: updatedToAccount,
    );
  }
}
