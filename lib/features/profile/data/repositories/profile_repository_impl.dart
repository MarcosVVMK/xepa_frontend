import 'dart:developer' as dev;
import 'package:dartz/dartz.dart';
import 'package:xepa_frontend/core/errors/failure.dart';
import 'package:xepa_frontend/core/utils/typedef.dart';
import 'package:xepa_frontend/features/profile/data/datasources/profile_remote_ds.dart';
import 'package:xepa_frontend/features/profile/domain/entities/address.dart';
import 'package:xepa_frontend/features/profile/domain/entities/profile.dart';
import 'package:xepa_frontend/features/profile/domain/repositories/i_profile_repository.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  ResultFuture<Profile> getProfile() async {
    try {
      final result = await remoteDataSource.getProfile();
      return Right(result);
    } catch (e, stackTrace) {
      dev.log('Erro ao obter perfil', error: e, stackTrace: stackTrace);
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<Profile> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String cpf,
  }) async {
    try {
      final result = await remoteDataSource.updateProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        cpf: cpf,
      );
      return Right(result);
    } catch (e, stackTrace) {
      dev.log('Erro ao atualizar perfil', error: e, stackTrace: stackTrace);
      return Left(ServerFailure(message: e.toString()));
    }
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
    double? latitude,
    double? longitude,
  }) async {
    try {
      final result = await remoteDataSource.saveAddress(
        zipCode: zipCode,
        street: street,
        number: number,
        complement: complement,
        neighborhood: neighborhood,
        city: city,
        state: state,
        uf: uf,
        latitude: latitude,
        longitude: longitude,
      );
      return Right(result);
    } catch (e, stackTrace) {
      dev.log('Erro ao salvar endereço', error: e, stackTrace: stackTrace);
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<Address> getAddress() async {
    try {
      final result = await remoteDataSource.getAddress();
      return Right(result);
    } catch (e, stackTrace) {
      dev.log('Erro ao obter endereço', error: e, stackTrace: stackTrace);
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid deleteAccount() async {
    try {
      await remoteDataSource.deleteAccount();
      return const Right(null);
    } catch (e, stackTrace) {
      dev.log('Erro ao excluir conta', error: e, stackTrace: stackTrace);
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } catch (e, stackTrace) {
      dev.log('Erro ao alterar senha', error: e, stackTrace: stackTrace);
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
