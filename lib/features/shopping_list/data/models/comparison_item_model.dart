import 'package:xepa_frontend/features/product/data/models/product_model.dart';
import 'package:xepa_frontend/features/shopping_list/domain/entities/comparison_item.dart';

class ComparisonItemModel extends ComparisonItem {
  const ComparisonItemModel({
    required super.product,
    required super.productName,
    super.brand,
    super.unitMeasure,
    required super.quantity,
    required super.unitPrice,
    required super.subtotal,
    required super.onPromotion,
    super.originalPrice,
    super.discountPercentage,
    super.savedAmount,
    super.priceUpdatedAt,
  });

  factory ComparisonItemModel.fromJson(Map<String, dynamic> json) {
    return ComparisonItemModel(
      product: ProductModel.fromJson(json['product'] ?? {}),
      productName: json['productName'] ?? '',
      brand: json['brand'],
      unitMeasure: json['unitMeasure'],
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      onPromotion: json['onPromotion'] ?? false,
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
      savedAmount: (json['savedAmount'] as num?)?.toDouble(),
      priceUpdatedAt: json['priceUpdatedAt'] != null
          ? DateTime.parse(json['priceUpdatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': (product as ProductModel).toJson(),
      'productName': productName,
      'brand': brand,
      'unitMeasure': unitMeasure,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'subtotal': subtotal,
      'onPromotion': onPromotion,
      'originalPrice': originalPrice,
      'discountPercentage': discountPercentage,
      'savedAmount': savedAmount,
      'priceUpdatedAt': priceUpdatedAt?.toIso8601String(),
    };
  }
}
