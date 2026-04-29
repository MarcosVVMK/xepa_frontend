import 'package:flutter_test/flutter_test.dart';
import 'package:xepa_frontend/features/profile/data/models/profile_model.dart';
import 'package:xepa_frontend/features/profile/domain/entities/profile.dart';

void main() {
  group('ProfileModel', () {
    final tProfileJson = {
      'id': 1,
      'first_name': 'João',
      'last_name': 'Silva',
      'email': 'joao@email.com',
      'cpf': '12345678900',
      'phone': '31999999999',
      'address': {
        'id': 10,
        'zip_code': '30130-000',
        'street': 'Rua da Bahia',
        'number': '1234',
        'complement': '',
        'neighborhood': 'Centro',
        'city': 'Belo Horizonte',
        'state': 'Minas Gerais',
        'uf': 'MG',
      },
      'created_at': '2026-04-20T10:00:00.000',
    };

    final tProfileJsonNoAddress = {
      'id': 2,
      'first_name': 'Maria',
      'last_name': 'Santos',
      'email': 'maria@email.com',
      'cpf': '98765432100',
      'phone': '31888888888',
      'created_at': '2026-04-21T14:00:00.000',
    };

    test('should be a subclass of Profile', () {
      final model = ProfileModel.fromJson(tProfileJson);
      expect(model, isA<Profile>());
    });

    group('fromJson', () {
      test('should return a valid ProfileModel with address', () {
        final result = ProfileModel.fromJson(tProfileJson);

        expect(result.id, 1);
        expect(result.firstName, 'João');
        expect(result.lastName, 'Silva');
        expect(result.email, 'joao@email.com');
        expect(result.cpf, '12345678900');
        expect(result.phone, '31999999999');
        expect(result.address, isNotNull);
        expect(result.address!.street, 'Rua da Bahia');
        expect(result.address!.city, 'Belo Horizonte');
        expect(result.createdAt, isNotNull);
      });

      test('should return a valid ProfileModel without address', () {
        final result = ProfileModel.fromJson(tProfileJsonNoAddress);

        expect(result.id, 2);
        expect(result.firstName, 'Maria');
        expect(result.lastName, 'Santos');
        expect(result.address, isNull);
      });

      test('should handle camelCase keys (firstName/lastName)', () {
        final json = {
          'id': 3,
          'firstName': 'Pedro',
          'lastName': 'Costa',
          'email': 'pedro@email.com',
          'cpf': '11122233344',
          'phone': '31777777777',
        };

        final result = ProfileModel.fromJson(json);
        expect(result.firstName, 'Pedro');
        expect(result.lastName, 'Costa');
      });

      test('should handle empty/null fields gracefully', () {
        final result = ProfileModel.fromJson({});

        expect(result.id, isNull);
        expect(result.firstName, '');
        expect(result.lastName, '');
        expect(result.email, '');
        expect(result.cpf, '');
        expect(result.phone, '');
        expect(result.address, isNull);
        expect(result.createdAt, isNull);
      });
    });

    group('toJson', () {
      test('should return a valid JSON map with address', () {
        final model = ProfileModel.fromJson(tProfileJson);
        final result = model.toJson();

        expect(result['id'], 1);
        expect(result['first_name'], 'João');
        expect(result['last_name'], 'Silva');
        expect(result['email'], 'joao@email.com');
        expect(result['cpf'], '12345678900');
        expect(result['phone'], '31999999999');
        expect(result['address'], isA<Map>());
        expect(result['address']['street'], 'Rua da Bahia');
        expect(result['created_at'], isNotNull);
      });

      test('should return null address when no address', () {
        final model = ProfileModel.fromJson(tProfileJsonNoAddress);
        final result = model.toJson();

        expect(result['address'], isNull);
      });
    });

    group('fromEntity', () {
      test('should create ProfileModel from Profile entity', () {
        const entity = Profile(
          id: 5,
          firstName: 'Ana',
          lastName: 'Lima',
          email: 'ana@email.com',
          cpf: '55566677788',
          phone: '31666666666',
        );

        final model = ProfileModel.fromEntity(entity);

        expect(model.id, entity.id);
        expect(model.firstName, entity.firstName);
        expect(model.lastName, entity.lastName);
        expect(model.email, entity.email);
        expect(model.cpf, entity.cpf);
        expect(model.phone, entity.phone);
      });
    });

    group('fromJson → toJson roundtrip', () {
      test('should preserve profile data through roundtrip', () {
        final model = ProfileModel.fromJson(tProfileJson);
        final json = model.toJson();

        expect(json['first_name'], tProfileJson['first_name']);
        expect(json['last_name'], tProfileJson['last_name']);
        expect(json['email'], tProfileJson['email']);
        expect(json['cpf'], tProfileJson['cpf']);
        expect(json['phone'], tProfileJson['phone']);
      });

      test('should preserve address data through roundtrip', () {
        final model = ProfileModel.fromJson(tProfileJson);
        final json = model.toJson();
        final addressJson = tProfileJson['address'] as Map<String, dynamic>;

        expect(json['address']['zip_code'], addressJson['zip_code']);
        expect(json['address']['street'], addressJson['street']);
        expect(json['address']['city'], addressJson['city']);
        expect(json['address']['uf'], addressJson['uf']);
      });
    });
  });
}
