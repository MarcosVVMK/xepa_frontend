import 'package:xepa_frontend/features/product/data/models/product_model.dart';
import 'package:xepa_frontend/features/product/data/models/product_price_model.dart';

abstract class IProductDataSource {
  Future<List<ProductModel>> getAllProducts({int page = 0, int size = 10});
  Future<List<ProductModel>> searchProducts(String query, {int page = 0, int size = 10});
  Future<List<ProductPrice>> getCheapestProducts();
  Future<List<ProductPrice>> getClosestProducts();
  Future<List<ProductPrice>> getProductPrices(int productId);
}
