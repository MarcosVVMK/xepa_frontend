import 'package:equatable/equatable.dart';
import 'package:xepa_frontend/features/product/domain/entities/product.dart';
import 'package:xepa_frontend/features/shopping_list/domain/entities/comparison_item.dart';
import 'package:xepa_frontend/features/supermarket_finder/domain/entities/supermarket.dart';

class SupermarketComparison extends Equatable {
  final Supermarket supermarket;
  final double totalValue;
  final int itemsFound;
  final int itemsNotFound;
  final int totalItems;
  final double availabilityPercentage;
  final List<ComparisonItem> foundItems;
  final List<Product> notFoundItems;
  final int promotionalItems;
  final double? potentialSavings;
  final DateTime comparisonDate;
  final double? distanceKm;

  const SupermarketComparison({
    required this.supermarket,
    required this.totalValue,
    required this.itemsFound,
    required this.itemsNotFound,
    required this.totalItems,
    required this.availabilityPercentage,
    required this.foundItems,
    required this.notFoundItems,
    required this.promotionalItems,
    this.potentialSavings,
    required this.comparisonDate,
    this.distanceKm,
  });

  bool get isComplete => itemsNotFound == 0;

  @override
  List<Object?> get props => [
        supermarket,
        totalValue,
        itemsFound,
        itemsNotFound,
        totalItems,
        availabilityPercentage,
        foundItems,
        notFoundItems,
        promotionalItems,
        potentialSavings,
        comparisonDate,
        distanceKm,
      ];
}
