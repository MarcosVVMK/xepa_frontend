import 'package:xepa_frontend/features/shopping_list/data/models/shopping_list_model.dart';
import 'package:xepa_frontend/features/shopping_list/domain/entities/comparison_result.dart';
import 'package:xepa_frontend/features/shopping_list/data/models/supermarket_comparison_model.dart';
import 'package:xepa_frontend/features/shopping_list/data/models/comparison_summary_model.dart';

class ComparisonResultModel extends ComparisonResult {
  const ComparisonResultModel({
    super.shoppingList,
    required super.shoppingListName,
    required super.totalItemsInList,
    required super.comparisonDate,
    required super.supermarketsCompared,
    required super.comparisons,
    super.cheapest,
    super.mostComplete,
    super.bestPromotions,
    super.maxSavings,
    super.averagePrice,
    super.summary,
  });

  factory ComparisonResultModel.fromJson(Map<String, dynamic> json) {
    return ComparisonResultModel(
      shoppingList: json['shoppingList'] != null
          ? ShoppingListModel.fromJson(json['shoppingList'])
          : null,
      shoppingListName: json['shoppingListName'] ?? '',
      totalItemsInList: json['totalItemsInList'] ?? 0,
      comparisonDate: json['comparisonDate'] != null
          ? DateTime.parse(json['comparisonDate'])
          : DateTime.now(),
      supermarketsCompared: json['supermarketsCompared'] ?? 0,
      comparisons: (json['comparisons'] as List?)
              ?.map((c) => SupermarketComparisonModel.fromJson(c))
              .toList() ??
          [],
      cheapest: json['cheapest'] != null
          ? SupermarketComparisonModel.fromJson(json['cheapest'])
          : null,
      mostComplete: json['mostComplete'] != null
          ? SupermarketComparisonModel.fromJson(json['mostComplete'])
          : null,
      bestPromotions: json['bestPromotions'] != null
          ? SupermarketComparisonModel.fromJson(json['bestPromotions'])
          : null,
      maxSavings: (json['maxSavings'] as num?)?.toDouble(),
      averagePrice: (json['averagePrice'] as num?)?.toDouble(),
      summary: json['summary'] != null
          ? ComparisonSummaryModel.fromJson(json['summary'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shoppingList': shoppingList != null ? (shoppingList as ShoppingListModel).toJson() : null,
      'shoppingListName': shoppingListName,
      'totalItemsInList': totalItemsInList,
      'comparisonDate': comparisonDate.toIso8601String(),
      'supermarketsCompared': supermarketsCompared,
      'comparisons': comparisons.map((c) => (c as SupermarketComparisonModel).toJson()).toList(),
      'cheapest': cheapest != null ? (cheapest as SupermarketComparisonModel).toJson() : null,
      'mostComplete': mostComplete != null ? (mostComplete as SupermarketComparisonModel).toJson() : null,
      'bestPromotions': bestPromotions != null ? (bestPromotions as SupermarketComparisonModel).toJson() : null,
      'maxSavings': maxSavings,
      'averagePrice': averagePrice,
      'summary': summary != null ? (summary as ComparisonSummaryModel).toJson() : null,
    };
  }
}
