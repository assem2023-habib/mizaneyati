// lib/domain/usecases/transaction/update_transaction_usecase.dart
import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
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
    DateTime? date,
    String? note,
    String? receiptPath,
  }) async {
    // 1. Get Old Transaction
    final oldTxRes = await _txRepo.getById(transactionId);
    if (oldTxRes is Fail) return Fail((oldTxRes as Fail).failure);
    final oldTx = (oldTxRes as Success).value;

    // 2. Create Value Objects for updated fields (Validation)
    Money? newAmount;
    if (amountMinor != null) {
      final res = Money.create(amountMinor);
      if (res is Fail) return Fail((res as Fail).failure);
      newAmount = (res as Success<Money>).value;
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

    // 3. Business Validation
    // Check Account if changed
    if (accountId != null) {
      final accRes = await _accountRepo.getById(accountId);
      if (accRes is Fail) return Fail((accRes as Fail).failure);
      final account = (accRes as Success).value;

      if (!account.isActive) {
        return const Fail(
          ValidationFailure('Account is not active', code: 'account_inactive'),
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

    // 4. Update Entity
    final updatedTx = oldTx.copyWith(
      amount: newAmount,
      type: type,
      categoryId: categoryId,
      accountId: accountId,
      date: newDate,
      note: newNote,
      receiptPath: receiptPath,
    );

    // 5. Persist (Repository handles atomic balance update)
    return await _txRepo.updateTransaction(updatedTx);
  }
}
