import 'package:xepa_frontend/features/shopping_list/domain/repositories/i_shopping_list_repository.dart';

class DeleteShoppingListUseCase {
  final IShoppingListRepository _repository;
  DeleteShoppingListUseCase(this._repository);
  Future<bool> call(int id) => _repository.deleteShoppingList(id);
}
