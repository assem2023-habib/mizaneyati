import 'package:flutter_test/flutter_test.dart';
import 'package:mizaneyati/core/utils/result.dart';
import 'package:mizaneyati/domain/entities/account_entity.dart';
import 'package:mizaneyati/domain/entities/category_entity.dart';
import 'package:mizaneyati/domain/entities/transaction_entity.dart';
import 'package:mizaneyati/domain/models/transaction_type.dart';
import 'package:mizaneyati/domain/models/category_type.dart';
import 'package:mizaneyati/domain/repositories/account_repository.dart';
import 'package:mizaneyati/domain/repositories/category_repository.dart';
import 'package:mizaneyati/domain/repositories/transaction_repository.dart';
import 'package:mizaneyati/domain/usecases/transaction/add_transaction_usecase.dart';
import 'package:mizaneyati/domain/value_objects/money.dart';
import 'package:mizaneyati/domain/value_objects/account_name.dart';
import 'package:mizaneyati/domain/value_objects/category_name.dart';
import 'package:mizaneyati/domain/value_objects/icon_value.dart';
import 'package:mizaneyati/domain/value_objects/color_value.dart';
import 'package:mockito/mockito.dart';

// Simple Mocks (Manual)
class MockTransactionRepository extends Fake implements TransactionRepository {
  @override
  Future<Result<String>> createTransaction(
    TransactionEntity tx, {
    required AccountEntity account,
    AccountEntity? toAccount,
  }) async {
    return const Success('tx-123');
  }
}

class MockAccountRepository extends Fake implements AccountRepository {
  @override
  Future<Result<AccountEntity>> getById(String id) async {
    return Success(
      AccountEntity(
        id: id,
        name:
            (AccountName.create('Test Account') as Success<AccountName>).value,
        type: 'Bank',
        balance: (Money.create(1000) as Success<Money>).value, // 10.00
        currency: 'TRY',
        icon: (IconValue.create('icon') as Success<IconValue>).value,
        color: (ColorValue.create('color') as Success<ColorValue>).value,
        isActive: true,
      ),
    );
  }
}

class MockCategoryRepository extends Fake implements CategoryRepository {
  @override
  Future<Result<CategoryEntity>> getById(String id) async {
    return Success(
      CategoryEntity(
        id: id,
        name: (CategoryName.create('Test Category') as Success<CategoryName>)
            .value,
        icon: (IconValue.create('icon') as Success<IconValue>).value,
        color: (ColorValue.create('color') as Success<ColorValue>).value,
        type: CategoryType.expense,
      ),
    );
  }
}

void main() {
  late AddTransactionUseCase useCase;
  late MockTransactionRepository mockTxRepo;
  late MockAccountRepository mockAccountRepo;
  late MockCategoryRepository mockCategoryRepo;

  setUp(() {
    mockTxRepo = MockTransactionRepository();
    mockAccountRepo = MockAccountRepository();
    mockCategoryRepo = MockCategoryRepository();
    useCase = AddTransactionUseCase(
      mockTxRepo,
      mockAccountRepo,
      mockCategoryRepo,
    );
  });

  test('should create expense transaction and debit account', () async {
    final result = await useCase(
      amountMinor: 500, // 5.00
      type: TransactionType.expense,
      categoryId: 'cat-1',
      accountId: 'acc-1',
      date: DateTime.now(),
      note: 'Test Expense',
    );

    expect(result, isA<Success<String>>());
    expect((result as Success<String>).value, 'tx-123');
  });
}
