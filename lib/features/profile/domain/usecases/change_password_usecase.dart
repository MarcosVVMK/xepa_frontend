import 'package:xepa_frontend/core/utils/typedef.dart';
import 'package:xepa_frontend/features/profile/domain/repositories/i_profile_repository.dart';

class ChangePasswordUseCase {
  final IProfileRepository _repository;

  ChangePasswordUseCase(this._repository);

  ResultVoid call({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
