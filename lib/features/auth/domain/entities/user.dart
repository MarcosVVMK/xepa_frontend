import 'package:equatable/equatable.dart';
import 'package:xepa_frontend/features/profile/domain/entities/address.dart';

class User extends Equatable {
  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String cpf;
  final String phone;
  final DateTime? createdAt;
  final Address? address;

  const User({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.cpf,
    required this.phone,
    this.createdAt,
    this.address,
  });

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        cpf,
        phone,
        createdAt,
        address,
      ];
}
