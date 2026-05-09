import 'package:dio/dio.dart';
import 'package:xepa_frontend/core/api/api_client.dart';
import 'package:xepa_frontend/core/errors/dio_error_handler.dart';
import 'package:xepa_frontend/features/supermarket_finder/data/datasources/i_supermarket_datasource.dart';
import 'package:xepa_frontend/features/supermarket_finder/data/models/supermarket_model.dart';
import 'package:xepa_frontend/features/product/data/models/product_price_model.dart';

class SupermarketRemoteDataSource implements ISupermarketDataSource {
  final ApiClient _apiClient;

  SupermarketRemoteDataSource(this._apiClient);

  @override
  Future<List<SupermarketModel>> getAllSupermarkets() async {
    try {
      final response = await _apiClient.dio.get('supermarket');
      final List<dynamic> data = response.data as List;
      return data.map((json) => SupermarketModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.extractMessage(e));
    }
  }

  @override
  Future<List<SupermarketModel>> getClosestSupermarkets() async {
    try {
      final response = await _apiClient.dio.get('supermarket/closest');
      final List<dynamic> data = response.data as List;
      return data.map((json) => SupermarketModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.extractMessage(e));
    }
  }

  @override
  Future<List<SupermarketModel>> searchSupermarkets(String query) async {
    try {
      final response = await _apiClient.dio.get(
        'supermarket/search',
        queryParameters: {'name': query},
      );
      final List<dynamic> data = response.data as List;
      return data.map((json) => SupermarketModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.extractMessage(e));
    }
  }

  @override
  Future<List<ProductPrice>> getSupermarketProducts(int supermarketId) async {
    try {
      final response = await _apiClient.dio.get(
        'product/supermarket/$supermarketId',
      );
      final List<dynamic> data = response.data as List;
      return data.map((json) => ProductPrice.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.extractMessage(e));
    }
  }
}
