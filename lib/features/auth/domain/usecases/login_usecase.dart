import 'package:xepa_frontend/core/utils/typedef.dart';
import 'package:xepa_frontend/features/auth/domain/entities/user.dart';
import 'package:xepa_frontend/features/auth/domain/repositories/i_auth_repository.dart';

class LoginUseCase {
  final IAuthRepository _repository;

  LoginUseCase(this._repository);

  ResultFuture<User> call({
    required String email,
    required String password,
  }) async {
    return await _repository.login(email: email, password: password);
  }
}
