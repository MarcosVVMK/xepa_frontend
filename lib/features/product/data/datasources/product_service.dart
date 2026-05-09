import 'dart:async';
import 'package:dio/dio.dart';
import 'package:xepa_frontend/core/api/api_client.dart';
import 'package:xepa_frontend/core/errors/dio_error_handler.dart';
import 'package:xepa_frontend/features/product/data/datasources/i_product_datasource.dart';
import 'package:xepa_frontend/features/product/data/models/product_model.dart';
import 'package:xepa_frontend/features/product/data/models/product_price_model.dart';

class ProductRemoteDataSource implements IProductDataSource {
  final ApiClient _apiClient;

  ProductRemoteDataSource(this._apiClient);

  @override
  Future<List<ProductModel>> getAllProducts({int page = 0, int size = 10}) async {
    try {
      final response = await _apiClient.dio.get(
        'product',
        queryParameters: {'page': page, 'size': size},
      );
      final List<dynamic> data = response.data as List;
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.extractMessage(e));
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(
    String query, {
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        'product/search',
        queryParameters: {'name': query, 'page': page, 'size': size},
      );
      final List<dynamic> data = response.data as List;
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.extractMessage(e));
    }
  }

  @override
  Future<List<ProductPrice>> getCheapestProducts() async {
    try {
      final response = await _apiClient.dio.get('product/cheapest');
      final List<dynamic> data = response.data as List;
      return data.map((json) => ProductPrice.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.extractMessage(e));
    }
  }

  @override
  Future<List<ProductPrice>> getClosestProducts() async {
    try {
      final response = await _apiClient.dio.get('product/closest');
      final List<dynamic> data = response.data as List;
      return data.map((json) => ProductPrice.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.extractMessage(e));
    }
  }

  @override
  Future<List<ProductPrice>> getProductPrices(int productId) async {
    try {
      final response = await _apiClient.dio.get('product/$productId/prices');
      final List<dynamic> data = response.data as List;
      return data.map((json) => ProductPrice.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.extractMessage(e));
    }
  }
}
