import 'package:xepa_frontend/core/utils/typedef.dart';
import 'package:xepa_frontend/features/profile/domain/entities/profile.dart';
import 'package:xepa_frontend/features/profile/domain/repositories/i_profile_repository.dart';

class GetProfileUseCase {
  final IProfileRepository _repository;

  GetProfileUseCase(this._repository);

  ResultFuture<Profile> call() async {
    return await _repository.getProfile();
  }
}
