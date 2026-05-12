import 'package:xepa_frontend/features/shopping_list/domain/entities/comparison_summary.dart';

class ComparisonSummaryModel extends ComparisonSummary {
  const ComparisonSummaryModel({
    required super.lowestPrice,
    required super.highestPrice,
    required super.averagePrice,
    super.medianPrice,
    required super.totalSupermarketsWithAllItems,
    required super.totalSupermarketsWithPartialItems,
    required super.totalSupermarketsWithNoItems,
    super.recommendation,
  });

  factory ComparisonSummaryModel.fromJson(Map<String, dynamic> json) {
    return ComparisonSummaryModel(
      lowestPrice: (json['lowestPrice'] as num?)?.toDouble() ?? 0.0,
      highestPrice: (json['highestPrice'] as num?)?.toDouble() ?? 0.0,
      averagePrice: (json['averagePrice'] as num?)?.toDouble() ?? 0.0,
      medianPrice: (json['medianPrice'] as num?)?.toDouble(),
      totalSupermarketsWithAllItems: json['totalSupermarketsWithAllItems'] ?? 0,
      totalSupermarketsWithPartialItems: json['totalSupermarketsWithPartialItems'] ?? 0,
      totalSupermarketsWithNoItems: json['totalSupermarketsWithNoItems'] ?? 0,
      recommendation: json['recommendation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lowestPrice': lowestPrice,
      'highestPrice': highestPrice,
      'averagePrice': averagePrice,
      'medianPrice': medianPrice,
      'totalSupermarketsWithAllItems': totalSupermarketsWithAllItems,
      'totalSupermarketsWithPartialItems': totalSupermarketsWithPartialItems,
      'totalSupermarketsWithNoItems': totalSupermarketsWithNoItems,
      'recommendation': recommendation,
    };
  }
}
