import 'package:artist_management_system/core/error/failures.dart';
import 'package:artist_management_system/core/usecases/usecase.dart';
import 'package:artist_management_system/features/auth/domain/usecases/get_current_user.dart';
import 'package:artist_management_system/features/auth/domain/usecases/google_signin_user.dart';
import 'package:artist_management_system/features/auth/domain/usecases/login_user.dart';
import 'package:artist_management_system/features/auth/domain/usecases/logout_user.dart';
import 'package:artist_management_system/features/auth/domain/usecases/register_user.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/mock_repositories.dart';
import '../../../helpers/test_fixtures.dart';

void main() {
  late MockAuthRepository repo;

  setUp(() => repo = MockAuthRepository());

  group('GetCurrentUser', () {
    late GetCurrentUser usecase;
    setUp(() => usecase = GetCurrentUser(repo));

    test('returns user when authenticated', () async {
      repo.stubGetCurrentUser(Right(tUser()));
      final result = await usecase(const NoParams());
      expect(result, Right(tUser()));
    });

    test('returns null when not authenticated', () async {
      repo.stubGetCurrentUser(const Right(null));
      final result = await usecase(const NoParams());
      expect(result, const Right(null));
    });

    test('returns AuthFailure on error', () async {
      repo.stubGetCurrentUser(Left(const AuthFailure('Not authenticated')));
      final result = await usecase(const NoParams());
      expect(result, Left(const AuthFailure('Not authenticated')));
    });
  });

  group('LoginUser', () {
    late LoginUser usecase;
    setUp(() => usecase = LoginUser(repo));

    test('returns user on successful login', () async {
      repo.stubLogin(Right(tUser()));
      final result = await usecase(
        const LoginParams(email: 'aastha@test.com', password: 'pass123'),
      );
      expect(result, Right(tUser()));
    });

    test('returns AuthFailure on wrong credentials', () async {
      repo.stubLogin(Left(const AuthFailure('Invalid email or password.')));
      final result = await usecase(
        const LoginParams(email: 'wrong@test.com', password: 'wrong'),
      );
      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f.message, 'Invalid email or password.'),
        (_) => fail('Should be failure'),
      );
    });

    test('LoginParams equality works', () {
      const p1 = LoginParams(email: 'a@a.com', password: '123');
      const p2 = LoginParams(email: 'a@a.com', password: '123');
      expect(p1, equals(p2));
    });

    test('LoginParams with different values are not equal', () {
      const p1 = LoginParams(email: 'a@a.com', password: '123');
      const p2 = LoginParams(email: 'b@b.com', password: '123');
      expect(p1, isNot(equals(p2)));
    });
  });

  group('RegisterUser', () {
    late RegisterUser usecase;
    setUp(() => usecase = RegisterUser(repo));

    final tParams = RegisterParams(
      email: 'new@test.com',
      password: 'pass123',
      firstName: 'Aastha',
      lastName: 'B',
      phone: '9800000000',
      gender: 'f',
      address: 'Kathmandu',
    );

    test('returns user on successful registration', () async {
      repo.stubRegister(Right(tUser()));
      final result = await usecase(tParams);
      expect(result, Right(tUser()));
    });

    test('returns AuthFailure when email already in use', () async {
      repo.stubRegister(
        Left(const AuthFailure('Email already registered. Please login.')),
      );
      final result = await usecase(tParams);
      expect(result.isLeft(), isTrue);
    });

    test('RegisterParams equality works', () {
      final p1 = RegisterParams(
        email: 'a@a.com',
        password: '123',
        firstName: 'A',
        lastName: 'B',
        phone: '1',
        gender: 'm',
        address: 'addr',
      );
      final p2 = RegisterParams(
        email: 'a@a.com',
        password: '123',
        firstName: 'A',
        lastName: 'B',
        phone: '1',
        gender: 'm',
        address: 'addr',
      );
      expect(p1, equals(p2));
    });

    test('RegisterParams with dob included', () async {
      final dob = DateTime(1995, 5, 10);
      repo.stubRegister(Right(tUser()));
      final result = await usecase(tParams.copyWith(dob: dob));
      expect(result.isRight(), isTrue);
    });
  });

  group('LogoutUser', () {
    late LogoutUser usecase;
    setUp(() => usecase = LogoutUser(repo));

    test('returns Right(null) on success', () async {
      repo.stubLogout(const Right(null));
      final result = await usecase(const NoParams());
      expect(result, const Right(null));
    });

    test('returns ServerFailure on error', () async {
      repo.stubLogout(Left(const ServerFailure('Logout failed.')));
      final result = await usecase(const NoParams());
      expect(result.isLeft(), isTrue);
    });
  });

  group('GoogleSignInUser', () {
    late GoogleSignInUser usecase;
    setUp(() => usecase = GoogleSignInUser(repo));

    test('returns user on successful Google sign-in', () async {
      repo.stubGoogleSignIn(Right(tUser()));
      final result = await usecase(const NoParams());
      expect(result, Right(tUser()));
    });

    test('returns AuthFailure when cancelled', () async {
      repo.stubGoogleSignIn(
        Left(const AuthFailure('Google sign-in cancelled.')),
      );
      final result = await usecase(const NoParams());
      result.fold(
        (f) => expect(f.message, 'Google sign-in cancelled.'),
        (_) => fail('Should be failure'),
      );
    });

    test('returns AuthFailure when token missing', () async {
      repo.stubGoogleSignIn(
        Left(const AuthFailure('Failed to get authentication token')),
      );
      final result = await usecase(const NoParams());
      expect(result.isLeft(), isTrue);
    });
  });
}

extension on RegisterParams {
  RegisterParams copyWith({DateTime? dob}) => RegisterParams(
    email: email,
    password: password,
    firstName: firstName,
    lastName: lastName,
    phone: phone,
    gender: gender,
    address: address,
    dob: dob ?? this.dob,
  );
}
