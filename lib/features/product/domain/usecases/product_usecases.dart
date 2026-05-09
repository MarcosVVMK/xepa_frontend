import 'package:xepa_frontend/features/product/domain/entities/product.dart';
import 'package:xepa_frontend/features/product/domain/repositories/i_product_repository.dart';
import 'package:xepa_frontend/features/product/data/models/product_price_model.dart';

class GetAllProductsUseCase {
  final IProductRepository _repository;
  GetAllProductsUseCase(this._repository);
  Future<List<Product>> call({int page = 0, int size = 10}) =>
      _repository.getAllProducts(page: page, size: size);
}

class SearchProductsUseCase {
  final IProductRepository _repository;
  SearchProductsUseCase(this._repository);
  Future<List<Product>> call(String query, {int page = 0, int size = 10}) =>
      _repository.searchProducts(query, page: page, size: size);
}

class GetCheapestProductsUseCase {
  final IProductRepository _repository;
  GetCheapestProductsUseCase(this._repository);
  Future<List<ProductPrice>> call() => _repository.getCheapestProducts();
}

class GetClosestProductsUseCase {
  final IProductRepository _repository;
  GetClosestProductsUseCase(this._repository);
  Future<List<ProductPrice>> call() => _repository.getClosestProducts();
}

class GetProductPricesUseCase {
  final IProductRepository _repository;
  GetProductPricesUseCase(this._repository);
  Future<List<ProductPrice>> call(int productId) =>
      _repository.getProductPrices(productId);
}
