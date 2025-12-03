import 'package:flutter_test/flutter_test.dart';
import 'package:mizaneyati/core/utils/result.dart';
import 'package:mizaneyati/domain/entities/budget_entity.dart';
import 'package:mizaneyati/domain/entities/category_entity.dart';
import 'package:mizaneyati/domain/models/category_type.dart';
import 'package:mizaneyati/domain/repositories/budget_repository.dart';
import 'package:mizaneyati/domain/repositories/category_repository.dart';
import 'package:mizaneyati/domain/usecases/budget/create_budget_usecase.dart';
import 'package:mizaneyati/domain/value_objects/money.dart';
import 'package:mizaneyati/domain/value_objects/date_value.dart';
import 'package:mizaneyati/domain/value_objects/category_name.dart';
import 'package:mizaneyati/domain/value_objects/icon_value.dart';
import 'package:mizaneyati/domain/value_objects/color_value.dart';
import 'package:mockito/mockito.dart';

class MockBudgetRepository extends Fake implements BudgetRepository {
  final List<BudgetEntity> existingBudgets;
  MockBudgetRepository(this.existingBudgets);

  @override
  Future<Result<List<BudgetEntity>>> getByCategory(String categoryId) async {
    return Success(existingBudgets);
  }

  @override
  Future<Result<Object>> create(BudgetEntity budget) async {
    return const Success('budget-123');
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
  late CreateBudgetUseCase useCase;
  late MockCategoryRepository mockCategoryRepo;

  setUp(() {
    mockCategoryRepo = MockCategoryRepository();
  });

  test('should create budget when no overlap', () async {
    final mockBudgetRepo = MockBudgetRepository([]);
    useCase = CreateBudgetUseCase(mockBudgetRepo, mockCategoryRepo);

    final result = await useCase(
      limitAmountMinor: 1000,
      categoryId: 'cat-1',
      startDate: DateTime(2023, 1, 1),
      endDate: DateTime(2023, 1, 31),
    );

    expect(result, isA<Success<Object>>());
  });

  test('should fail when overlap exists', () async {
    final existingBudget = BudgetEntity(
      id: 'b1',
      categoryId: 'cat-1',
      limitAmount: (Money.create(1000) as Success<Money>).value,
      startDate:
          (DateValue.create(DateTime(2023, 1, 1)) as Success<DateValue>).value,
      endDate:
          (DateValue.create(DateTime(2023, 1, 31)) as Success<DateValue>).value,
      isActive: true,
    );
    final mockBudgetRepo = MockBudgetRepository([existingBudget]);
    useCase = CreateBudgetUseCase(mockBudgetRepo, mockCategoryRepo);

    final result = await useCase(
      limitAmountMinor: 1000,
      categoryId: 'cat-1',
      startDate: DateTime(2023, 1, 15), // Overlaps
      endDate: DateTime(2023, 2, 15),
    );

    expect(result, isA<Fail<Object>>());
  });
}
