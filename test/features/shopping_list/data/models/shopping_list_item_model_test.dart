import 'package:flutter_test/flutter_test.dart';
import 'package:xepa_frontend/features/shopping_list/data/models/shopping_list_item_model.dart';
import 'package:xepa_frontend/features/shopping_list/domain/entities/shopping_list_item.dart';

void main() {
  group('ShoppingListItemModel', () {
    const tJson = {
      'id': 1,
      'productId': 10,
      'productName': 'Arroz',
      'quantity': 2.5,
      'notes': 'Marca X'
    };

    test('should be a subclass of ShoppingListItem entity', () {
      const model = ShoppingListItemModel(id: 1, productId: 1, productName: 'T', quantity: 1.0);
      expect(model, isA<ShoppingListItem>());
    });

    test('should return a valid model from JSON', () {
      final model = ShoppingListItemModel.fromJson(tJson);

      expect(model.id, 1);
      expect(model.productName, 'Arroz');
      expect(model.quantity, 2.5);
    });

    test('should return a JSON map containing proper data', () {
      final model = ShoppingListItemModel.fromJson(tJson);
      final result = model.toJson();

      expect(result['id'], 1);
      expect(result['productName'], 'Arroz');
      expect(result['quantity'], 2.5);
    });
  });
}
