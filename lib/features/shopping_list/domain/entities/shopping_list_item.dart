import 'package:equatable/equatable.dart';

class ShoppingListItem extends Equatable {
  final int? id;
  final int productId;
  final double quantity;
  final int? shoppingListId;
  final String? productName;
  final String? unitMeasure;
  final String? notes;
  final double? price;
  final String? imageUrl;
  final DateTime? lastPriceUpdate;
  final bool? isPriceReliable;
  final String? originSupermarket;

  const ShoppingListItem({
    this.id,
    required this.productId,
    required this.quantity,
    this.shoppingListId,
    this.productName,
    this.unitMeasure,
    this.notes,
    this.price,
    this.imageUrl,
    this.lastPriceUpdate,
    this.isPriceReliable,
    this.originSupermarket,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        quantity,
        shoppingListId,
        productName,
        unitMeasure,
        notes,
        price,
        imageUrl,
        lastPriceUpdate,
        isPriceReliable,
        originSupermarket,
      ];
}
