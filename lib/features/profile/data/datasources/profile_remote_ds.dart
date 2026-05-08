import 'package:xepa_frontend/core/api/api_client.dart';
import 'package:xepa_frontend/features/profile/data/models/address_model.dart';
import 'package:xepa_frontend/features/profile/data/models/profile_model.dart';
import 'package:dio/dio.dart';

class ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSource(this.apiClient);

  Future<ProfileModel> getProfile() async {
    try {
      final response = await apiClient.dio.get('profile');
      return ProfileModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<ProfileModel> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    try {
      final response = await apiClient.dio.put(
        'profile',
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone': phone,
        },
      );
      return ProfileModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<AddressModel> saveAddress({
    required String zipCode,
    required String street,
    required String number,
    String complement = '',
    required String neighborhood,
    required String city,
    required String state,
    required String uf,
  }) async {
    try {
      final response = await apiClient.dio.put(
        'profile/address',
        data: {
          'zip_code': zipCode,
          'street': street,
          'number': number,
          'complement': complement,
          'neighborhood': neighborhood,
          'city': city,
          'state': state,
          'uf': uf,
        },
      );
      return AddressModel.fromJson(response.data);
    } on DioException catch (e, stackTrace) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<AddressModel> getAddress() async {
    try {
      final response = await apiClient.dio.get('profile/address');
      return AddressModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await apiClient.dio.put(
        'profile/password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
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
          if (errors.isNotEmpty && errors[0] is Map) {
            return errors[0]['msg'] ?? 'Erro de validação';
          }
        }
      }
    }
    return e.message ?? 'Erro desconhecido';
  }
}
