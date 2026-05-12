import 'package:xepa_frontend/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:xepa_frontend/features/shopping_list/domain/repositories/i_shopping_list_repository.dart';

class UpdateShoppingListUseCase {
  final IShoppingListRepository _repository;
  UpdateShoppingListUseCase(this._repository);
  Future<ShoppingList> call(int id, Map<String, dynamic> updates) =>
      _repository.updateShoppingList(id, updates);
}
