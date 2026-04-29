import 'package:xepa_frontend/core/utils/typedef.dart';
import 'package:xepa_frontend/features/auth/domain/entities/user.dart';

abstract class IAuthRepository {
  ResultFuture<User> login({
    required String email,
    required String password,
  });
  ResultFuture<User> register({
    required String firstName,
    required String lastName,
    required String cpf,
    required String email,
    required String password,
    required String phone,
  });
  
  ResultVoid logout();
  
  ResultFuture<User?> getCurrentUser();
}
