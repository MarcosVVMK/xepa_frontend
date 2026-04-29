import 'package:xepa_frontend/core/utils/typedef.dart';
import 'package:xepa_frontend/features/profile/domain/entities/address.dart';
import 'package:xepa_frontend/features/profile/domain/repositories/i_profile_repository.dart';

class SaveAddressUseCase {
  final IProfileRepository _repository;

  SaveAddressUseCase(this._repository);

  ResultFuture<Address> call({
    required String zipCode,
    required String street,
    required String number,
    String complement = '',
    required String neighborhood,
    required String city,
    required String state,
    required String uf,
  }) async {
    return await _repository.saveAddress(
      zipCode: zipCode,
      street: street,
      number: number,
      complement: complement,
      neighborhood: neighborhood,
      city: city,
      state: state,
      uf: uf,
    );
  }
}
