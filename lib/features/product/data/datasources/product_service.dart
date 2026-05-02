import 'package:dio/dio.dart';
import 'package:xepa_frontend/core/api/api_client.dart';

class ProductService {
  final ApiClient apiClient;

  ProductService(this.apiClient);

  Future<List<dynamic>> getAllProducts({int page = 0, int size = 10}) async {
    try {
      final response = await apiClient.dio.get('/product?page=$page&size=$size');
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
      return [];
    } on DioException {
      return [];
    }
  }

  Future<List<dynamic>> getCheapestProducts() async {
    try {
      final response = await apiClient.dio.get('/product/cheapest');
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
      return [];
    } on DioException {
      return [];
    }
  }

  Future<List<dynamic>> getClosestProducts() async {
    try {
      final response = await apiClient.dio.get('/product/closest');
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
      return [];
    } on DioException {
      return [];
    }
  }

  Future<List<dynamic>> searchProducts(String query) async {
    try {
      final response = await apiClient.dio.get('/product/search', queryParameters: {'name': query});
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
      return [];
    } on DioException {
      return [];
    }
  }
}
