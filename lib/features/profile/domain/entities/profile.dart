import 'package:equatable/equatable.dart';
import 'package:xepa_frontend/features/profile/domain/entities/address.dart';

class Profile extends Equatable {
  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String cpf;
  final String phone;
  final Address? address;
  final DateTime? createdAt;

  const Profile({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.cpf,
    required this.phone,
    this.address,
    this.createdAt,
  });

  Profile copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? cpf,
    String? phone,
    Address? address,
    DateTime? createdAt,
  }) {
    return Profile(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      cpf: cpf ?? this.cpf,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        cpf,
        phone,
        address,
        createdAt,
      ];
}
