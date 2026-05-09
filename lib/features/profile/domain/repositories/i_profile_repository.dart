import 'package:xepa_frontend/core/utils/typedef.dart';
import 'package:xepa_frontend/features/profile/domain/entities/address.dart';
import 'package:xepa_frontend/features/profile/domain/entities/profile.dart';

abstract class IProfileRepository {
  ResultFuture<Profile> getProfile();

  ResultFuture<Profile> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String cpf,
  });

  ResultFuture<Address> saveAddress({
    required String zipCode,
    required String street,
    required String number,
    String complement,
    required String neighborhood,
    required String city,
    required String state,
    required String uf,
    double? latitude,
    double? longitude,
  });

  ResultFuture<Address> getAddress();

  ResultVoid deleteAccount();

  ResultVoid changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
