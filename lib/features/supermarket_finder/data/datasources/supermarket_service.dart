import 'package:dio/dio.dart';
import 'package:xepa_frontend/core/api/api_client.dart';
import 'package:xepa_frontend/features/supermarket_finder/data/models/supermarket_model.dart';

class SupermarketService {
  final ApiClient apiClient;

  SupermarketService(this.apiClient);

  Future<List<SupermarketModel>> getAllSupermarkets() async {
    try {
      final response = await apiClient.dio.get('/supermarket');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => SupermarketModel.fromJson(json)).toList();
      }
      return [];
    } on DioException {
      return [];
    }
  }

  Future<List<SupermarketModel>> getClosestSupermarkets() async {
    try {
      final response = await apiClient.dio.get('/supermarket/closest');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => SupermarketModel.fromJson(json)).toList();
      }
      return [];
    } on DioException {
      return [];
    }
  }

  Future<List<SupermarketModel>> searchSupermarkets(String query) async {
    try {
      final response = await apiClient.dio.get(
        '/supermarket/search?name=$query',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => SupermarketModel.fromJson(json)).toList();
      }
      return [];
    } on DioException {
      return [];
    }
  }
}
