// lib/domain/usecases/transaction_usecase_example.dart
//
// هذا مثال توضيحي لكيفية استخدام Validators في UseCase
// يمكنك نسخ هذا النمط واستخدامه في UseCases الحقيقية

import '../../core/utils/result.dart';
import '../../core/validation/validators.dart';
import '../../domain/models/transaction_type.dart';
import '../../domain/models/account_type.dart';
import '../entities/transaction_entity.dart';
import '../entities/account_entity.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/repositories/account_repository.dart';
import '../../data/repositories/category_repository.dart';

/// مثال على UseCase لإنشاء معاملة مع التحقق الكامل
///
/// يوضح هذا المثال:
/// 1. كيفية استخدام Validators قبل العمليات
/// 2. كيفية التعامل مع Result pattern
/// 3. كيفية التحقق من الكيانات المرتبطة
class CreateTransactionUseCase {
  final TransactionRepository _transactionRepo;
  final AccountRepository _accountRepo;

  CreateTransactionUseCase(this._transactionRepo, this._accountRepo);

  /// تنفيذ UseCase لإنشاء معاملة جديدة
  Future<Result<String>> execute(TransactionEntity transaction) async {
    // 1. التحقق من المبلغ (convert minor to main units for validation)
    final amountValidation = Validators.validateAmount(
      transaction.amountMinor / 100.0,
    );
    if (amountValidation case Fail(:final failure)) {
      return Fail(failure);
    }

    // 2. التحقق من التاريخ
    final dateValidation = Validators.validateNotFutureDate(transaction.date);
    if (dateValidation case Fail(:final failure)) {
      return Fail(failure);
    }

    // 3. التحقق من الحساب
    final accountResult = await _accountRepo.getAccountById(
      transaction.accountId,
    );
    if (accountResult case Fail(:final failure)) {
      return Fail(failure);
    }

    final account = (accountResult as Success<AccountEntity>).value;
    final accountActiveValidation = Validators.validateAccountActive(
      account.isActive,
      accountId: account.id,
    );
    if (accountActiveValidation case Fail(:final failure)) {
      return Fail(failure);
    }

    // 4. التحقق الخاص بالتحويلات
    if (transaction.type == TransactionType.transfer) {
      final transferValidation = Validators.validateTransfer(
        fromAccountId: transaction.accountId,
        toAccountId: transaction.note,
      );
      if (transferValidation case Fail(:final failure)) {
        return Fail(failure);
      }

      // التحقق من أن الحساب الوجهة موجود ونشط
      if (transaction.note != null) {
        final targetAccountResult = await _accountRepo.getAccountById(
          transaction.note!,
        );
        if (targetAccountResult case Fail(:final failure)) {
          return Fail(failure);
        }

        final targetAccount =
            (targetAccountResult as Success<AccountEntity>).value;
        final targetActiveValidation = Validators.validateAccountActive(
          targetAccount.isActive,
          accountId: targetAccount.id,
        );
        if (targetActiveValidation case Fail(:final failure)) {
          return Fail(failure);
        }
      }
    }

    // 5. جميع التحققات نجحت - إنشاء المعاملة
    return await _transactionRepo.createTransaction(
      amount: transaction.amountMinor / 100.0, // Convert minor to main units
      type: transaction.type,
      categoryId: transaction.categoryId,
      accountId: transaction.accountId,
      date: transaction.date,
      note: transaction.note,
      receiptPath: transaction.receiptPath,
    );
  }
}

/// مثال مبسط على UseCase لحذف فئة مع التحقق
class DeleteCategoryUseCase {
  final CategoryRepository _categoryRepo;

  DeleteCategoryUseCase(this._categoryRepo);

  Future<Result<int>> execute(String categoryId) async {
    // التحقق من إمكانية الحذف (افترض 0 معاملات للتوضيح)
    const transactionsCount = 0;

    final canDeleteValidation = Validators.canDeleteCategory(transactionsCount);
    if (canDeleteValidation case Fail(:final failure)) {
      return Fail(failure);
    }

    // حذف الفئة
    return await _categoryRepo.deleteCategory(categoryId);
  }
}

/// مثال مبسط على UseCase لحذف حساب مع التحقق
class DeleteAccountUseCase {
  final AccountRepository _accountRepo;

  DeleteAccountUseCase(this._accountRepo);

  Future<Result<bool>> execute(
    String accountId, {
    bool requireZeroBalance = true,
  }) async {
    // 1. التحقق من وجود الحساب
    final accountResult = await _accountRepo.getAccountById(accountId);
    if (accountResult case Fail(:final failure)) {
      return Fail(failure);
    }

    final account = (accountResult as Success<AccountEntity>).value;

    // 2. التحقق من إمكانية الحذف (افترض 0 معاملات للتوضيح)
    const transactionsCount = 0;

    final canDeleteValidation = Validators.canDeleteAccount(
      transactionsCount: transactionsCount,
      balance: account.balanceMinor / 100.0, // Convert minor to main units
      requireZeroBalance: requireZeroBalance,
    );
    if (canDeleteValidation case Fail(:final failure)) {
      return Fail(failure);
    }

    // 3. حذف الحساب
    final deleteResult = await _accountRepo.deleteAccount(accountId);
    if (deleteResult case Fail(:final failure)) {
      return Fail(failure);
    }

    return const Success(true);
  }
}

/// مثال على UseCase لتحديث رصيد حساب مع التحقق
class UpdateAccountBalanceUseCase {
  final AccountRepository _accountRepo;

  UpdateAccountBalanceUseCase(this._accountRepo);

  Future<Result<bool>> execute(String accountId, double newBalance) async {
    // التحقق من الرصيد
    final balanceValidation = Validators.validateNonNegativeBalance(newBalance);
    if (balanceValidation case Fail(:final failure)) {
      return Fail(failure);
    }

    // تحديث الرصيد
    return await _accountRepo.updateBalance(accountId, newBalance);
  }
}

/// مثال على UseCase لإنشاء حساب جديد مع التحقق
class CreateAccountUseCase {
  final AccountRepository _accountRepo;

  CreateAccountUseCase(this._accountRepo);

  Future<Result<String>> execute({
    required String name,
    required double balance,
    required String type,
    required String color,
    String? icon,
  }) async {
    // 1. التحقق من الاسم
    final nameValidation = Validators.validateAccountName(name);
    if (nameValidation case Fail(:final failure)) {
      return Fail(failure);
    }

    // 2. التحقق من الرصيد
    final balanceValidation = Validators.validateNonNegativeBalance(balance);
    if (balanceValidation case Fail(:final failure)) {
      return Fail(failure);
    }

    // 3. إنشاء الحساب
    // تحويل النص إلى Enum
    final accountType = AccountType.values.firstWhere(
      (t) => t.name == type,
      orElse: () => AccountType.cash,
    );

    return await _accountRepo.createAccount(
      name: name,
      balance: balance,
      type: accountType,
      color: color,
      icon: icon,
    );
  }
}
