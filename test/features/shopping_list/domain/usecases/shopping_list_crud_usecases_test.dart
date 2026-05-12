import 'package:flutter_test/flutter_test.dart' hide ComparisonResult;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xepa_frontend/features/shopping_list/domain/repositories/i_shopping_list_repository.dart';
import 'package:xepa_frontend/features/shopping_list/domain/usecases/get_shopping_lists_usecase.dart';
import 'package:xepa_frontend/features/shopping_list/domain/usecases/create_shopping_list_usecase.dart';
import 'package:xepa_frontend/features/shopping_list/domain/usecases/delete_shopping_list_usecase.dart';
import 'package:xepa_frontend/features/shopping_list/domain/usecases/add_item_to_list_usecase.dart';
import 'package:xepa_frontend/features/shopping_list/domain/usecases/remove_item_from_list_usecase.dart';
import 'package:xepa_frontend/features/shopping_list/domain/usecases/get_shopping_list_by_id_usecase.dart';
import 'package:xepa_frontend/features/shopping_list/domain/usecases/update_shopping_list_usecase.dart';
import 'package:xepa_frontend/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:xepa_frontend/features/shopping_list/domain/entities/shopping_list_item.dart';

import 'shopping_list_crud_usecases_test.mocks.dart';

@GenerateMocks([IShoppingListRepository])
void main() {
  late MockIShoppingListRepository mockRepository;
  
  late GetShoppingListsUseCase getListsUseCase;
  late CreateShoppingListUseCase createListUseCase;
  late DeleteShoppingListUseCase deleteListUseCase;
  late AddItemToListUseCase addItemUseCase;
  late RemoveItemFromListUseCase removeItemUseCase;
  late GetShoppingListByIdUseCase getByIdUseCase;
  late UpdateShoppingListUseCase updateUseCase;

  setUp(() {
    mockRepository = MockIShoppingListRepository();
    getListsUseCase = GetShoppingListsUseCase(mockRepository);
    createListUseCase = CreateShoppingListUseCase(mockRepository);
    deleteListUseCase = DeleteShoppingListUseCase(mockRepository);
    addItemUseCase = AddItemToListUseCase(mockRepository);
    removeItemUseCase = RemoveItemFromListUseCase(mockRepository);
    getByIdUseCase = GetShoppingListByIdUseCase(mockRepository);
    updateUseCase = UpdateShoppingListUseCase(mockRepository);
  });

  final tShoppingList = const ShoppingList(id: 1, name: 'Test', color: 'red', items: []);
  final tShoppingListItem = const ShoppingListItem(id: 1, productId: 1, productName: 'Item', quantity: 1.0);

  test('GetShoppingListsUseCase should get lists from repository', () async {
    when(mockRepository.getShoppingLists()).thenAnswer((_) async => [tShoppingList]);
    final result = await getListsUseCase();
    expect(result, [tShoppingList]);
    verify(mockRepository.getShoppingLists());
  });

  test('CreateShoppingListUseCase should create list in repository', () async {
    when(mockRepository.createShoppingList(any)).thenAnswer((_) async => tShoppingList);
    final result = await createListUseCase('New List');
    expect(result, tShoppingList);
    verify(mockRepository.createShoppingList('New List'));
  });

  test('DeleteShoppingListUseCase should delete list in repository', () async {
    when(mockRepository.deleteShoppingList(any)).thenAnswer((_) async => true);
    final result = await deleteListUseCase(1);
    expect(result, true);
    verify(mockRepository.deleteShoppingList(1));
  });

  test('AddItemToListUseCase should add item in repository', () async {
    when(mockRepository.addItemToList(any, any, any, any)).thenAnswer((_) async => tShoppingListItem);
    final result = await addItemUseCase(1, 1, 1.0, 'note');
    expect(result, tShoppingListItem);
    verify(mockRepository.addItemToList(1, 1, 1.0, 'note'));
  });

  test('RemoveItemFromListUseCase should remove item from repository', () async {
    when(mockRepository.removeItemFromList(any, any)).thenAnswer((_) async => true);
    final result = await removeItemUseCase(1, 1);
    expect(result, true);
    verify(mockRepository.removeItemFromList(1, 1));
  });

  test('GetShoppingListByIdUseCase should get list from repository', () async {
    when(mockRepository.getShoppingListById(any)).thenAnswer((_) async => tShoppingList);
    final result = await getByIdUseCase(1);
    expect(result, tShoppingList);
    verify(mockRepository.getShoppingListById(1));
  });

  test('UpdateShoppingListUseCase should update list in repository', () async {
    final updates = {'name': 'Updated'};
    when(mockRepository.updateShoppingList(any, any)).thenAnswer((_) async => tShoppingList);
    final result = await updateUseCase(1, updates);
    expect(result, tShoppingList);
    verify(mockRepository.updateShoppingList(1, updates));
  });
}
