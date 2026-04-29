import 'package:xepa_frontend/features/profile/data/models/address_model.dart';
import 'package:xepa_frontend/features/profile/domain/entities/profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.cpf,
    required super.phone,
    super.address,
    super.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      firstName: json['first_name'] ?? json['firstName'] ?? '',
      lastName: json['last_name'] ?? json['lastName'] ?? '',
      email: json['email'] ?? '',
      cpf: json['cpf'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] != null
          ? AddressModel.fromJson(json['address'])
          : null,
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
      'address': address != null
          ? (address as AddressModel).toJson()
          : null,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory ProfileModel.fromEntity(Profile profile) {
    return ProfileModel(
      id: profile.id,
      firstName: profile.firstName,
      lastName: profile.lastName,
      email: profile.email,
      cpf: profile.cpf,
      phone: profile.phone,
      address: profile.address,
      createdAt: profile.createdAt,
    );
  }
}
