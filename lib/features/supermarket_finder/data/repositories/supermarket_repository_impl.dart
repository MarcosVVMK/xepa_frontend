import 'package:xepa_frontend/features/supermarket_finder/data/datasources/i_supermarket_datasource.dart';
import 'package:xepa_frontend/features/supermarket_finder/domain/entities/supermarket.dart';
import 'package:xepa_frontend/features/supermarket_finder/domain/repositories/i_supermarket_repository.dart';
import 'package:xepa_frontend/features/product/data/models/product_price_model.dart';

class SupermarketRepositoryImpl implements ISupermarketRepository {
  final ISupermarketDataSource _dataSource;

  SupermarketRepositoryImpl(this._dataSource);

  @override
  Future<List<Supermarket>> getAllSupermarkets() =>
      _dataSource.getAllSupermarkets();

  @override
  Future<List<Supermarket>> getClosestSupermarkets() =>
      _dataSource.getClosestSupermarkets();

  @override
  Future<List<Supermarket>> searchSupermarkets(String query) =>
      _dataSource.searchSupermarkets(query);

  @override
  Future<List<ProductPrice>> getSupermarketProducts(int supermarketId) =>
      _dataSource.getSupermarketProducts(supermarketId);
}
