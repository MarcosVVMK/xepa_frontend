import 'package:xepa_frontend/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:xepa_frontend/features/shopping_list/domain/repositories/i_shopping_list_repository.dart';

class GetShoppingListsUseCase {
  final IShoppingListRepository _repository;
  GetShoppingListsUseCase(this._repository);
  Future<List<ShoppingList>> call() => _repository.getShoppingLists();
}
