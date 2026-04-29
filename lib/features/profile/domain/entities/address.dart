import 'package:equatable/equatable.dart';

class Address extends Equatable {
  final int? id;
  final String zipCode;
  final String street;
  final String number;
  final String complement;
  final String neighborhood;
  final String city;
  final String state;
  final String uf;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Address({
    this.id,
    required this.zipCode,
    required this.street,
    required this.number,
    this.complement = '',
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.uf,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        zipCode,
        street,
        number,
        complement,
        neighborhood,
        city,
        state,
        uf,
        createdAt,
        updatedAt,
      ];
}
