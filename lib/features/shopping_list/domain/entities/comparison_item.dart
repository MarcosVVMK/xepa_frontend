import 'package:equatable/equatable.dart';
import 'package:xepa_frontend/features/product/domain/entities/product.dart';

class ComparisonItem extends Equatable {
  final Product product;
  final String productName;
  final String? brand;
  final String? unitMeasure;
  final double quantity;
  final double unitPrice;
  final double subtotal;
  final bool onPromotion;
  final double? originalPrice;
  final double? discountPercentage;
  final double? savedAmount;
  final DateTime? priceUpdatedAt;

  const ComparisonItem({
    required this.product,
    required this.productName,
    this.brand,
    this.unitMeasure,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.onPromotion,
    this.originalPrice,
    this.discountPercentage,
    this.savedAmount,
    this.priceUpdatedAt,
  });

  @override
  List<Object?> get props => [
        product,
        productName,
        brand,
        unitMeasure,
        quantity,
        unitPrice,
        subtotal,
        onPromotion,
        originalPrice,
        discountPercentage,
        savedAmount,
        priceUpdatedAt,
      ];
}
