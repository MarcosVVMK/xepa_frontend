import 'package:flutter_test/flutter_test.dart' hide ComparisonResult;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xepa_frontend/features/shopping_list/domain/repositories/i_shopping_list_repository.dart';
import 'package:xepa_frontend/features/shopping_list/domain/usecases/compare_shopping_list_usecase.dart';
import 'package:xepa_frontend/features/shopping_list/domain/entities/comparison_result.dart';

import 'compare_shopping_list_usecase_test.mocks.dart';

@GenerateMocks([IShoppingListRepository])
void main() {
  late CompareShoppingListUseCase useCase;
  late MockIShoppingListRepository mockRepository;

  setUp(() {
    mockRepository = MockIShoppingListRepository();
    useCase = CompareShoppingListUseCase(mockRepository);
  });

  const tListId = 1;
  final tComparisonResult = ComparisonResult(
    shoppingListName: 'Teste',
    totalItemsInList: 5,
    comparisonDate: DateTime.now(),
    supermarketsCompared: 3,
    comparisons: const [],
  );

  test('should get comparison result from the repository', () async {
    // arrange
    when(mockRepository.compareShoppingList(any))
        .thenAnswer((_) async => tComparisonResult);

    // act
    final result = await useCase(tListId);

    // assert
    expect(result, tComparisonResult);
    verify(mockRepository.compareShoppingList(tListId));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw an exception when repository fails', () async {
    // arrange
    when(mockRepository.compareShoppingList(any))
        .thenThrow(Exception('Server Error'));

    // act & assert
    expect(() => useCase(tListId), throwsException);
    verify(mockRepository.compareShoppingList(tListId));
  });
}
