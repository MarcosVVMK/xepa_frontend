import 'package:equatable/equatable.dart';
import 'package:xepa_frontend/features/profile/domain/entities/address.dart';

class Supermarket extends Equatable {
  final int? id;
  final String name;
  final String? email;
  final String? cnpj;
  final String? phone;
  final bool active;
  final String? openingHours;
  final String? closingHours;
  final Address? address;
  final double? distance;

  const Supermarket({
    this.id,
    required this.name,
    this.email,
    this.cnpj,
    this.phone,
    this.active = true,
    this.openingHours,
    this.closingHours,
    this.address,
    this.distance,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        cnpj,
        phone,
        active,
        openingHours,
        closingHours,
        address,
        distance,
      ];
}
