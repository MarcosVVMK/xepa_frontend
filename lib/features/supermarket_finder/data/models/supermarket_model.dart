import 'package:xepa_frontend/features/profile/data/models/address_model.dart';
import 'package:xepa_frontend/features/supermarket_finder/domain/entities/supermarket.dart';

class SupermarketModel extends Supermarket {
  const SupermarketModel({
    super.id,
    required super.name,
    super.email,
    super.cnpj,
    super.phone,
    super.active,
    super.openingHours,
    super.closingHours,
    super.address,
    super.distance,
  });

  factory SupermarketModel.fromJson(Map<String, dynamic> json) {
    return SupermarketModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'],
      cnpj: json['cnpj'],
      phone: json['phone'],
      active: json['active'] ?? true,
      openingHours: json['opening_hours'] ?? json['openingHours'],
      closingHours: json['closing_hours'] ?? json['closingHours'],
      address: json['address'] != null ? AddressModel.fromJson(json['address']) : null,
      distance: json['distance'] != null ? (json['distance'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'cnpj': cnpj,
      'phone': phone,
      'active': active,
      'opening_hours': openingHours,
      'closing_hours': closingHours,
      'address': address != null ? (address as AddressModel).toJson() : null,
      'distance': distance,
    };
  }
}
