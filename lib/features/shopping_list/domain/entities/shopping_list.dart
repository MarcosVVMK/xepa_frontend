import 'package:equatable/equatable.dart';
import 'package:xepa_frontend/features/shopping_list/domain/enums/shopping_list_status.dart';


class ShoppingList extends Equatable {
  final int? id;
  final String name;
  final int? customerId;
  final String? color;
  final int? itemCount;
  final double? total;
  final ShoppingListStatus? status;
  final List<ShoppingListItem>? items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ShoppingList({
    this.id,
    required this.name,
    this.customerId,
    this.color,
    this.itemCount,
    this.total,
    this.status,
    this.items,
    this.createdAt,
    this.updatedAt,
  });


  @override
  List<Object?> get props => [
        id,
        name,
        customerId,
        color,
        itemCount,
        total,
        status,
        items,
        createdAt,
        updatedAt,
      ];
}

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
