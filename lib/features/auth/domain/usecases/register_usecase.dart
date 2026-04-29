import 'package:xepa_frontend/core/utils/typedef.dart';
import 'package:xepa_frontend/features/auth/domain/entities/user.dart';
import 'package:xepa_frontend/features/auth/domain/repositories/i_auth_repository.dart';

class RegisterUseCase {
  final IAuthRepository _repository;

  RegisterUseCase(this._repository);

  ResultFuture<User> call({
    required String firstName,
    required String lastName,
    required String cpf,
    required String email,
    required String password,
    required String phone,
  }) async {
    return await _repository.register(
      firstName: firstName,
      lastName: lastName,
      cpf: cpf,
      email: email,
      password: password,
      phone: phone,
    );
  }
}
