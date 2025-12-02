import 'package:uuid/uuid.dart';
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';
import '../entities/transaction_entity.dart';
import '../entities/account_entity.dart';
import '../entities/category_entity.dart';
import '../models/transaction_type.dart';
import '../models/category_type.dart';
import '../value_objects/money.dart';
import '../value_objects/date_value.dart';
import '../value_objects/note_value.dart';

/// Example UseCase demonstrating proper Value Objects usage
///
/// This is a REFERENCE IMPLEMENTATION showing best practices for:
/// - Using VOs for validation
/// - Handling Result<T> pattern
/// - Proper error propagation
/// - Repository interaction patterns
///
/// ⚠️ This file is for documentation purposes.
/// Real implementations should follow this pattern.

// Pseudo interfaces - in real code these would be abstract classes
abstract class TransactionRepository {
  Future<Result<String>> createTransaction(TransactionEntity entity);
  Future<Result<void>> updateAccountBalance(String accountId, int amountMinor);
}

abstract class AccountRepository {
  Future<Result<AccountEntity>> getAccountById(String id);
}

abstract class CategoryRepository {
  Future<Result<CategoryEntity>> getCategoryById(String id);
}

/// Request object for creating a transaction
class CreateTransactionRequest {
  final int amountMinor;
  final TransactionType type;
  final String accountId;
  final String categoryId;
  final DateTime? date;
  final String? note;

  const CreateTransactionRequest({
    required this.amountMinor,
    required this.type,
    required this.accountId,
    required this.categoryId,
    this.date,
    this.note,
  });
}

/// UseCase for creating a transaction with full validation
class AddTransactionUseCase {
  final TransactionRepository transactionRepo;
  final AccountRepository accountRepo;
  final CategoryRepository categoryRepo;
  final Uuid uuid;

  AddTransactionUseCase({
    required this.transactionRepo,
    required this.accountRepo,
    required this.categoryRepo,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  /// Executes the use case
  ///
  /// Returns [Success<String>] with transaction ID if successful
  /// Returns [Fail<String>] with appropriate failure if validation or execution fails
  Future<Result<String>> execute(CreateTransactionRequest request) async {
    // ========================================
    // STEP 1: Validate Value Objects
    // ========================================

    // Validate money amount
    final moneyResult = Money.create(request.amountMinor);
    if (moneyResult is Fail) {
      return Fail((moneyResult as Fail).failure);
    }
    final money = (moneyResult as Success<Money>).value;

    // Validate date (use current date if not provided)
    final dateResult = DateValue.create(request.date ?? DateTime.now());
    if (dateResult is Fail) {
      return Fail((dateResult as Fail).failure);
    }
    final dateValue = (dateResult as Success<DateValue>).value;

    // Validate optional note
    final noteResult = NoteValue.create(request.note);
    if (noteResult is Fail) {
      return Fail((noteResult as Fail).failure);
    }
    final noteValue = (noteResult as Success<NoteValue>).value;

    // ========================================
    // STEP 2: Verify Account Exists and Is Active
    // ========================================

    final accountResult = await accountRepo.getAccountById(request.accountId);
    if (accountResult is Fail) {
      return Fail((accountResult as Fail).failure);
    }

    final account = (accountResult as Success<AccountEntity>).value;

    if (!account.isActive) {
      return const Fail(
        ValidationFailure('Account is inactive', code: 'account_inactive'),
      );
    }

    // ========================================
    // STEP 3: Verify Category Exists and Type Matches
    // ========================================

    final categoryResult = await categoryRepo.getCategoryById(
      request.categoryId,
    );
    if (categoryResult is Fail) {
      return Fail((categoryResult as Fail).failure);
    }

    final category = (categoryResult as Success<CategoryEntity>).value;

    // Validate category type matches transaction type
    if ((request.type == TransactionType.expense &&
            category.type != CategoryType.expense) ||
        (request.type == TransactionType.income &&
            category.type != CategoryType.income)) {
      return const Fail(
        ValidationFailure(
          'Category type does not match transaction type',
          code: 'category_type_mismatch',
        ),
      );
    }

    // ========================================
    // STEP 4: Create Transaction Entity
    // ========================================

    final transactionEntity = TransactionEntity(
      id: uuid.v4(),
      amountMinor: money.toMinor(),
      type: request.type,
      categoryId: request.categoryId,
      accountId: request.accountId,
      date: dateValue.value,
      note: noteValue.value,
      createdAt: DateTime.now(),
    );

    // ========================================
    // STEP 5: Persist Transaction
    // ========================================
    // Note: Repository should handle the DB transaction:
    // - Insert transaction record
    // - Update account balance accordingly

    final createResult = await transactionRepo.createTransaction(
      transactionEntity,
    );

    if (createResult is Fail) {
      return Fail((createResult as Fail).failure);
    }

    // Calculate balance change (negative for expenses, positive for income)
    final balanceChange = request.type == TransactionType.expense
        ? -money.toMinor()
        : money.toMinor();

    final updateBalanceResult = await transactionRepo.updateAccountBalance(
      request.accountId,
      balanceChange,
    );

    if (updateBalanceResult is Fail) {
      return Fail((updateBalanceResult as Fail).failure);
    }

    // ========================================
    // STEP 6: Return Success with Transaction ID
    // ========================================

    return Success(transactionEntity.id);
  }
}

/// ========================================
/// PATTERN SUMMARY
/// ========================================
/// 
/// 1️⃣ VOs validate input at creation:
///    - Money.create() ensures non-negative amounts
///    - DateValue.create() prevents future dates
///    - NoteValue.create() enforces length limits
/// 
/// 2️⃣ All validation returns Result<T>:
///    - Pattern matching (is Success / is Fail)
///    - Early return on failure
///    - Type-safe value extraction
/// 
/// 3️⃣ Business rules in UseCase:
///    - Account must be active
///    - Category type must match transaction type
///    - These checks happen AFTER VO validation
/// 
/// 4️⃣ Repository handles persistence:
///    - DB transactions for consistency
///    - Maps entities to/from DB models
///    - Converts exceptions to Failures
/// 
/// 5️⃣ Error codes support i18n:
///    - 'money_negative'
///    - 'account_inactive'
///    - 'category_type_mismatch'
///    - UI can map these to translated messages
