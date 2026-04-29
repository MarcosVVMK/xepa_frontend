import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xepa_frontend/core/errors/failure.dart';
import 'package:xepa_frontend/features/profile/data/models/address_model.dart';
import 'package:xepa_frontend/features/profile/data/models/profile_model.dart';
import 'package:xepa_frontend/features/profile/domain/entities/address.dart';
import 'package:xepa_frontend/features/profile/domain/entities/profile.dart';
import 'package:xepa_frontend/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:xepa_frontend/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:xepa_frontend/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:xepa_frontend/features/profile/domain/usecases/save_address_usecase.dart';
import 'package:xepa_frontend/features/profile/domain/usecases/change_password_usecase.dart';
import 'package:xepa_frontend/core/utils/typedef.dart';class MockProfileRepository implements IProfileRepository {
  Profile? profileToReturn;
  Address? addressToReturn;
  Failure? failureToReturn;
  bool changePasswordCalled = false;

  // Track calls
  Map<String, dynamic>? lastUpdateProfileParams;
  Map<String, dynamic>? lastSaveAddressParams;
  Map<String, dynamic>? lastChangePasswordParams;

  @override
  ResultFuture<Profile> getProfile() async {
    if (failureToReturn != null) return Left(failureToReturn!);
    return Right(profileToReturn!);
  }

  @override
  ResultFuture<Profile> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    lastUpdateProfileParams = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
    };
    if (failureToReturn != null) return Left(failureToReturn!);
    return Right(profileToReturn!);
  }

  @override
  ResultFuture<Address> saveAddress({
    required String zipCode,
    required String street,
    required String number,
    String complement = '',
    required String neighborhood,
    required String city,
    required String state,
    required String uf,
  }) async {
    lastSaveAddressParams = {
      'zipCode': zipCode,
      'street': street,
      'number': number,
      'complement': complement,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'uf': uf,
    };
    if (failureToReturn != null) return Left(failureToReturn!);
    return Right(addressToReturn!);
  }

  @override
  ResultFuture<Address> getAddress() async {
    if (failureToReturn != null) return Left(failureToReturn!);
    return Right(addressToReturn!);
  }

  @override
  ResultVoid changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    lastChangePasswordParams = {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    };
    changePasswordCalled = true;
    if (failureToReturn != null) return Left(failureToReturn!);
    return const Right(null);
  }
}

void main() {
  late MockProfileRepository mockRepository;

  const tProfile = ProfileModel(
    id: 1,
    firstName: 'João',
    lastName: 'Silva',
    email: 'joao@email.com',
    cpf: '12345678900',
    phone: '31999999999',
  );

  const tAddress = AddressModel(
    id: 10,
    zipCode: '30130-000',
    street: 'Rua da Bahia',
    number: '1234',
    complement: 'Apt 101',
    neighborhood: 'Centro',
    city: 'Belo Horizonte',
    state: 'Minas Gerais',
    uf: 'MG',
  );

  setUp(() {
    mockRepository = MockProfileRepository();
    mockRepository.profileToReturn = tProfile;
    mockRepository.addressToReturn = tAddress;
  group('GetProfileUseCase', () {
    test('should get profile from repository', () async {
      final useCase = GetProfileUseCase(mockRepository);

      final result = await useCase();

      expect(result, const Right(tProfile));
    });

    test('should return failure when repository fails', () async {
      mockRepository.failureToReturn =
          const ServerFailure(message: 'Server error');
      final useCase = GetProfileUseCase(mockRepository);

      final result = await useCase();

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, 'Server error'),
        (_) => fail('Should not return right'),
      );
    });
  group('UpdateProfileUseCase', () {
    test('should call repository with correct parameters', () async {
      final useCase = UpdateProfileUseCase(mockRepository);

      await useCase(
        firstName: 'João',
        lastName: 'Silva',
        email: 'joao@email.com',
        phone: '31999999999',
      );

      expect(mockRepository.lastUpdateProfileParams, {
        'firstName': 'João',
        'lastName': 'Silva',
        'email': 'joao@email.com',
        'phone': '31999999999',
      });
    });

    test('should return updated profile on success', () async {
      final useCase = UpdateProfileUseCase(mockRepository);

      final result = await useCase(
        firstName: 'João',
        lastName: 'Silva',
        email: 'joao@email.com',
        phone: '31999999999',
      );

      expect(result, const Right(tProfile));
    });

    test('should return failure when update fails', () async {
      mockRepository.failureToReturn =
          const ServerFailure(message: 'Update failed');
      final useCase = UpdateProfileUseCase(mockRepository);

      final result = await useCase(
        firstName: 'João',
        lastName: 'Silva',
        email: 'joao@email.com',
        phone: '31999999999',
      );

      expect(result.isLeft(), true);
    });
  group('SaveAddressUseCase', () {
    test('should call repository with correct parameters', () async {
      final useCase = SaveAddressUseCase(mockRepository);

      await useCase(
        zipCode: '30130-000',
        street: 'Rua da Bahia',
        number: '1234',
        complement: 'Apt 101',
        neighborhood: 'Centro',
        city: 'Belo Horizonte',
        state: 'Minas Gerais',
        uf: 'MG',
      );

      expect(mockRepository.lastSaveAddressParams?['zipCode'], '30130-000');
      expect(
          mockRepository.lastSaveAddressParams?['street'], 'Rua da Bahia');
      expect(mockRepository.lastSaveAddressParams?['number'], '1234');
      expect(
          mockRepository.lastSaveAddressParams?['complement'], 'Apt 101');
      expect(
          mockRepository.lastSaveAddressParams?['neighborhood'], 'Centro');
      expect(mockRepository.lastSaveAddressParams?['city'],
          'Belo Horizonte');
      expect(mockRepository.lastSaveAddressParams?['state'],
          'Minas Gerais');
      expect(mockRepository.lastSaveAddressParams?['uf'], 'MG');
    });

    test('should return saved address on success', () async {
      final useCase = SaveAddressUseCase(mockRepository);

      final result = await useCase(
        zipCode: '30130-000',
        street: 'Rua da Bahia',
        number: '1234',
        neighborhood: 'Centro',
        city: 'Belo Horizonte',
        state: 'Minas Gerais',
        uf: 'MG',
      );

      expect(result, const Right(tAddress));
    });

    test('should return failure when save fails', () async {
      mockRepository.failureToReturn =
          const ServerFailure(message: 'Save failed');
      final useCase = SaveAddressUseCase(mockRepository);

      final result = await useCase(
        zipCode: '30130-000',
        street: 'Rua da Bahia',
        number: '1234',
        neighborhood: 'Centro',
        city: 'Belo Horizonte',
        state: 'Minas Gerais',
        uf: 'MG',
      );

      expect(result.isLeft(), true);
    });
  group('ChangePasswordUseCase', () {
    test('should call repository with correct parameters', () async {
      final useCase = ChangePasswordUseCase(mockRepository);

      await useCase(
        currentPassword: 'oldPass123',
        newPassword: 'newPass456',
      );

      expect(mockRepository.changePasswordCalled, true);
      expect(mockRepository.lastChangePasswordParams, {
        'currentPassword': 'oldPass123',
        'newPassword': 'newPass456',
      });
    });

    test('should return Right(null) on success', () async {
      final useCase = ChangePasswordUseCase(mockRepository);

      final result = await useCase(
        currentPassword: 'oldPass123',
        newPassword: 'newPass456',
      );

      expect(result, const Right(null));
    });

    test('should return failure when password change fails', () async {
      mockRepository.failureToReturn =
          const ServerFailure(message: 'Wrong password');
      final useCase = ChangePasswordUseCase(mockRepository);

      final result = await useCase(
        currentPassword: 'wrongPass',
        newPassword: 'newPass456',
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, 'Wrong password'),
        (_) => fail('Should not return right'),
      );
    });
  });
}
