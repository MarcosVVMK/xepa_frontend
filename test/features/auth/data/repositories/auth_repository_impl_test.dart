import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xepa_frontend/core/errors/failure.dart';
import 'package:xepa_frontend/features/auth/data/datasources/auth_remote_ds.dart';
import 'package:xepa_frontend/features/auth/data/models/user_model.dart';
import 'package:xepa_frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:xepa_frontend/core/auth/token_storage.dart';class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  Map<String, dynamic>? resultToReturn;
  Exception? exceptionToThrow;

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return resultToReturn!;
  }

  @override
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String cpf,
    required String email,
    required String password,
    required String phone,
  }) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return resultToReturn!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockTokenStorage implements TokenStorage {
  String? storedToken;
  String? storedUser;

  @override
  Future<void> saveToken(String token) async {
    storedToken = token;
  }

  @override
  Future<String?> getToken() async => storedToken;

  @override
  Future<void> deleteToken() async {
    storedToken = null;
  }

  @override
  Future<void> saveUser(String userJson) async {
    storedUser = userJson;
  }

  @override
  Future<String?> getUser() async => storedUser;

  @override
  Future<void> deleteUser() async {
    storedUser = null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockDataSource;
  late MockTokenStorage mockTokenStorage;

  const tUser = UserModel(
    id: 1,
    firstName: 'João',
    lastName: 'Silva',
    email: 'joao@email.com',
    cpf: '12345678900',
    phone: '31999999999',
  );

  setUp(() {
    mockDataSource = MockAuthRemoteDataSource();
    mockTokenStorage = MockTokenStorage();
    mockDataSource.resultToReturn = {
      'token': 'test-jwt-token',
      'user': tUser,
    };
    repository = AuthRepositoryImpl(
      mockDataSource,
      tokenStorage: mockTokenStorage,
    );
  });

  group('login', () {
    test('should return User and save token on success', () async {
      final result = await repository.login(
        email: 'joao@email.com',
        password: 'pass123',
      );

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (user) {
          expect(user.firstName, 'João');
          expect(user.email, 'joao@email.com');
        },
      );
      expect(mockTokenStorage.storedToken, 'test-jwt-token');
      expect(mockTokenStorage.storedUser, isNotNull);
    });

    test('should handle null token gracefully', () async {
      mockDataSource.resultToReturn = {
        'token': null,
        'user': tUser,
      };

      final result = await repository.login(
        email: 'joao@email.com',
        password: 'pass123',
      );

      expect(result.isRight(), true);
      expect(mockTokenStorage.storedToken, isNull);
    });

    test('should return ServerFailure on exception', () async {
      mockDataSource.exceptionToThrow = Exception('Network error');

      final result = await repository.login(
        email: 'joao@email.com',
        password: 'pass123',
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Network error'));
        },
        (_) => fail('Should not succeed'),
      );
    });
  });

  group('register', () {
    test('should return User and save token on success', () async {
      final result = await repository.register(
        firstName: 'João',
        lastName: 'Silva',
        cpf: '12345678900',
        email: 'joao@email.com',
        password: 'pass123',
        phone: '31999999999',
      );

      expect(result.isRight(), true);
      expect(mockTokenStorage.storedToken, 'test-jwt-token');
      expect(mockTokenStorage.storedUser, isNotNull);
    });

    test('should return ServerFailure on exception', () async {
      mockDataSource.exceptionToThrow = Exception('Email already exists');

      final result = await repository.register(
        firstName: 'João',
        lastName: 'Silva',
        cpf: '12345678900',
        email: 'joao@email.com',
        password: 'pass123',
        phone: '31999999999',
      );

      expect(result.isLeft(), true);
    });
  group('getCurrentUser', () {
    test('should return user from storage', () async {
      mockTokenStorage.storedUser =
          '{"id":1,"first_name":"João","last_name":"Silva","email":"joao@email.com","cpf":"12345678900","phone":"31999999999"}';

      final result = await repository.getCurrentUser();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (user) {
          expect(user, isNotNull);
          expect(user!.firstName, 'João');
        },
      );
    });

    test('should return null when no user stored', () async {
      final result = await repository.getCurrentUser();

      result.fold(
        (_) => fail('Should not fail'),
        (user) => expect(user, isNull),
      );
    });
  group('logout', () {
    test('should delete token and user', () async {
      mockTokenStorage.storedToken = 'some-token';
      mockTokenStorage.storedUser = '{}';

      final result = await repository.logout();

      expect(result, const Right(null));
      expect(mockTokenStorage.storedToken, isNull);
      expect(mockTokenStorage.storedUser, isNull);
    });
  });
}
