import 'package:xepa_frontend/features/profile/domain/entities/address.dart';

class AddressModel extends Address {
  const AddressModel({
    super.id,
    required super.zipCode,
    required super.street,
    required super.number,
    super.complement,
    required super.neighborhood,
    required super.city,
    required super.state,
    required super.uf,
    super.createdAt,
    super.updatedAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      zipCode: json['zip_code'] ?? json['zipCode'] ?? '',
      street: json['street'] ?? '',
      number: json['number'] ?? '',
      complement: json['complement'] ?? '',
      neighborhood: json['neighborhood'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      uf: json['uf'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'zip_code': zipCode,
      'street': street,
      'number': number,
      'complement': complement,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'uf': uf,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
