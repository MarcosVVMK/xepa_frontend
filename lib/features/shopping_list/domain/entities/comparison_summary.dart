import 'package:equatable/equatable.dart';

class ComparisonSummary extends Equatable {
  final double lowestPrice;
  final double highestPrice;
  final double averagePrice;
  final double? medianPrice;
  final int totalSupermarketsWithAllItems;
  final int totalSupermarketsWithPartialItems;
  final int totalSupermarketsWithNoItems;
  final String? recommendation;

  const ComparisonSummary({
    required this.lowestPrice,
    required this.highestPrice,
    required this.averagePrice,
    this.medianPrice,
    required this.totalSupermarketsWithAllItems,
    required this.totalSupermarketsWithPartialItems,
    required this.totalSupermarketsWithNoItems,
    this.recommendation,
  });

  @override
  List<Object?> get props => [
        lowestPrice,
        highestPrice,
        averagePrice,
        medianPrice,
        totalSupermarketsWithAllItems,
        totalSupermarketsWithPartialItems,
        totalSupermarketsWithNoItems,
        recommendation,
      ];
}
