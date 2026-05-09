import 'package:xepa_frontend/features/supermarket_finder/domain/entities/supermarket.dart';
import 'package:xepa_frontend/features/supermarket_finder/domain/repositories/i_supermarket_repository.dart';
import 'package:xepa_frontend/features/product/data/models/product_price_model.dart';

class GetAllSupermarketsUseCase {
  final ISupermarketRepository _repository;
  GetAllSupermarketsUseCase(this._repository);
  Future<List<Supermarket>> call() => _repository.getAllSupermarkets();
}

class GetClosestSupermarketsUseCase {
  final ISupermarketRepository _repository;
  GetClosestSupermarketsUseCase(this._repository);
  Future<List<Supermarket>> call() => _repository.getClosestSupermarkets();
}

class SearchSupermarketsUseCase {
  final ISupermarketRepository _repository;
  SearchSupermarketsUseCase(this._repository);
  Future<List<Supermarket>> call(String query) =>
      _repository.searchSupermarkets(query);
}

class GetSupermarketProductsUseCase {
  final ISupermarketRepository _repository;
  GetSupermarketProductsUseCase(this._repository);
  Future<List<ProductPrice>> call(int supermarketId) =>
      _repository.getSupermarketProducts(supermarketId);
}
