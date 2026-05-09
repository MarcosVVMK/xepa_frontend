import 'package:xepa_frontend/core/utils/typedef.dart';
import 'package:xepa_frontend/features/profile/domain/entities/profile.dart';
import 'package:xepa_frontend/features/profile/domain/repositories/i_profile_repository.dart';

class UpdateProfileUseCase {
  final IProfileRepository _repository;

  UpdateProfileUseCase(this._repository);

  ResultFuture<Profile> call({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String cpf,
  }) async {
    return await _repository.updateProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      cpf: cpf,
    );
  }
}
