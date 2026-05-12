import 'package:xepa_frontend/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:xepa_frontend/features/shopping_list/domain/repositories/i_shopping_list_repository.dart';

class CreateShoppingListUseCase {
  final IShoppingListRepository _repository;
  CreateShoppingListUseCase(this._repository);
  Future<ShoppingList> call(String name) => _repository.createShoppingList(name);
}
