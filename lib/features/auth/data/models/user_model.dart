import 'package:xepa_frontend/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.cpf,
    required super.phone,
    super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['first_name'] ?? json['firstName'] ?? '',
      lastName: json['last_name'] ?? json['lastName'] ?? '',
      email: json['email'] ?? '',
      cpf: json['cpf'] ?? '',
      phone: json['phone'] ?? '',
      createdAt: json['created_at'] != null || json['createdAt'] != null
          ? DateTime.parse(json['created_at'] ?? json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'cpf': cpf,
      'phone': phone,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
