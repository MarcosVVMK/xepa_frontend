import 'package:xepa_frontend/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:xepa_frontend/features/shopping_list/domain/repositories/i_shopping_list_repository.dart';

class GetShoppingListsUseCase {
  final IShoppingListRepository _repository;
  GetShoppingListsUseCase(this._repository);
  Future<List<ShoppingList>> call() => _repository.getShoppingLists();
}

class GetShoppingListByIdUseCase {
  final IShoppingListRepository _repository;
  GetShoppingListByIdUseCase(this._repository);
  Future<ShoppingList> call(int id) => _repository.getShoppingListById(id);
}

class CreateShoppingListUseCase {
  final IShoppingListRepository _repository;
  CreateShoppingListUseCase(this._repository);
  Future<ShoppingList> call(String name) => _repository.createShoppingList(name);
}

class DeleteShoppingListUseCase {
  final IShoppingListRepository _repository;
  DeleteShoppingListUseCase(this._repository);
  Future<bool> call(int id) => _repository.deleteShoppingList(id);
}

class AddItemToListUseCase {
  final IShoppingListRepository _repository;
  AddItemToListUseCase(this._repository);
  Future<ShoppingListItem> call(
    int listId,
    int productId,
    double quantity,
    String notes,
  ) =>
      _repository.addItemToList(listId, productId, quantity, notes);
}

class RemoveItemFromListUseCase {
  final IShoppingListRepository _repository;
  RemoveItemFromListUseCase(this._repository);
  Future<bool> call(int listId, int itemId) =>
      _repository.removeItemFromList(listId, itemId);
}

class UpdateShoppingListUseCase {
  final IShoppingListRepository _repository;
  UpdateShoppingListUseCase(this._repository);
  Future<ShoppingList> call(int id, Map<String, dynamic> updates) =>
      _repository.updateShoppingList(id, updates);
}
