import 'package:xepa_frontend/features/shopping_list/domain/repositories/i_shopping_list_repository.dart';

class RemoveItemFromListUseCase {
  final IShoppingListRepository _repository;
  RemoveItemFromListUseCase(this._repository);
  Future<bool> call(int listId, int itemId) =>
      _repository.removeItemFromList(listId, itemId);
}
