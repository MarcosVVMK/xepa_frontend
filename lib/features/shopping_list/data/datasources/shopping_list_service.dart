import 'package:dio/dio.dart';
import 'package:xepa_frontend/core/api/api_client.dart';
import 'package:xepa_frontend/core/errors/dio_error_handler.dart';
import 'package:xepa_frontend/features/shopping_list/data/datasources/i_shopping_list_datasource.dart';
import 'package:xepa_frontend/features/shopping_list/data/models/shopping_list_model.dart';

class ShoppingListRemoteDataSource implements IShoppingListDataSource {
  final ApiClient _apiClient;

  ShoppingListRemoteDataSource(this._apiClient);

  @override
  Future<List<ShoppingListModel>> getShoppingLists() async {
    try {
      final response = await _apiClient.dio.get('shopping-lists');
      final List data = response.data as List;
      return data.map((json) => ShoppingListModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.extractMessage(e));
    }
  }

  @override
  Future<ShoppingListModel> getShoppingListById(int id) async {
    try {
      final response = await _apiClient.dio.get('shopping-lists/$id');
      return ShoppingListModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.extractMessage(e));
    }
  }

  @override
  Future<ShoppingListModel> createShoppingList(String name) async {
    try {
      final response = await _apiClient.dio.post(
        'shopping-lists',
        data: {'name': name, 'color': '#2196F3'},
      );
      return ShoppingListModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.extractMessage(e));
    }
  }

  @override
  Future<bool> deleteShoppingList(int id) async {
    try {
      final response = await _apiClient.dio.delete('shopping-lists/$id');
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.extractMessage(e));
    }
  }

  @override
  Future<ShoppingListItemModel> addItemToList(
    int listId,
    int productId,
    double quantity,
    String notes,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        'shopping-lists/$listId/items',
        data: {'productId': productId, 'quantity': quantity, 'notes': notes},
      );
      return ShoppingListItemModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.extractMessage(e));
    }
  }

  @override
  Future<bool> removeItemFromList(int listId, int itemId) async {
    try {
      final response = await _apiClient.dio.delete(
        'shopping-lists/$listId/items/$itemId',
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.extractMessage(e));
    }
  }

  @override
  Future<ShoppingListModel> updateShoppingList(
    int id,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _apiClient.dio.patch(
        'shopping-lists/$id',
        data: updates,
      );
      return ShoppingListModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.extractMessage(e));
    }
  }
}
