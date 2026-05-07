import 'package:equatable/equatable.dart';
import 'package:xepa_frontend/features/product/data/models/product_model.dart';
import 'package:xepa_frontend/features/supermarket_finder/data/models/supermarket_model.dart';

class ProductPrice extends Equatable {
  final ProductModel product;
  final SupermarketModel supermarket;
  final double price;
  final DateTime? priceUpdatedAt;

  const ProductPrice({
    required this.product,
    required this.supermarket,
    required this.price,
    this.priceUpdatedAt,
  });

  factory ProductPrice.fromJson(Map<String, dynamic> json) {
    return ProductPrice(
      product: ProductModel.fromJson(json['product']),
      supermarket: SupermarketModel.fromJson(json['supermarket']),
      price: (json['price'] as num).toDouble(),
      priceUpdatedAt: json['priceUpdatedAt'] != null
          ? DateTime.tryParse(json['priceUpdatedAt'])
          : null,
    );
  }

  @override
  List<Object?> get props => [product, supermarket, price, priceUpdatedAt];
}
