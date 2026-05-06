import 'package:xepa_frontend/features/product/domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    super.id,
    required super.name,
    super.category,
    super.unitMeasure,
    super.barcode,
    super.description,
    super.brand,
    super.active,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'] ?? '',
      category: json['productCategory'] ?? json['category'],
      unitMeasure: json['unitMeasure'],
      barcode: json['barcode'],
      description: json['description'],
      brand: json['brand'],
      active: json['active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'productCategory': category,
      'unitMeasure': unitMeasure,
      'barcode': barcode,
      'description': description,
      'brand': brand,
      'active': active,
    };
  }
}
