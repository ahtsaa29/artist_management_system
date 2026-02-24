import 'package:artist_management_system/core/error/exceptions.dart';
import 'package:artist_management_system/core/error/failures.dart';
import 'package:artist_management_system/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/mock_datasources.dart';
import '../../../helpers/user_model_fixture.dart';

void main() {
  late MockAuthRemoteDataSource ds;
  late AuthRepositoryImpl repo;

  setUp(() {
    ds = MockAuthRemoteDataSource();
    repo = AuthRepositoryImpl(remoteDataSource: ds);
  });

  group('getCurrentUser', () {
    test('returns Right(user) when datasource returns a user', () async {
      ds.stubCurrentUser(tUserModel());
      final result = await repo.getCurrentUser();
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be Right'),
        (u) => expect(u?.email, tUserModel().email),
      );
    });

    test('returns Right(null) when not logged in', () async {
      ds.stubCurrentUser(null);
      final result = await repo.getCurrentUser();
      expect(result, const Right(null));
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      ds.stubCurrentUserError(const ServerException('Firestore error'));
      final result = await repo.getCurrentUser();
      expect(result.isLeft(), isTrue);
      result.fold((f) {
        expect(f, isA<ServerFailure>());
        expect(f.message, 'Firestore error');
      }, (_) => fail('Should be Left'));
    });

    test('returns Left(AuthFailure) on AuthException', () async {
      ds.stubCurrentUserError(const AuthException('Not authenticated'));
      final result = await repo.getCurrentUser();
      result.fold(
        (f) => expect(f, isA<AuthFailure>()),
        (_) => fail('Should be Left'),
      );
    });
  });

  group('login', () {
    test('returns Right(user) on success', () async {
      ds.stubLogin(tUserModel());
      final result = await repo.login(email: 'a@a.com', password: 'pass');
      expect(result.isRight(), isTrue);
    });

    test('returns Left(AuthFailure) on AuthException', () async {
      ds.stubLoginError(const AuthException('Invalid email or password.'));
      final result = await repo.login(email: 'a@a.com', password: 'wrong');
      result.fold((f) {
        expect(f, isA<AuthFailure>());
        expect(f.message, 'Invalid email or password.');
      }, (_) => fail('Should be Left'));
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      ds.stubLoginError(const ServerException('Server error'));
      final result = await repo.login(email: 'a@a.com', password: 'pass');
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('Should be Left'),
      );
    });
  });

  group('register', () {
    test('returns Right(user) on success', () async {
      ds.stubRegister(tUserModel());
      final result = await repo.register(
        email: 'new@test.com',
        password: 'pass123',
        firstName: 'A',
        lastName: 'B',
        phone: '1',
        gender: 'm',
        address: 'addr',
      );
      expect(result.isRight(), isTrue);
    });

    test('returns Left(AuthFailure) on AuthException', () async {
      ds.stubRegisterError(
        const AuthException('Email already registered. Please login.'),
      );
      final result = await repo.register(
        email: 'x@x.com',
        password: 'pass',
        firstName: 'A',
        lastName: 'B',
        phone: '1',
        gender: 'm',
        address: 'addr',
      );
      result.fold((f) {
        expect(f, isA<AuthFailure>());
        expect(f.message, 'Email already registered. Please login.');
      }, (_) => fail('Should be Left'));
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      ds.stubRegisterError(const ServerException('Network error'));
      final result = await repo.register(
        email: 'x@x.com',
        password: 'pass',
        firstName: 'A',
        lastName: 'B',
        phone: '1',
        gender: 'm',
        address: 'addr',
      );
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('Should be Left'),
      );
    });
  });

  group('signInWithGoogle', () {
    test('returns Right(user) on success', () async {
      ds.stubGoogle(tUserModel());
      final result = await repo.signInWithGoogle();
      expect(result.isRight(), isTrue);
    });

    test('returns Left(AuthFailure) on AuthException', () async {
      ds.stubGoogleError(const AuthException('Google sign-in cancelled.'));
      final result = await repo.signInWithGoogle();
      result.fold((f) {
        expect(f, isA<AuthFailure>());
        expect(f.message, 'Google sign-in cancelled.');
      }, (_) => fail('Should be Left'));
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      ds.stubGoogleError(const ServerException('Firebase error'));
      final result = await repo.signInWithGoogle();
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('Should be Left'),
      );
    });
  });

  group('logout', () {
    test('returns Right(null) on success', () async {
      final result = await repo.logout();
      expect(result, const Right(null));
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      ds.stubLogoutError(const ServerException('Logout failed.'));
      final result = await repo.logout();
      result.fold((f) {
        expect(f, isA<ServerFailure>());
        expect(f.message, 'Logout failed.');
      }, (_) => fail('Should be Left'));
    });
  });
}
