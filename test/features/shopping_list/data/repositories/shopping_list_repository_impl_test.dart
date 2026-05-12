import 'package:flutter_test/flutter_test.dart' hide ComparisonResult;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xepa_frontend/features/shopping_list/data/datasources/i_shopping_list_datasource.dart';
import 'package:xepa_frontend/features/shopping_list/data/repositories/shopping_list_repository_impl.dart';
import 'package:xepa_frontend/features/shopping_list/data/models/comparison_result_model.dart';
import 'package:xepa_frontend/features/shopping_list/data/models/shopping_list_model.dart';
import 'package:xepa_frontend/features/shopping_list/data/models/shopping_list_item_model.dart';

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

  final tShoppingListModel = const ShoppingListModel(
    id: 1,
    name: 'Lista Teste',
    color: '#FF0000',
    items: [],
  );

  final tShoppingListItemModel = const ShoppingListItemModel(
    id: 1,
    productId: 1,
    productName: 'Produto Teste',
    quantity: 1.0,
  );

  group('getShoppingLists', () {
    test('should return list of shopping lists when call is successful', () async {
      when(mockDataSource.getShoppingLists())
          .thenAnswer((_) async => [tShoppingListModel]);

      final result = await repository.getShoppingLists();

      expect(result, [tShoppingListModel]);
      verify(mockDataSource.getShoppingLists());
    });
  });

  group('getShoppingListById', () {
    test('should return shopping list when call is successful', () async {
      when(mockDataSource.getShoppingListById(any))
          .thenAnswer((_) async => tShoppingListModel);

      final result = await repository.getShoppingListById(tListId);

      expect(result, tShoppingListModel);
      verify(mockDataSource.getShoppingListById(tListId));
    });
  });

  group('createShoppingList', () {
    test('should return new shopping list when call is successful', () async {
      when(mockDataSource.createShoppingList(any))
          .thenAnswer((_) async => tShoppingListModel);

      final result = await repository.createShoppingList('Nova Lista');

      expect(result, tShoppingListModel);
      verify(mockDataSource.createShoppingList('Nova Lista'));
    });
  });

  group('deleteShoppingList', () {
    test('should return true when delete is successful', () async {
      when(mockDataSource.deleteShoppingList(any))
          .thenAnswer((_) async => true);

      final result = await repository.deleteShoppingList(tListId);

      expect(result, true);
      verify(mockDataSource.deleteShoppingList(tListId));
    });
  });

  group('addItemToList', () {
    test('should return added item when call is successful', () async {
      when(mockDataSource.addItemToList(any, any, any, any))
          .thenAnswer((_) async => tShoppingListItemModel);

      final result = await repository.addItemToList(1, 1, 1.0, 'nota');

      expect(result, tShoppingListItemModel);
      verify(mockDataSource.addItemToList(1, 1, 1.0, 'nota'));
    });
  });

  group('removeItemFromList', () {
    test('should return true when removal is successful', () async {
      when(mockDataSource.removeItemFromList(any, any))
          .thenAnswer((_) async => true);

      final result = await repository.removeItemFromList(1, 1);

      expect(result, true);
      verify(mockDataSource.removeItemFromList(1, 1));
    });
  });

  group('updateShoppingList', () {
    test('should return updated list when call is successful', () async {
      final updates = {'name': 'Updated'};
      when(mockDataSource.updateShoppingList(any, any))
          .thenAnswer((_) async => tShoppingListModel);

      final result = await repository.updateShoppingList(tListId, updates);

      expect(result, tShoppingListModel);
      verify(mockDataSource.updateShoppingList(tListId, updates));
    });
  });

  group('compareShoppingList', () {
    test('should return comparison result when call is successful', () async {
      when(mockDataSource.compareShoppingList(any))
          .thenAnswer((_) async => tComparisonResultModel);

      final result = await repository.compareShoppingList(tListId);

      expect(result, tComparisonResultModel);
      verify(mockDataSource.compareShoppingList(tListId));
    });

    test('should throw exception when call is unsuccessful', () async {
      when(mockDataSource.compareShoppingList(any))
          .thenThrow(Exception());

      expect(() => repository.compareShoppingList(tListId), throwsException);
    });
  });
}
