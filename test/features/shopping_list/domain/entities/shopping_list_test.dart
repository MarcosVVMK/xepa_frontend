import 'package:flutter_test/flutter_test.dart';
import 'package:xepa_frontend/core/errors/failure.dart';

class ShoppingList {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<ShoppingItem> items;

  ShoppingList({
    required this.id,
    required this.name,
    required this.createdAt,
    this.items = const [],
  });

  int get totalItems => items.length;

  double get totalPrice =>
      items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  ShoppingList addItem(ShoppingItem item) {
    return ShoppingList(
      id: id,
      name: name,
      createdAt: createdAt,
      items: [...items, item],
    );
  }

  ShoppingList removeItem(String itemId) {
    return ShoppingList(
      id: id,
      name: name,
      createdAt: createdAt,
      items: items.where((i) => i.id != itemId).toList(),
    );
  }

  ShoppingList updateItemQuantity(String itemId, int quantity) {
    return ShoppingList(
      id: id,
      name: name,
      createdAt: createdAt,
      items: items.map((i) {
        if (i.id == itemId) {
          return ShoppingItem(
            id: i.id,
            name: i.name,
            price: i.price,
            quantity: quantity,
          );
        }
        return i;
      }).toList(),
    );
  }
}

class ShoppingItem {
  final String id;
  final String name;
  final double price;
  final int quantity;

  const ShoppingItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
  });
}

void main() {
  group('ShoppingList', () {
    late ShoppingList tList;

    setUp(() {
      tList = ShoppingList(
        id: '1',
        name: 'Compras da Semana',
        createdAt: DateTime(2026, 4, 20),
        items: const [
          ShoppingItem(id: 'a', name: 'Arroz', price: 8.90, quantity: 2),
          ShoppingItem(id: 'b', name: 'Feijão', price: 7.50, quantity: 1),
        ],
      );
    });

    test('should calculate totalItems correctly', () {
      expect(tList.totalItems, 2);
    });

    test('should calculate totalPrice correctly', () {
      // (8.90 * 2) + (7.50 * 1) = 25.30
      expect(tList.totalPrice, closeTo(25.30, 0.01));
    });

    test('should return 0 totalPrice for empty list', () {
      final emptyList = ShoppingList(
        id: '2',
        name: 'Vazia',
        createdAt: DateTime.now(),
      );
      expect(emptyList.totalPrice, 0.0);
      expect(emptyList.totalItems, 0);
    });

    test('should add item immutably', () {
      const newItem =
          ShoppingItem(id: 'c', name: 'Leite', price: 5.50);

      final updatedList = tList.addItem(newItem);

      expect(updatedList.totalItems, 3);
      expect(tList.totalItems, 2); // original unchanged
      expect(updatedList.items.last.name, 'Leite');
    });

    test('should remove item immutably', () {
      final updatedList = tList.removeItem('a');

      expect(updatedList.totalItems, 1);
      expect(tList.totalItems, 2); // original unchanged
      expect(updatedList.items.first.name, 'Feijão');
    });

    test('should handle removing non-existent item', () {
      final updatedList = tList.removeItem('non-existent');
      expect(updatedList.totalItems, 2);
    });

    test('should update item quantity immutably', () {
      final updatedList = tList.updateItemQuantity('a', 5);

      expect(updatedList.items.first.quantity, 5);
      expect(tList.items.first.quantity, 2); // original unchanged
      // New total: (8.90 * 5) + (7.50 * 1) = 52.00
      expect(updatedList.totalPrice, closeTo(52.00, 0.01));
    });

    test('should preserve list metadata on modifications', () {
      final updatedList = tList.addItem(
        const ShoppingItem(id: 'd', name: 'Café', price: 12.00),
      );

      expect(updatedList.id, tList.id);
      expect(updatedList.name, tList.name);
      expect(updatedList.createdAt, tList.createdAt);
    });
  });

  group('ShoppingItem', () {
    test('should have default quantity of 1', () {
      const item = ShoppingItem(id: '1', name: 'Test', price: 10.0);
      expect(item.quantity, 1);
    });

    test('should store all properties correctly', () {
      const item = ShoppingItem(
        id: 'x',
        name: 'Banana',
        price: 3.99,
        quantity: 4,
      );
      expect(item.id, 'x');
      expect(item.name, 'Banana');
      expect(item.price, 3.99);
      expect(item.quantity, 4);
    });
  });

  group('Failure types for shopping list', () {
    test('ServerFailure should carry message', () {
      const failure = ServerFailure(message: 'Could not load lists');
      expect(failure.message, 'Could not load lists');
      expect(failure.statusCode, 500);
    });

    test('CacheFailure should carry message', () {
      const failure = CacheFailure(message: 'Local cache error');
      expect(failure.message, 'Local cache error');
    });
  });
}
