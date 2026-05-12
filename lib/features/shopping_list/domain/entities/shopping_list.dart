import 'package:equatable/equatable.dart';
import 'package:xepa_frontend/features/shopping_list/domain/enums/shopping_list_status.dart';
import 'package:xepa_frontend/features/shopping_list/domain/entities/shopping_list_item.dart';

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
