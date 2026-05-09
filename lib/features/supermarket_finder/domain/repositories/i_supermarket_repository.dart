import 'package:xepa_frontend/features/supermarket_finder/domain/entities/supermarket.dart';
import 'package:xepa_frontend/features/product/data/models/product_price_model.dart';

abstract class ISupermarketRepository {
  Future<List<Supermarket>> getAllSupermarkets();
  Future<List<Supermarket>> getClosestSupermarkets();
  Future<List<Supermarket>> searchSupermarkets(String query);
  Future<List<ProductPrice>> getSupermarketProducts(int supermarketId);
}
