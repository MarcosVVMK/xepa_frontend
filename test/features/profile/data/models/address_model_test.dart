import 'package:flutter_test/flutter_test.dart';
import 'package:xepa_frontend/features/profile/data/models/address_model.dart';

void main() {
  group('AddressModel', () {
    const tAddressJson = {
      'id': 1,
      'zip_code': '30130-000',
      'street': 'Rua da Bahia',
      'number': '1234',
      'complement': 'Apt 101',
      'neighborhood': 'Centro',
      'city': 'Belo Horizonte',
      'state': 'Minas Gerais',
      'uf': 'MG',
      'created_at': '2026-04-20T10:00:00.000',
      'updated_at': '2026-04-21T15:30:00.000',
    };

    const tAddressModel = AddressModel(
      id: 1,
      zipCode: '30130-000',
      street: 'Rua da Bahia',
      number: '1234',
      complement: 'Apt 101',
      neighborhood: 'Centro',
      city: 'Belo Horizonte',
      state: 'Minas Gerais',
      uf: 'MG',
    );

    test('should be a subclass of Address', () {
      expect(tAddressModel, isA<AddressModel>());
    });

    group('fromJson', () {
      test('should return a valid AddressModel from JSON', () {
        final result = AddressModel.fromJson(tAddressJson);

        expect(result.id, 1);
        expect(result.zipCode, '30130-000');
        expect(result.street, 'Rua da Bahia');
        expect(result.number, '1234');
        expect(result.complement, 'Apt 101');
        expect(result.neighborhood, 'Centro');
        expect(result.city, 'Belo Horizonte');
        expect(result.state, 'Minas Gerais');
        expect(result.uf, 'MG');
        expect(result.createdAt, isNotNull);
        expect(result.updatedAt, isNotNull);
      });

      test('should handle missing optional fields', () {
        final minimalJson = {
          'street': 'Rua Teste',
          'number': '10',
          'neighborhood': 'Bairro',
          'city': 'Cidade',
          'state': 'Estado',
          'uf': 'XX',
        };

        final result = AddressModel.fromJson(minimalJson);

        expect(result.id, isNull);
        expect(result.zipCode, '');
        expect(result.complement, '');
        expect(result.createdAt, isNull);
        expect(result.updatedAt, isNull);
      });

      test('should handle empty JSON gracefully', () {
        final result = AddressModel.fromJson({});

        expect(result.zipCode, '');
        expect(result.street, '');
        expect(result.number, '');
        expect(result.complement, '');
        expect(result.neighborhood, '');
        expect(result.city, '');
        expect(result.state, '');
        expect(result.uf, '');
      });
    });

    group('toJson', () {
      test('should return a valid JSON map', () {
        final result = AddressModel(
          id: 1,
          zipCode: '30130-000',
          street: 'Rua da Bahia',
          number: '1234',
          complement: 'Apt 101',
          neighborhood: 'Centro',
          city: 'Belo Horizonte',
          state: 'Minas Gerais',
          uf: 'MG',
          createdAt: DateTime.parse('2026-04-20T10:00:00.000'),
          updatedAt: DateTime.parse('2026-04-21T15:30:00.000'),
        ).toJson();

        expect(result['id'], 1);
        expect(result['zip_code'], '30130-000');
        expect(result['street'], 'Rua da Bahia');
        expect(result['number'], '1234');
        expect(result['complement'], 'Apt 101');
        expect(result['neighborhood'], 'Centro');
        expect(result['city'], 'Belo Horizonte');
        expect(result['state'], 'Minas Gerais');
        expect(result['uf'], 'MG');
        expect(result['created_at'], isNotNull);
        expect(result['updated_at'], isNotNull);
      });

      test('should handle null dates in toJson', () {
        final result = tAddressModel.toJson();

        expect(result['created_at'], isNull);
        expect(result['updated_at'], isNull);
      });
    });

    group('fromJson → toJson roundtrip', () {
      test('should preserve data through serialization roundtrip', () {
        final model = AddressModel.fromJson(tAddressJson);
        final json = model.toJson();

        expect(json['zip_code'], tAddressJson['zip_code']);
        expect(json['street'], tAddressJson['street']);
        expect(json['number'], tAddressJson['number']);
        expect(json['complement'], tAddressJson['complement']);
        expect(json['neighborhood'], tAddressJson['neighborhood']);
        expect(json['city'], tAddressJson['city']);
        expect(json['state'], tAddressJson['state']);
        expect(json['uf'], tAddressJson['uf']);
      });
    });
  });
}
