import 'package:xepa_frontend/features/shopping_list/domain/entities/comparison_result.dart';
import 'package:xepa_frontend/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:xepa_frontend/features/shopping_list/domain/entities/shopping_list_item.dart';

abstract class IShoppingListRepository {
  Future<List<ShoppingList>> getShoppingLists();
  Future<ShoppingList> getShoppingListById(int id);
  Future<ShoppingList> createShoppingList(String name);
  Future<bool> deleteShoppingList(int id);
  Future<ShoppingListItem> addItemToList(
    int listId,
    int productId,
    double quantity,
    String notes,
  );
  Future<bool> removeItemFromList(int listId, int itemId);
  Future<ShoppingList> updateShoppingList(int id, Map<String, dynamic> updates);
  Future<ComparisonResult> compareShoppingList(int id);
}
