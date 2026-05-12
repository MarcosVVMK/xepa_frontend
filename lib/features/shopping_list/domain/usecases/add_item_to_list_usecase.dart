import 'package:xepa_frontend/features/shopping_list/domain/entities/shopping_list_item.dart';
import 'package:xepa_frontend/features/shopping_list/domain/repositories/i_shopping_list_repository.dart';

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
