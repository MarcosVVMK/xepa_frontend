import 'package:xepa_frontend/features/shopping_list/data/models/shopping_list_model.dart';

abstract class IShoppingListDataSource {
  Future<List<ShoppingListModel>> getShoppingLists();
  Future<ShoppingListModel> getShoppingListById(int id);
  Future<ShoppingListModel> createShoppingList(String name);
  Future<bool> deleteShoppingList(int id);
  Future<ShoppingListItemModel> addItemToList(int listId, int productId, double quantity, String notes);
  Future<bool> removeItemFromList(int listId, int itemId);
  Future<ShoppingListModel> updateShoppingList(int id, Map<String, dynamic> updates);
}
