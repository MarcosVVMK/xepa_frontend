import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xepa_frontend/core/errors/failure.dart';
import 'package:xepa_frontend/features/profile/data/datasources/profile_remote_ds.dart';
import 'package:xepa_frontend/features/profile/data/models/address_model.dart';
import 'package:xepa_frontend/features/profile/data/models/profile_model.dart';
import 'package:xepa_frontend/features/profile/data/repositories/profile_repository_impl.dart';

class MockProfileRemoteDataSource implements ProfileRemoteDataSource {
  ProfileModel? profileToReturn;
  AddressModel? addressToReturn;
  Exception? exceptionToThrow;
  bool changePasswordCalled = false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<ProfileModel> getProfile() async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return profileToReturn!;
  }

  @override
  Future<ProfileModel> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String cpf,
  }) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return profileToReturn!;
  }

  @override
  Future<AddressModel> saveAddress({
    required String zipCode,
    required String street,
    required String number,
    String complement = '',
    required String neighborhood,
    required String city,
    required String state,
    required String uf,
    double? latitude,
    double? longitude,
  }) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return addressToReturn!;
  }

  @override
  Future<AddressModel> getAddress() async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return addressToReturn!;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    changePasswordCalled = true;
    if (exceptionToThrow != null) throw exceptionToThrow!;
  }

  @override
  Future<void> deleteAccount() async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
  }
}

void main() {
  late ProfileRepositoryImpl repository;
  late MockProfileRemoteDataSource mockDataSource;

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
    neighborhood: 'Centro',
    city: 'Belo Horizonte',
    state: 'Minas Gerais',
    uf: 'MG',
  );

  setUp(() {
    mockDataSource = MockProfileRemoteDataSource();
    mockDataSource.profileToReturn = tProfile;
    mockDataSource.addressToReturn = tAddress;
    repository = ProfileRepositoryImpl(mockDataSource);
  });

  group('getProfile', () {
    test('should return Profile when datasource succeeds', () async {
      final result = await repository.getProfile();

      expect(result, const Right(tProfile));
    });

    test('should return ServerFailure when datasource throws', () async {
      mockDataSource.exceptionToThrow = Exception('Server error');

      final result = await repository.getProfile();

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Server error'));
        },
        (_) => fail('Should not succeed'),
      );
    });
  });

  group('updateProfile', () {
    test('should return updated Profile on success', () async {
      final result = await repository.updateProfile(
        firstName: 'João',
        lastName: 'Silva',
        email: 'joao@email.com',
        phone: '31999999999',
        cpf: '12345678900',
      );

      expect(result, const Right(tProfile));
    });

    test('should return ServerFailure on error', () async {
      mockDataSource.exceptionToThrow = Exception('Network error');

      final result = await repository.updateProfile(
        firstName: 'João',
        lastName: 'Silva',
        email: 'joao@email.com',
        phone: '31999999999',
        cpf: '12345678900',
      );

      expect(result.isLeft(), true);
    });
  });

  group('saveAddress', () {
    test('should return Address on success', () async {
      final result = await repository.saveAddress(
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

    test('should return ServerFailure on error', () async {
      mockDataSource.exceptionToThrow = Exception('Bad request');

      final result = await repository.saveAddress(
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
  });

  group('getAddress', () {
    test('should return Address on success', () async {
      final result = await repository.getAddress();

      expect(result, const Right(tAddress));
    });

    test('should return ServerFailure on error', () async {
      mockDataSource.exceptionToThrow = Exception('Not found');

      final result = await repository.getAddress();

      expect(result.isLeft(), true);
    });
  });

  group('changePassword', () {
    test('should return Right(null) on success', () async {
      final result = await repository.changePassword(
        currentPassword: 'old123',
        newPassword: 'new456',
      );

      expect(result, const Right(null));
      expect(mockDataSource.changePasswordCalled, true);
    });

    test('should return ServerFailure on error', () async {
      mockDataSource.exceptionToThrow = Exception('Wrong password');

      final result = await repository.changePassword(
        currentPassword: 'wrong',
        newPassword: 'new456',
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('Wrong password')),
        (_) => fail('Should not succeed'),
      );
    });
  });

  group('deleteAccount', () {
    test('should return Right(null) on success', () async {
      final result = await repository.deleteAccount();
      expect(result, const Right(null));
    });
  });
}
