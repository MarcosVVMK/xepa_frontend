import 'package:flutter_test/flutter_test.dart';
import 'package:xepa_frontend/features/auth/data/models/user_model.dart';
import 'package:xepa_frontend/features/auth/domain/entities/user.dart';

void main() {
  group('UserModel', () {
    const tUserJson = {
      'id': 1,
      'first_name': 'João',
      'last_name': 'Silva',
      'email': 'joao@email.com',
      'cpf': '12345678900',
      'phone': '31999999999',
      'created_at': '2026-04-20T10:00:00.000',
    };

    const tUserModel = UserModel(
      id: 1,
      firstName: 'João',
      lastName: 'Silva',
      email: 'joao@email.com',
      cpf: '12345678900',
      phone: '31999999999',
    );

    test('should be a subclass of User entity', () {
      expect(tUserModel, isA<User>());
    });

    group('fromJson', () {
      test('should return a valid UserModel from snake_case JSON', () {
        final result = UserModel.fromJson(tUserJson);

        expect(result.id, 1);
        expect(result.firstName, 'João');
        expect(result.lastName, 'Silva');
        expect(result.email, 'joao@email.com');
        expect(result.cpf, '12345678900');
        expect(result.phone, '31999999999');
        expect(result.createdAt, isNotNull);
      });

      test('should handle camelCase keys (firstName/lastName)', () {
        final json = {
          'id': 2,
          'firstName': 'Maria',
          'lastName': 'Santos',
          'email': 'maria@email.com',
          'cpf': '98765432100',
          'phone': '31888888888',
        };

        final result = UserModel.fromJson(json);
        expect(result.firstName, 'Maria');
        expect(result.lastName, 'Santos');
      });

      test('should handle missing/null fields gracefully', () {
        final result = UserModel.fromJson({});

        expect(result.id, isNull);
        expect(result.firstName, '');
        expect(result.lastName, '');
        expect(result.email, '');
        expect(result.cpf, '');
        expect(result.phone, '');
        expect(result.createdAt, isNull);
      });

      test('should parse created_at date correctly', () {
        final result = UserModel.fromJson(tUserJson);
        expect(result.createdAt, DateTime(2026, 4, 20, 10, 0, 0));
      });

      test('should handle createdAt (camelCase) date key', () {
        final json = {
          'email': 'test@test.com',
          'createdAt': '2026-01-15T08:30:00.000',
        };
        final result = UserModel.fromJson(json);
        expect(result.createdAt, DateTime(2026, 1, 15, 8, 30, 0));
      });
    });

    group('toJson', () {
      test('should return a valid JSON map with snake_case keys', () {
        final model = UserModel(
          id: 1,
          firstName: 'João',
          lastName: 'Silva',
          email: 'joao@email.com',
          cpf: '12345678900',
          phone: '31999999999',
          createdAt: DateTime(2026, 4, 20, 10, 0, 0),
        );
        final result = model.toJson();

        expect(result['id'], 1);
        expect(result['first_name'], 'João');
        expect(result['last_name'], 'Silva');
        expect(result['email'], 'joao@email.com');
        expect(result['cpf'], '12345678900');
        expect(result['phone'], '31999999999');
        expect(result['created_at'], isNotNull);
      });

      test('should handle null createdAt', () {
        final result = tUserModel.toJson();
        expect(result['created_at'], isNull);
      });
    });

    group('Equatable', () {
      test('should be equal when all properties match', () {
        const model1 = UserModel(
          id: 1,
          firstName: 'João',
          lastName: 'Silva',
          email: 'joao@email.com',
          cpf: '123',
          phone: '999',
        );
        const model2 = UserModel(
          id: 1,
          firstName: 'João',
          lastName: 'Silva',
          email: 'joao@email.com',
          cpf: '123',
          phone: '999',
        );
        expect(model1, equals(model2));
      });

      test('should NOT be equal when properties differ', () {
        const model1 = UserModel(
          firstName: 'João',
          lastName: 'Silva',
          email: 'joao@email.com',
          cpf: '123',
          phone: '999',
        );
        const model2 = UserModel(
          firstName: 'Maria',
          lastName: 'Silva',
          email: 'maria@email.com',
          cpf: '456',
          phone: '888',
        );
        expect(model1, isNot(equals(model2)));
      });
    });

    group('fromJson → toJson roundtrip', () {
      test('should preserve data through serialization roundtrip', () {
        final model = UserModel.fromJson(tUserJson);
        final json = model.toJson();

        expect(json['first_name'], tUserJson['first_name']);
        expect(json['last_name'], tUserJson['last_name']);
        expect(json['email'], tUserJson['email']);
        expect(json['cpf'], tUserJson['cpf']);
        expect(json['phone'], tUserJson['phone']);
      });
    });
  });
}
