import 'package:xepa_frontend/features/product/data/datasources/i_product_datasource.dart';
import 'package:xepa_frontend/features/product/data/models/product_price_model.dart';
import 'package:xepa_frontend/features/product/domain/entities/product.dart';
import 'package:xepa_frontend/features/product/domain/repositories/i_product_repository.dart';

class ProductRepositoryImpl implements IProductRepository {
  final IProductDataSource _dataSource;

  ProductRepositoryImpl(this._dataSource);

  @override
  Future<List<Product>> getAllProducts({int page = 0, int size = 10}) =>
      _dataSource.getAllProducts(page: page, size: size);

  @override
  Future<List<Product>> searchProducts(
    String query, {
    int page = 0,
    int size = 10,
  }) =>
      _dataSource.searchProducts(query, page: page, size: size);

  @override
  Future<List<ProductPrice>> getCheapestProducts() =>
      _dataSource.getCheapestProducts();

  @override
  Future<List<ProductPrice>> getClosestProducts() =>
      _dataSource.getClosestProducts();

  @override
  Future<List<ProductPrice>> getProductPrices(int productId) =>
      _dataSource.getProductPrices(productId);
}
