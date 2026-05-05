import 'package:dio/dio.dart';
import 'package:xepa_frontend/core/api/api_client.dart';

class SupermarketService {
  final ApiClient apiClient;

  SupermarketService(this.apiClient);

  Future<List<dynamic>> getAllSupermarkets() async {
    try {
      final response = await apiClient.dio.get('/supermarket');
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
      return [];
    } on DioException {
      return [];
    }
  }

  Future<List<dynamic>> getClosestSupermarkets() async {
    try {
      final response = await apiClient.dio.get('/supermarket/closest');
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
      return [];
    } on DioException {
      return [];
    }
  }
}
