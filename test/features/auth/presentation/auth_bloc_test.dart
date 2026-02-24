import 'package:artist_management_system/core/error/failures.dart';
import 'package:artist_management_system/features/auth/domain/usecases/get_current_user.dart';
import 'package:artist_management_system/features/auth/domain/usecases/google_signin_user.dart';
import 'package:artist_management_system/features/auth/domain/usecases/login_user.dart';
import 'package:artist_management_system/features/auth/domain/usecases/logout_user.dart';
import 'package:artist_management_system/features/auth/domain/usecases/register_user.dart';
import 'package:artist_management_system/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/mock_repositories.dart';
import '../../../helpers/test_fixtures.dart';

AuthBloc _makeBloc(MockAuthRepository repo) => AuthBloc(
  getCurrentUser: GetCurrentUser(repo),
  loginUser: LoginUser(repo),
  registerUser: RegisterUser(repo),
  logoutUser: LogoutUser(repo),
  googleSignInUser: GoogleSignInUser(repo),
);

void main() {
  late MockAuthRepository repo;

  setUp(() => repo = MockAuthRepository());

  test('initial state is AuthInitial', () {
    expect(_makeBloc(repo).state, isA<AuthInitial>());
  });

  group('AuthCheckRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Authenticated] when user is logged in',
      build: () {
        repo.stubGetCurrentUser(Right(tUser()));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Unauthenticated] when no user',
      build: () {
        repo.stubGetCurrentUser(const Right(null));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [isA<AuthLoading>(), isA<AuthUnauthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Unauthenticated] on failure',
      build: () {
        repo.stubGetCurrentUser(Left(const AuthFailure('error')));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [isA<AuthLoading>(), isA<AuthUnauthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'Authenticated state contains the user',
      build: () {
        repo.stubGetCurrentUser(Right(tUser()));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>().having((s) => s.user, 'user', tUser()),
      ],
    );
  });

  group('AuthLoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Authenticated] on success',
      build: () {
        repo.stubLogin(Right(tUser()));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(email: 'aastha@test.com', password: 'pass123'),
      ),
      expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, AuthError] on wrong credentials',
      build: () {
        repo.stubLogin(Left(const AuthFailure('Invalid email or password.')));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(email: 'wrong@test.com', password: 'wrong'),
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having(
          (s) => s.message,
          'message',
          'Invalid email or password.',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, AuthError] on server failure',
      build: () {
        repo.stubLogin(Left(const ServerFailure('Server error')));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(email: 'a@test.com', password: 'pass'),
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having((s) => s.message, 'message', 'Server error'),
      ],
    );
  });

  group('AuthGoogleSignInRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Authenticated] on success',
      build: () {
        repo.stubGoogleSignIn(Right(tUser()));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(AuthGoogleSignInRequested()),
      expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, AuthError] when cancelled',
      build: () {
        repo.stubGoogleSignIn(
          Left(const AuthFailure('Google sign-in cancelled.')),
        );
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(AuthGoogleSignInRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having(
          (s) => s.message,
          'message',
          'Google sign-in cancelled.',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, AuthError] when token missing',
      build: () {
        repo.stubGoogleSignIn(
          Left(const AuthFailure('Failed to get authentication token')),
        );
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(AuthGoogleSignInRequested()),
      expect: () => [isA<AuthLoading>(), isA<AuthError>()],
    );
  });

  group('AuthRegisterRequested', () {
    final tEvent = AuthRegisterRequested(
      email: 'new@test.com',
      password: 'pass123',
      firstName: 'Aastha',
      lastName: 'B',
      phone: '9800000000',
      gender: 'f',
      address: 'Kathmandu',
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, AuthRegistered] on success',
      build: () {
        repo.stubRegister(Right(tUser()));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(tEvent),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthRegistered>().having(
          (s) => s.message,
          'message',
          'Registration successful! Please login.',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, AuthError] when email already in use',
      build: () {
        repo.stubRegister(
          Left(const AuthFailure('Email already registered. Please login.')),
        );
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(tEvent),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having(
          (s) => s.message,
          'message',
          'Email already registered. Please login.',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, AuthError] on weak password',
      build: () {
        repo.stubRegister(
          Left(const AuthFailure('Password must be at least 6 characters.')),
        );
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(tEvent),
      expect: () => [isA<AuthLoading>(), isA<AuthError>()],
    );
  });

  group('AuthLogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [Unauthenticated] after logout',
      build: () {
        repo.stubLogout(const Right(null));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(AuthLogoutRequested()),
      expect: () => [isA<AuthUnauthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Unauthenticated] even if logout fails (fire-and-forget)',
      build: () {
        repo.stubLogout(Left(const ServerFailure('Logout failed.')));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(AuthLogoutRequested()),
      expect: () => [isA<AuthUnauthenticated>()],
    );
  });

  group('State equality', () {
    test('AuthAuthenticated with same user are equal', () {
      expect(AuthAuthenticated(tUser()), equals(AuthAuthenticated(tUser())));
    });

    test('AuthAuthenticated with different users are not equal', () {
      expect(
        AuthAuthenticated(tUser(id: 'a')),
        isNot(equals(AuthAuthenticated(tUser(id: 'b')))),
      );
    });

    test('AuthError with same message are equal', () {
      expect(const AuthError('err'), equals(const AuthError('err')));
    });

    test('AuthRegistered with same message are equal', () {
      expect(const AuthRegistered('ok'), equals(const AuthRegistered('ok')));
    });
  });
}
