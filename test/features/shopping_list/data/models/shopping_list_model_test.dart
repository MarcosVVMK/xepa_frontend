import 'package:flutter_test/flutter_test.dart';
import 'package:xepa_frontend/features/shopping_list/data/models/shopping_list_model.dart';
import 'package:xepa_frontend/features/shopping_list/domain/entities/shopping_list.dart';

void main() {
  group('ShoppingListModel', () {
    const tJson = {
      'id': 1,
      'name': 'Minha Lista',
      'color': '#00FF00',
      'shoppingListItems': [
        {
          'id': 1,
          'productId': 1,
          'productName': 'Arroz',
          'quantity': 2.0,
          'notes': 'Tio João'
        }
      ]
    };

    test('should be a subclass of ShoppingList entity', () {
      const model = ShoppingListModel(id: 1, name: 'T', color: 'C', items: []);
      expect(model, isA<ShoppingList>());
    });

    test('should return a valid model from JSON', () {
      final model = ShoppingListModel.fromJson(tJson);

      expect(model.id, 1);
      expect(model.name, 'Minha Lista');
      expect(model.items?.length, 1);
      expect(model.items?.first.productName, 'Arroz');
    });

    test('should return a JSON map containing proper data', () {
      final model = ShoppingListModel.fromJson(tJson);
      final result = model.toJson();

      expect(result['id'], 1);
      expect(result['name'], 'Minha Lista');
      expect(result['shoppingListItems'], isA<List>());
    });
  });
}
