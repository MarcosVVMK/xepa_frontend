import 'package:xepa_frontend/features/shopping_list/domain/entities/shopping_list_item.dart';

class ShoppingListItemModel extends ShoppingListItem {
  const ShoppingListItemModel({
    super.id,
    required super.productId,
    required super.quantity,
    super.shoppingListId,
    super.productName,
    super.unitMeasure,
    super.notes,
    super.price,
    super.imageUrl,
    super.lastPriceUpdate,
    super.isPriceReliable,
    super.originSupermarket,
  });

  factory ShoppingListItemModel.fromJson(Map<String, dynamic> json) {
    return ShoppingListItemModel(
      id: json['id'],
      productId: json['productId'],
      quantity: (json['quantity'] as num).toDouble(),
      shoppingListId: json['shoppingListId'],
      productName: json['productName'],
      unitMeasure: json['unitMeasure'],
      notes: json['notes'],
      price: (json['price'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'],
      lastPriceUpdate: json['lastPriceUpdate'] != null
          ? DateTime.parse(json['lastPriceUpdate'])
          : null,
      isPriceReliable: json['isPriceReliable'],
      originSupermarket: json['originSupermarket'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'quantity': quantity,
      'shoppingListId': shoppingListId,
      'productName': productName,
      'unitMeasure': unitMeasure,
      'notes': notes,
      'price': price,
      'imageUrl': imageUrl,
      'lastPriceUpdate': lastPriceUpdate?.toIso8601String(),
      'isPriceReliable': isPriceReliable,
      'originSupermarket': originSupermarket,
    };
  }
}
