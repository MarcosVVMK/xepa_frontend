import 'package:xepa_frontend/core/utils/typedef.dart';
import 'package:xepa_frontend/features/profile/domain/repositories/i_profile_repository.dart';

class DeleteAccountUseCase {
  final IProfileRepository _repository;

  DeleteAccountUseCase(this._repository);

  ResultVoid call() async {
    return await _repository.deleteAccount();
  }
}
