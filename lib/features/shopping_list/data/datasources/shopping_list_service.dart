import 'package:dio/dio.dart';
import 'package:xepa_frontend/core/api/api_client.dart';
import 'package:xepa_frontend/features/shopping_list/data/models/shopping_list_model.dart';

class ShoppingListService {
  final ApiClient apiClient;

  ShoppingListService(this.apiClient);

  Future<List<ShoppingListModel>> getShoppingLists() async {
    try {
      final response = await apiClient.dio.get('/shopping-lists');
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => ShoppingListModel.fromJson(json)).toList();
      }
      return [];
    } on DioException {
      return [];
    }
  }

  Future<ShoppingListModel?> getShoppingListById(int id) async {
    try {
      final response = await apiClient.dio.get('/shopping-lists/$id');
      if (response.statusCode == 200) {
        return ShoppingListModel.fromJson(response.data);
      }
      return null;
    } on DioException {
      return null;
    }
  }

  Future<ShoppingListModel?> createShoppingList(String name) async {
    try {
      final response = await apiClient.dio.post(
        '/shopping-lists',
        data: {
          'name': name,
          'color': '#2196F3',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ShoppingListModel.fromJson(response.data);
      }
      return null;
    } on DioException {
      return null;
    }
  }

  Future<bool> deleteShoppingList(int id) async {
    try {
      final response = await apiClient.dio.delete('/shopping-lists/$id');
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException {
      return false;
    }
  }

  Future<ShoppingListItemModel?> addItemToList(int listId, int productId, double quantity, String notes) async {
    try {
      final response = await apiClient.dio.post(
        '/shopping-lists/$listId/items',
        data: {
          'productId': productId,
          'quantity': quantity,
          'notes': notes,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ShoppingListItemModel.fromJson(response.data);
      }
      return null;
    } on DioException {
      return null;
    }
  }

  Future<bool> removeItemFromList(int listId, int itemId) async {
    try {
      final response = await apiClient.dio.delete('/shopping-lists/$listId/items/$itemId');
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException {
      return false;
    }
  }

  Future<ShoppingListModel?> updateShoppingList(int id, Map<String, dynamic> updates) async {
    try {
      final response = await apiClient.dio.patch('/shopping-lists/$id', data: updates);
      if (response.statusCode == 200) {
        return ShoppingListModel.fromJson(response.data);
      }
      return null;
    } on DioException {
      return null;
    }
  }
}
