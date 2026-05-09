import 'package:xepa_frontend/features/supermarket_finder/data/models/supermarket_model.dart';
import 'package:xepa_frontend/features/product/data/models/product_price_model.dart';

abstract class ISupermarketDataSource {
  Future<List<SupermarketModel>> getAllSupermarkets();
  Future<List<SupermarketModel>> getClosestSupermarkets();
  Future<List<SupermarketModel>> searchSupermarkets(String query);
  Future<List<ProductPrice>> getSupermarketProducts(int supermarketId);
}
