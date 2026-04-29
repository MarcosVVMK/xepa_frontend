import 'package:flutter_test/flutter_test.dart';
import 'package:xepa_frontend/core/errors/failure.dart';

void main() {
  group('Failure', () {
    group('ServerFailure', () {
      test('should store message correctly', () {
        const failure = ServerFailure(message: 'Internal server error');
        expect(failure.message, 'Internal server error');
      });

      test('should have default statusCode 500', () {
        const failure = ServerFailure(message: 'Error');
        expect(failure.statusCode, 500);
      });

      test('should accept custom statusCode', () {
        const failure = ServerFailure(message: 'Not found', statusCode: 404);
        expect(failure.statusCode, 404);
      });

      test('should be equal when same message and statusCode', () {
        const f1 = ServerFailure(message: 'Error', statusCode: 500);
        const f2 = ServerFailure(message: 'Error', statusCode: 500);
        expect(f1, equals(f2));
      });

      test('should NOT be equal when different message', () {
        const f1 = ServerFailure(message: 'Error A');
        const f2 = ServerFailure(message: 'Error B');
        expect(f1, isNot(equals(f2)));
      });

      test('should NOT be equal when different statusCode', () {
        const f1 = ServerFailure(message: 'Error', statusCode: 500);
        const f2 = ServerFailure(message: 'Error', statusCode: 404);
        expect(f1, isNot(equals(f2)));
      });
    });

    group('CacheFailure', () {
      test('should store message correctly', () {
        const failure = CacheFailure(message: 'Cache miss');
        expect(failure.message, 'Cache miss');
      });

      test('should have default statusCode 500', () {
        const failure = CacheFailure(message: 'Error');
        expect(failure.statusCode, 500);
      });

      test('should be equal when same properties', () {
        const f1 = CacheFailure(message: 'Error');
        const f2 = CacheFailure(message: 'Error');
        expect(f1, equals(f2));
      });
    });

    group('Cross-type comparison', () {
      test('ServerFailure and CacheFailure with same props should be equal (Equatable)', () {
        // Both extend Failure with same props [message, statusCode]
        const server = ServerFailure(message: 'Error', statusCode: 500);
        const cache = CacheFailure(message: 'Error', statusCode: 500);
        // Equatable compares props, not runtime type
        expect(server.props, equals(cache.props));
      });
    });
  });
}
