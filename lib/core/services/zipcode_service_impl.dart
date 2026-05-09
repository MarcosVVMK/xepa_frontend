import 'package:dartz/dartz.dart';
import 'package:xepa_frontend/core/api/api_client.dart';
import 'package:xepa_frontend/core/errors/failure.dart';
import 'package:xepa_frontend/core/utils/typedef.dart';
import 'package:xepa_frontend/core/services/i_zipcode_service.dart';

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

      final response = await _apiClient.dio.get('https://cep.awesomeapi.com.br/json/$cleanZipCode');

      if (response.data != null) {
        if (response.data['status'] == 404 || response.data['code'] == 'not_found') {
          return Left(ServerFailure(message: 'ZipCode not found.'));
        }

        return Right({
          'street': response.data['address'] ?? '',
          'complement': '',
          'neighborhood': response.data['district'] ?? '',
          'city': response.data['city'] ?? '',
          'uf': response.data['state'] ?? '',
        });
      }

      return Left(ServerFailure(message: 'Error fetching ZipCode data.'));
    } catch (e) {
      return Left(ServerFailure(message: 'ZipCode request failed: $e'));
    }
  }
}
