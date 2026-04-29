import 'package:dartz/dartz.dart';
import 'package:geocoding/geocoding.dart';
import 'package:xepa_frontend/core/errors/failure.dart';
import 'package:xepa_frontend/core/utils/typedef.dart';
import 'package:xepa_frontend/core/services/geocoding_service.dart';

class GeocodingServiceImpl implements IGeocodingService {
  @override
  ResultFuture<Map<String, double>> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return Right({
          'latitude': locations.first.latitude,
          'longitude': locations.first.longitude,
        });
      }
      return Left(ServerFailure(message: 'Nenhuma coordenada encontrada para o endereço.'));
    } catch (e) {
      return Left(ServerFailure(message: 'Erro na geocodificação: $e'));
    }
  }
}
