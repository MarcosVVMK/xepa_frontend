import 'package:xepa_frontend/core/utils/typedef.dart';

abstract class IZipCodeService {
  ResultFuture<Map<String, String>> getAddressByZipCode(String zipCode);
}
