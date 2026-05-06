import 'package:dio/dio.dart';
import 'package:xepa_frontend/core/api/api_client.dart';
import 'package:xepa_frontend/features/product/data/models/product_model.dart';
import 'package:xepa_frontend/features/product/data/models/product_price_model.dart';

class ProductService {
  final ApiClient apiClient;

  ProductService(this.apiClient);

  Future<List<ProductModel>> getAllProducts({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await apiClient.dio.get(
        'product?page=$page&size=$size',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ProductModel.fromJson(json)).toList();
      }
      return [];
    } on DioException {
      return [];
    }
  }

  Future<List<ProductPrice>> getCheapestProducts() async {
    try {
      final response = await apiClient.dio.get('product/cheapest');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ProductPrice.fromJson(json)).toList();
      }
      return [];
    } on DioException {
      return [];
    }
  }

  Future<List<ProductPrice>> getClosestProducts() async {
    try {
      final response = await apiClient.dio.get('product/closest');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ProductPrice.fromJson(json)).toList();
      }
      return [];
    } on DioException {
      return [];
    }
  }

  Future<List<ProductModel>> searchProducts(
    String query, {
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await apiClient.dio.get(
        'product/search',
        queryParameters: {'name': query, 'page': page, 'size': size},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ProductModel.fromJson(json)).toList();
      }
      return [];
    } on DioException {
      return [];
    }
  }

  Future<List<ProductPrice>> getProductPrices(int productId) async {
    try {
      final response = await apiClient.dio.get('product/$productId/prices');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ProductPrice.fromJson(json)).toList();
      }
      return [];
    } on DioException {
      return [];
    }
  }
}
