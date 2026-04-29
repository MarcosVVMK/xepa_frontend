import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String cpf;
  final String phone;
  final DateTime? createdAt;

  const User({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.cpf,
    required this.phone,
    this.createdAt,
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
      ];
}
