import 'package:equatable/equatable.dart';
import 'package:xepa_frontend/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:xepa_frontend/features/shopping_list/domain/entities/supermarket_comparison.dart';
import 'package:xepa_frontend/features/shopping_list/domain/entities/comparison_summary.dart';

class ComparisonResult extends Equatable {
  final ShoppingList? shoppingList;
  final String shoppingListName;
  final int totalItemsInList;
  final DateTime comparisonDate;
  final int supermarketsCompared;
  final List<SupermarketComparison> comparisons;
  final SupermarketComparison? cheapest;
  final SupermarketComparison? mostComplete;
  final SupermarketComparison? bestPromotions;
  final double? maxSavings;
  final double? averagePrice;
  final ComparisonSummary? summary;

  const ComparisonResult({
    this.shoppingList,
    required this.shoppingListName,
    required this.totalItemsInList,
    required this.comparisonDate,
    required this.supermarketsCompared,
    required this.comparisons,
    this.cheapest,
    this.mostComplete,
    this.bestPromotions,
    this.maxSavings,
    this.averagePrice,
    this.summary,
  });

  @override
  List<Object?> get props => [
        shoppingList,
        shoppingListName,
        totalItemsInList,
        comparisonDate,
        supermarketsCompared,
        comparisons,
        cheapest,
        mostComplete,
        bestPromotions,
        maxSavings,
        averagePrice,
        summary,
      ];
}
