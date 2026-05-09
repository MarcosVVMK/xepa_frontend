import 'package:xepa_frontend/features/product/domain/entities/product.dart';
import 'package:xepa_frontend/features/product/data/models/product_price_model.dart';

abstract class IProductRepository {
  Future<List<Product>> getAllProducts({int page = 0, int size = 10});
  Future<List<Product>> searchProducts(String query, {int page = 0, int size = 10});
  Future<List<ProductPrice>> getCheapestProducts();
  Future<List<ProductPrice>> getClosestProducts();
  Future<List<ProductPrice>> getProductPrices(int productId);
}
