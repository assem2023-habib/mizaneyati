// lib/domain/usecases/transaction_usecase_example.dart
//
// هذا مثال توضيحي لكيفية استخدام Validators في UseCase
// يمكنك نسخ هذا النمط واستخدامه في UseCases الحقيقية

import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../core/validation/validators.dart';
import '../../core/constants/transaction_type.dart';
import '../entities/transaction_entity.dart';
import '../entities/account_entity.dart';
import '../entities/category_entity.dart';
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
  final CategoryRepository _categoryRepo;

  CreateTransactionUseCase(
    this._transactionRepo,
    this._accountRepo,
    this._categoryRepo,
  );

  /// تنفيذ UseCase لإنشاء معاملة جديدة
  ///
  /// الخطوات:
  /// 1. التحقق من صحة البيانات الأساسية (المبلغ، التاريخ)
  /// 2. التحقق من وجود وحالة الحساب
  /// 3. التحقق من وجود وتطابق الفئة (للدخل والمصروفات)
  /// 4. التحقق الخاص بالتحويلات
  /// 5. إنشاء المعاملة في قاعدة البيانات
  Future<Result<String>> execute(TransactionEntity transaction) async {
    // 1. التحقق من المبلغ
    final amountValidation = Validators.validateAmount(transaction.amount);
    if (amountValidation is Fail) {
      // تحويل Result<void> إلى Result<String>
      return Fail((amountValidation as Fail).failure);
    }

    // 2. التحقق من التاريخ
    final dateValidation = Validators.validateNotFutureDate(transaction.date);
    if (dateValidation is Fail) {
      return Fail((dateValidation as Fail).failure);
    }

    // 3. التحقق من الحساب
    final accountResult = await _accountRepo.getAccountById(
      transaction.accountId,
    );
    if (accountResult is Fail) {
      return Fail((accountResult as Fail).failure);
    }

    final account = (accountResult as Success<AccountEntity>).value;
    final accountActiveValidation = Validators.validateAccountActive(
      account.isActive,
      accountId: account.id,
    );
    if (accountActiveValidation is Fail) {
      return Fail((accountActiveValidation as Fail).failure);
    }

    // 4. التحقق من الفئة (للدخل والمصروفات فقط)
    if (transaction.type != TransactionType.transfer) {
      final categoryResult = await _categoryRepo.getCategoryById(
        transaction.categoryId,
      );
      if (categoryResult is Fail) {
        return Fail((categoryResult as Fail).failure);
      }

      final category = (categoryResult as Success<CategoryEntity>).value;
      final categoryValidation = Validators.validateCategoryForTransaction(
        transaction.type,
        category.type,
        categoryId: category.id,
      );
      if (categoryValidation is Fail) {
        return Fail((categoryValidation as Fail).failure);
      }
    }

    // 5. التحقق الخاص بالتحويلات
    if (transaction.type == TransactionType.transfer) {
      // في حالة التحويل، يجب تحديد الحساب الوجهة
      // (افترض أن note تحتوي على targetAccountId مؤقتاً)
      final transferValidation = Validators.validateTransfer(
        fromAccountId: transaction.accountId,
        toAccountId:
            transaction.note, // في التطبيق الحقيقي، ستكون هناك خاصية منفصلة
      );
      if (transferValidation is Fail) {
        return Fail((transferValidation as Fail).failure);
      }

      // التحقق من أن الحساب الوجهة موجود ونشط
      if (transaction.note != null) {
        final targetAccountResult = await _accountRepo.getAccountById(
          transaction.note!,
        );
        if (targetAccountResult is Fail) {
          return Fail((targetAccountResult as Fail).failure);
        }

        final targetAccount =
            (targetAccountResult as Success<AccountEntity>).value;
        final targetActiveValidation = Validators.validateAccountActive(
          targetAccount.isActive,
          accountId: targetAccount.id,
        );
        if (targetActiveValidation is Fail) {
          return Fail((targetActiveValidation as Fail).failure);
        }
      }
    }

    // 6. جميع التحققات نجحت - إنشاء المعاملة
    return await _transactionRepo.createTransaction(transaction);
  }
}

/// مثال على UseCase لحذف فئة مع التحقق
///
/// ملاحظة: هذا مثال مبسط. في التطبيق الحقيقي، ستحتاج لإضافة
/// دالة getTransactionsByCategory في TransactionRepository
class DeleteCategoryUseCase {
  final CategoryRepository _categoryRepo;
  // final TransactionRepository _transactionRepo; // سيتم استخدامه عند توفر الدالة

  DeleteCategoryUseCase(this._categoryRepo);

  Future<Result<bool>> execute(String categoryId) async {
    // 1. التحقق من وجود الفئة
    final categoryResult = await _categoryRepo.getCategoryById(categoryId);
    if (categoryResult is Fail) {
      return Fail((categoryResult as Fail).failure);
    }

    // 2. حذف الفئة
    return await _categoryRepo.deleteCategory(categoryId);
  }
}

/// مثال على UseCase لحذف حساب مع التحقق
///
/// ملاحظة: هذا مثال مبسط. في التطبيق الحقيقي، ستحتاج لإضافة
/// دالة getTransactionsByAccount في TransactionRepository
class DeleteAccountUseCase {
  final AccountRepository _accountRepo;
  // final TransactionRepository _transactionRepo; // سيتم استخدامه عند توفر الدالة

  DeleteAccountUseCase(this._accountRepo);

  Future<Result<bool>> execute(
    String accountId, {
    bool requireZeroBalance = true,
  }) async {
    // 1. التحقق من وجود الحساب
    final accountResult = await _accountRepo.getAccountById(accountId);
    if (accountResult is Fail) {
      return Fail((accountResult as Fail).failure);
    }

    final account = (accountResult as Success<AccountEntity>).value;

    // 2. عد المعاملات المرتبطة بهذا الحساب
    // ملاحظة: ستحتاج لإضافة هذه الدالة في TransactionRepository:
    // Future<Result<List<TransactionEntity>>> getTransactionsByAccount(String accountId)

    // مثال مبسط - افترض عدد المعاملات = 0 للتوضيح فقط
    const transactionsCount = 0; // في الواقع، استدعي الـ repository

    // 3. التحقق من إمكانية الحذف
    final canDeleteValidation = Validators.canDeleteAccount(
      transactionsCount: transactionsCount,
      balance: account.balance,
      requireZeroBalance: requireZeroBalance,
    );
    if (canDeleteValidation is Fail) {
      return Fail((canDeleteValidation as Fail).failure);
    }

    // 4. حذف الحساب
    final deleteResult = await _accountRepo.deleteAccount(accountId);
    if (deleteResult is Fail) {
      return Fail((deleteResult as Fail).failure);
    }

    return const Success(true);
  }
}
