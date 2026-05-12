import 'package:flutter_test/flutter_test.dart' hide ComparisonResult;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xepa_frontend/features/shopping_list/data/datasources/i_shopping_list_datasource.dart';
import 'package:xepa_frontend/features/shopping_list/data/repositories/shopping_list_repository_impl.dart';
import 'package:xepa_frontend/features/shopping_list/data/models/comparison_result_model.dart';

import 'shopping_list_repository_impl_test.mocks.dart';

@GenerateMocks([IShoppingListDataSource])
void main() {
  late ShoppingListRepositoryImpl repository;
  late MockIShoppingListDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockIShoppingListDataSource();
    repository = ShoppingListRepositoryImpl(mockDataSource);
  });

  const tListId = 1;
  final tComparisonResultModel = ComparisonResultModel(
    shoppingListName: 'Teste',
    totalItemsInList: 5,
    comparisonDate: DateTime(2024),
    supermarketsCompared: 3,
    comparisons: const [],
  );

  test('should return comparison result when the call to datasource is successful', () async {
    // arrange
    when(mockDataSource.compareShoppingList(any))
        .thenAnswer((_) async => tComparisonResultModel);

    // act
    final result = await repository.compareShoppingList(tListId);

    // assert
    expect(result, tComparisonResultModel);
    verify(mockDataSource.compareShoppingList(tListId));
  });

  test('should throw exception when the call to datasource is unsuccessful', () async {
    // arrange
    when(mockDataSource.compareShoppingList(any))
        .thenThrow(Exception('DataSource Error'));

    // act
    final call = repository.compareShoppingList;

    // assert
    expect(() => call(tListId), throwsException);
  });
}
