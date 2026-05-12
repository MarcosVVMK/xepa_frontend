import 'package:xepa_frontend/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:xepa_frontend/features/shopping_list/domain/enums/shopping_list_status.dart';
import 'package:xepa_frontend/features/shopping_list/data/models/shopping_list_item_model.dart';

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
      'shoppingListItems': items?.map((i) => (i as ShoppingListItemModel).toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
