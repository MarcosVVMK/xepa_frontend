import 'package:dartz/dartz.dart';
import 'package:xepa_frontend/core/api/api_client.dart';
import 'package:xepa_frontend/core/errors/failure.dart';
import 'package:xepa_frontend/core/utils/typedef.dart';
import 'package:xepa_frontend/core/services/zipcode_service.dart';

class ZipCodeServiceImpl implements IZipCodeService {
  final ApiClient _apiClient;

  ZipCodeServiceImpl(this._apiClient);

  @override
  ResultFuture<Map<String, String>> getAddressByZipCode(String zipCode) async {
    try {
      final cleanZipCode = zipCode.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanZipCode.length != 8) {
        return Left(ServerFailure(message: 'Invalid ZipCode.'));
      }

      final response = await _apiClient.dio.get('https://viacep.com.br/ws/$cleanZipCode/json/');

      if (response.data != null) {
        if (response.data['erro'] == true) {
          return Left(ServerFailure(message: 'ZipCode not found.'));
        }

        return Right({
          'street': response.data['logradouro'] ?? '',
          'complement': response.data['complemento'] ?? '',
          'neighborhood': response.data['bairro'] ?? '',
          'city': response.data['localidade'] ?? '',
          'state': response.data['uf'] ?? '',
          'uf': response.data['uf'] ?? '',
        });
      }

      return Left(ServerFailure(message: 'Error fetching ZipCode data.'));
    } catch (e) {
      return Left(ServerFailure(message: 'ZipCode request failed: $e'));
    }
  }
}
