import 'package:xepa_frontend/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:xepa_frontend/features/shopping_list/domain/enums/shopping_list_status.dart';

class ShoppingListModel extends ShoppingList {
  const ShoppingListModel({
    super.id,
    required super.name,
    super.customerId,
    super.color,
    super.itemCount,
    super.total,
    super.status,
    super.items,
    super.createdAt,
    super.updatedAt,
  });

  factory ShoppingListModel.fromJson(Map<String, dynamic> json) {
    return ShoppingListModel(
      id: json['id'],
      name: json['name'],
      customerId: json['customerId'],
      color: json['color'],
      itemCount: json['itemCount'],
      total: (json['total'] as num?)?.toDouble(),
      status: json['shoppingListStatus'] != null
          ? ShoppingListStatus.fromString(json['shoppingListStatus'])
          : null,
      items: json['shoppingListItems'] != null
          ? (json['shoppingListItems'] as List)
              .map((i) => ShoppingListItemModel.fromJson(i))
              .toList()
          : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'customerId': customerId,
      'color': color,
      'itemCount': itemCount,
      'total': total,
      'shoppingListStatus': status?.name,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}


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
