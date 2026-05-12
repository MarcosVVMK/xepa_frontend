import 'package:flutter_test/flutter_test.dart' hide ComparisonResult;
import 'package:xepa_frontend/features/shopping_list/data/models/comparison_result_model.dart';
import 'package:xepa_frontend/features/shopping_list/domain/entities/comparison_result.dart';

void main() {
  group('ComparisonResultModel', () {
    final tJson = {
      'shoppingListName': 'Lista Teste',
      'totalItemsInList': 10,
      'comparisonDate': '2024-05-12T10:00:00Z',
      'supermarketsCompared': 5,
      'comparisons': [
        {
          'supermarket': {
            'id': 1,
            'name': 'Supermercado A',
            'address': {
              'street': 'Rua A',
              'number': '123',
              'neighborhood': 'Bairro A',
              'city': 'Cidade A',
              'state': 'Estado A',
              'latitude': -23.0,
              'longitude': -46.0
            }
          },
          'totalValue': 150.50,
          'itemsFound': 8,
          'totalItems': 10,
          'itemsFoundList': [],
          'notFoundItems': []
        }
      ]
    };

    test('should be a subclass of ComparisonResult entity', () {
      final model = ComparisonResultModel.fromJson(tJson);
      expect(model, isA<ComparisonResult>());
    });

    test('should return a valid model from JSON', () {
      final model = ComparisonResultModel.fromJson(tJson);

      expect(model.shoppingListName, 'Lista Teste');
      expect(model.totalItemsInList, 10);
      expect(model.supermarketsCompared, 5);
      expect(model.comparisons.length, 1);
      expect(model.comparisons.first.supermarket.name, 'Supermercado A');
    });

    test('should handle missing or null fields gracefully', () {
      final invalidJson = {
        'shoppingListName': null,
        'totalItemsInList': null,
        'comparisons': null,
      };

      final model = ComparisonResultModel.fromJson(invalidJson);

      expect(model.shoppingListName, '');
      expect(model.totalItemsInList, 0);
      expect(model.comparisons, isEmpty);
      expect(model.comparisonDate, isA<DateTime>());
    });

    test('should return a JSON map containing proper data', () {
      final model = ComparisonResultModel.fromJson(tJson);
      final result = model.toJson();

      expect(result['shoppingListName'], 'Lista Teste');
      expect(result['totalItemsInList'], 10);
      expect(result['comparisons'], isA<List>());
    });
  });
}
