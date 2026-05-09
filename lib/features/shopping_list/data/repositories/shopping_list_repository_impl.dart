import 'package:xepa_frontend/features/shopping_list/data/datasources/i_shopping_list_datasource.dart';
import 'package:xepa_frontend/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:xepa_frontend/features/shopping_list/domain/repositories/i_shopping_list_repository.dart';

class ShoppingListRepositoryImpl implements IShoppingListRepository {
  final IShoppingListDataSource _dataSource;

  ShoppingListRepositoryImpl(this._dataSource);

  @override
  Future<List<ShoppingList>> getShoppingLists() =>
      _dataSource.getShoppingLists();

  @override
  Future<ShoppingList> getShoppingListById(int id) =>
      _dataSource.getShoppingListById(id);

  @override
  Future<ShoppingList> createShoppingList(String name) =>
      _dataSource.createShoppingList(name);

  @override
  Future<bool> deleteShoppingList(int id) =>
      _dataSource.deleteShoppingList(id);

  @override
  Future<ShoppingListItem> addItemToList(
    int listId,
    int productId,
    double quantity,
    String notes,
  ) =>
      _dataSource.addItemToList(listId, productId, quantity, notes);

  @override
  Future<bool> removeItemFromList(int listId, int itemId) =>
      _dataSource.removeItemFromList(listId, itemId);

  @override
  Future<ShoppingList> updateShoppingList(
    int id,
    Map<String, dynamic> updates,
  ) =>
      _dataSource.updateShoppingList(id, updates);
}
