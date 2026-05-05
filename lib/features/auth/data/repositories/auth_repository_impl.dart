import 'dart:developer' as dev;
import 'package:xepa_frontend/core/auth/token_storage.dart';
import 'package:xepa_frontend/core/errors/failure.dart';
import 'package:xepa_frontend/core/utils/typedef.dart';
import 'package:xepa_frontend/features/auth/data/datasources/auth_remote_ds.dart';
import 'package:xepa_frontend/features/auth/data/models/user_model.dart';
import 'package:xepa_frontend/features/auth/domain/entities/user.dart';
import 'package:xepa_frontend/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'dart:convert';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  AuthRepositoryImpl(this.remoteDataSource, {required this.tokenStorage});

  @override
  ResultFuture<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.login(email, password);
      
      final token = result['token'] as String?;
      final user = result['user'] as UserModel;

      if (token != null && token.isNotEmpty) {
        await tokenStorage.saveToken(token);
      }
      await tokenStorage.saveUser(jsonEncode(user.toJson()));

      return Right(user);
    } catch (e, stackTrace) {
      dev.log('Erro no login', error: e, stackTrace: stackTrace);
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<User> register({
    required String firstName,
    required String lastName,
    required String cpf,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final result = await remoteDataSource.register(
        firstName: firstName,
        lastName: lastName,
        cpf: cpf,
        email: email,
        password: password,
        phone: phone,
      );
      
      final token = result['token'] as String?;
      final user = result['user'] as UserModel;

      if (token != null && token.isNotEmpty) {
        await tokenStorage.saveToken(token);
      }
      await tokenStorage.saveUser(jsonEncode(user.toJson()));

      return Right(user);
    } catch (e, stackTrace) {
      dev.log('Erro no registro de usuário', error: e, stackTrace: stackTrace);
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<User?> getCurrentUser() async {
    try {
      final userJson = await tokenStorage.getUser();
      if (userJson != null) {
        final userModel = UserModel.fromJson(jsonDecode(userJson));
        return Right(userModel);
      }
      return const Right(null);
    } catch (e, stackTrace) {
      dev.log('Erro ao obter usuário atual do cache', error: e, stackTrace: stackTrace);
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid logout() async {
    try {
      await tokenStorage.deleteToken();
      await tokenStorage.deleteUser();
      return const Right(null);
    } catch (e, stackTrace) {
      dev.log('Erro ao realizar logout (limpeza de cache)', error: e, stackTrace: stackTrace);
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
