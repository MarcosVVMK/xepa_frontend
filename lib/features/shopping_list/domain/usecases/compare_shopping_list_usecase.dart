import 'package:xepa_frontend/features/shopping_list/domain/entities/comparison_result.dart';
import 'package:xepa_frontend/features/shopping_list/domain/repositories/i_shopping_list_repository.dart';

class CompareShoppingListUseCase {
  final IShoppingListRepository _repository;
  CompareShoppingListUseCase(this._repository);
  Future<ComparisonResult> call(int id) => _repository.compareShoppingList(id);
}
