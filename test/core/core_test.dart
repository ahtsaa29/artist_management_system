import 'package:artist_management_system/core/error/exceptions.dart';
import 'package:artist_management_system/core/error/failures.dart';
import 'package:artist_management_system/core/usecases/usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Exceptions
  group('Exceptions', () {
    test('ServerException has default message', () {
      const e = ServerException();
      expect(e.message, 'A server error occurred.');
    });

    test('ServerException accepts custom message', () {
      const e = ServerException('Custom error');
      expect(e.message, 'Custom error');
    });

    test('AuthException has default message', () {
      const e = AuthException();
      expect(e.message, 'Authentication failed.');
    });

    test('AuthException accepts custom message', () {
      const e = AuthException('Invalid token');
      expect(e.message, 'Invalid token');
    });

    test('NetworkException has default message', () {
      const e = NetworkException();
      expect(e.message, 'No internet connection.');
    });

    test('CacheException has default message', () {
      const e = CacheException();
      expect(e.message, 'Cache error.');
    });

    test('exceptions are throwable', () {
      expect(
        () => throw const ServerException('boom'),
        throwsA(isA<ServerException>()),
      );
      expect(
        () => throw const AuthException('fail'),
        throwsA(isA<AuthException>()),
      );
    });
  });

  // Failures
  group('Failures', () {
    test('ServerFailure has default message', () {
      const f = ServerFailure();
      expect(f.message, 'A server error occurred.');
    });

    test('ServerFailure accepts custom message', () {
      const f = ServerFailure('Custom');
      expect(f.message, 'Custom');
    });

    test('AuthFailure has default message', () {
      const f = AuthFailure();
      expect(f.message, 'Authentication failed.');
    });

    test('NetworkFailure has default message', () {
      const f = NetworkFailure();
      expect(f.message, 'No internet connection.');
    });

    test('CacheFailure has default message', () {
      const f = CacheFailure();
      expect(f.message, 'Cache error occurred.');
    });

    test('NotFoundFailure has default message', () {
      const f = NotFoundFailure();
      expect(f.message, 'Not found.');
    });

    test('PermissionFailure has default message', () {
      const f = PermissionFailure();
      expect(f.message, 'Permission denied.');
    });

    test('Failures with same message are equal (Equatable)', () {
      expect(const ServerFailure('err'), equals(const ServerFailure('err')));
    });

    test('Failures with different messages are not equal', () {
      expect(const ServerFailure('a'), isNot(equals(const ServerFailure('b'))));
    });

    test('Different failure types with same message are not equal', () {
      expect(
        const ServerFailure('err'),
        isNot(equals(const AuthFailure('err'))),
      );
    });
  });

  // NoParams
  group('NoParams', () {
    test('two NoParams instances are equal', () {
      expect(const NoParams(), equals(const NoParams()));
    });

    test('props is empty', () {
      expect(const NoParams().props, isEmpty);
    });
  });
}
