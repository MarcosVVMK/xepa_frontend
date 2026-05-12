import 'package:xepa_frontend/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:xepa_frontend/features/shopping_list/domain/repositories/i_shopping_list_repository.dart';

class GetShoppingListByIdUseCase {
  final IShoppingListRepository _repository;
  GetShoppingListByIdUseCase(this._repository);
  Future<ShoppingList> call(int id) => _repository.getShoppingListById(id);
}
