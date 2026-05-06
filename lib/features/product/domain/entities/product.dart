import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int? id;
  final String name;
  final String? category;
  final String? unitMeasure;
  final String? barcode;
  final String? description;
  final String? brand;
  final bool active;

  const Product({
    this.id,
    required this.name,
    this.category,
    this.unitMeasure,
    this.barcode,
    this.description,
    this.brand,
    this.active = true,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        unitMeasure,
        barcode,
        description,
        brand,
        active,
      ];
}
