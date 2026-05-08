import 'package:xepa_frontend/core/api/api_client.dart';
import 'package:xepa_frontend/features/auth/data/models/auth_response_model.dart';
import 'package:dio/dio.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource(this.apiClient);

  Future<AuthResponseModel> login(String email, String password) async {
    try {
      print('🔑 Iniciando processo de login para: $email');
      final response = await apiClient.dio.post(
        'login',
        data: {'email': email, 'password': password},
      );

      print('🔑 Login bem sucedido!');
      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      print('DioException no login: $e');
      final message = _extractErrorMessage(e);
      throw Exception(message);
    }
  }

  Future<AuthResponseModel> register({
    required String firstName,
    required String lastName,
    required String cpf,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final response = await apiClient.dio.post(
        'register',
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'cpf': cpf,
          'email': email,
          'password': password,
          'phone': phone,
        },
      );

      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      print('DioException no registro: $e');
      final message = _extractErrorMessage(e);
      throw Exception(message);
    }
  }

  Future<bool> verifyToken() async {
    try {
      final response = await apiClient.dio.get('customer/me');
      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao verificar token: $e');
      return false;
    }
  }

  String _extractErrorMessage(DioException e) {
    if (e.response?.data != null) {
      final data = e.response?.data;
      if (data is Map && data['detail'] != null) {
        if (data['detail'] is String) {
          return data['detail'];
        } else if (data['detail'] is List) {
          final List errors = data['detail'];
          if (errors.isNotEmpty && errors[0] is String) {
            return errors[0];
          }
        }
      }
    }
    return e.message ?? 'Unknown error occurred';
  }
}
