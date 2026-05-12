import 'package:xepa_frontend/features/product/data/models/product_model.dart';
import 'package:xepa_frontend/features/shopping_list/domain/entities/supermarket_comparison.dart';
import 'package:xepa_frontend/features/shopping_list/data/models/comparison_item_model.dart';
import 'package:xepa_frontend/features/supermarket_finder/data/models/supermarket_model.dart';

class SupermarketComparisonModel extends SupermarketComparison {
  const SupermarketComparisonModel({
    required super.supermarket,
    required super.totalValue,
    required super.itemsFound,
    required super.itemsNotFound,
    required super.totalItems,
    required super.availabilityPercentage,
    required super.foundItems,
    required super.notFoundItems,
    required super.promotionalItems,
    super.potentialSavings,
    required super.comparisonDate,
    super.distanceKm,
  });

  factory SupermarketComparisonModel.fromJson(Map<String, dynamic> json) {
    return SupermarketComparisonModel(
      supermarket: SupermarketModel.fromJson(json['supermarket'] ?? {}),
      totalValue: (json['totalValue'] as num?)?.toDouble() ?? 0.0,
      itemsFound: json['itemsFound'] ?? 0,
      itemsNotFound: json['itemsNotFound'] ?? 0,
      totalItems: json['totalItems'] ?? 0,
      availabilityPercentage: (json['availabilityPercentage'] as num?)?.toDouble() ?? 0.0,
      foundItems: (json['foundItems'] as List?)
              ?.map((i) => ComparisonItemModel.fromJson(i))
              .toList() ??
          [],
      notFoundItems: (json['notFoundItems'] as List?)
              ?.map((i) => i['product'] != null ? ProductModel.fromJson(i['product']) : null)
              .whereType<ProductModel>()
              .toList() ??
          [],
      promotionalItems: json['promotionalItems'] ?? 0,
      potentialSavings: (json['potentialSavings'] as num?)?.toDouble(),
      comparisonDate: json['comparisonDate'] != null
          ? DateTime.parse(json['comparisonDate'])
          : DateTime.now(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supermarket': (supermarket as SupermarketModel).toJson(),
      'totalValue': totalValue,
      'itemsFound': itemsFound,
      'itemsNotFound': itemsNotFound,
      'totalItems': totalItems,
      'availabilityPercentage': availabilityPercentage,
      'foundItems': foundItems.map((i) => (i as ComparisonItemModel).toJson()).toList(),
      'notFoundItems': notFoundItems.map((i) => (i as ProductModel).toJson()).toList(),
      'promotionalItems': promotionalItems,
      'potentialSavings': potentialSavings,
      'comparisonDate': comparisonDate.toIso8601String(),
      'distanceKm': distanceKm,
    };
  }
}
