import 'package:xepa_frontend/core/utils/typedef.dart';

abstract class IGeocodingService {
  ResultFuture<Map<String, double>> getCoordinatesFromAddress(String address);
}
