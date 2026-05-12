import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xepa_frontend/core/errors/failure.dart';
import 'package:xepa_frontend/core/utils/typedef.dart';
import 'package:xepa_frontend/features/auth/data/models/user_model.dart';
import 'package:xepa_frontend/features/auth/domain/entities/user.dart';
import 'package:xepa_frontend/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:xepa_frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:xepa_frontend/features/auth/domain/usecases/register_usecase.dart';

class MockAuthRepository implements IAuthRepository {
  User? userToReturn;
  Failure? failureToReturn;

  Map<String, dynamic>? lastLoginParams;
  Map<String, dynamic>? lastRegisterParams;
  bool logoutCalled = false;

  @override
  ResultFuture<User> login({
    required String email,
    required String password,
  }) async {
    lastLoginParams = {'email': email, 'password': password};
    if (failureToReturn != null) return Left(failureToReturn!);
    return Right(userToReturn!);
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
    lastRegisterParams = {
      'firstName': firstName,
      'lastName': lastName,
      'cpf': cpf,
      'email': email,
      'password': password,
      'phone': phone,
    };
    if (failureToReturn != null) return Left(failureToReturn!);
    return Right(userToReturn!);
  }

  @override
  ResultVoid logout() async {
    logoutCalled = true;
    if (failureToReturn != null) return Left(failureToReturn!);
    return const Right(null);
  }

  @override
  ResultFuture<User?> getCurrentUser() async {
    if (failureToReturn != null) return Left(failureToReturn!);
    return Right(userToReturn);
  }
}

void main() {
  late MockAuthRepository mockRepository;

  const tUser = UserModel(
    id: 1,
    firstName: 'João',
    lastName: 'Silva',
    email: 'joao@email.com',
    cpf: '12345678900',
    phone: '31999999999',
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    mockRepository.userToReturn = tUser;
  });

  group('LoginUseCase', () {
    test('should call repository login with correct parameters', () async {
      final useCase = LoginUseCase(mockRepository);

      await useCase(email: 'joao@email.com', password: 'pass123');

      expect(mockRepository.lastLoginParams, {
        'email': 'joao@email.com',
        'password': 'pass123',
      });
    });

    test('should return User on successful login', () async {
      final useCase = LoginUseCase(mockRepository);

      final result = await useCase(email: 'joao@email.com', password: 'pass123');

      expect(result, const Right(tUser));
    });

    test('should return failure when login fails', () async {
      mockRepository.failureToReturn =
          const ServerFailure(message: 'Invalid credentials');
      final useCase = LoginUseCase(mockRepository);

      final result = await useCase(email: 'wrong@email.com', password: 'wrong');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, 'Invalid credentials'),
        (_) => fail('Should not return right'),
      );
    });
  });

  group('RegisterUseCase', () {
    test('should call repository register with all parameters', () async {
      final useCase = RegisterUseCase(mockRepository);

      await useCase(
        firstName: 'João',
        lastName: 'Silva',
        cpf: '12345678900',
        email: 'joao@email.com',
        password: 'pass123',
        phone: '31999999999',
      );

      expect(mockRepository.lastRegisterParams?['firstName'], 'João');
      expect(mockRepository.lastRegisterParams?['lastName'], 'Silva');
      expect(mockRepository.lastRegisterParams?['cpf'], '12345678900');
      expect(mockRepository.lastRegisterParams?['email'], 'joao@email.com');
      expect(mockRepository.lastRegisterParams?['password'], 'pass123');
      expect(mockRepository.lastRegisterParams?['phone'], '31999999999');
    });

    test('should return User on successful registration', () async {
      final useCase = RegisterUseCase(mockRepository);

      final result = await useCase(
        firstName: 'João',
        lastName: 'Silva',
        cpf: '12345678900',
        email: 'joao@email.com',
        password: 'pass123',
        phone: '31999999999',
      );

      expect(result, const Right(tUser));
    });

    test('should return failure when registration fails', () async {
      mockRepository.failureToReturn =
          const ServerFailure(message: 'Email already exists');
      final useCase = RegisterUseCase(mockRepository);

      final result = await useCase(
        firstName: 'João',
        lastName: 'Silva',
        cpf: '12345678900',
        email: 'joao@email.com',
        password: 'pass123',
        phone: '31999999999',
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, 'Email already exists'),
        (_) => fail('Should not return right'),
      );
    });
  });

  group('getCurrentUser (via repository)', () {
    test('should return user when stored', () async {
      final result = await mockRepository.getCurrentUser();
      expect(result, Right(tUser));
    });

    test('should return null when no user stored', () async {
      mockRepository.userToReturn = null;
      final result = await mockRepository.getCurrentUser();
      result.fold(
        (_) => fail('Should not fail'),
        (user) => expect(user, isNull),
      );
    });

    test('should return failure on error', () async {
      mockRepository.failureToReturn =
          const CacheFailure(message: 'Cache error');
      final result = await mockRepository.getCurrentUser();
      expect(result.isLeft(), true);
    });
  });

  group('logout (via repository)', () {
    test('should call logout successfully', () async {
      final result = await mockRepository.logout();
      expect(result, const Right(null));
      expect(mockRepository.logoutCalled, true);
    });

    test('should return failure on logout error', () async {
      mockRepository.failureToReturn =
          const CacheFailure(message: 'Logout error');
      final result = await mockRepository.logout();
      expect(result.isLeft(), true);
    });
  });
}
