import 'package:artist_management_system/core/error/failures.dart';
import 'package:artist_management_system/features/user/domain/usecases/delete_user_usecase.dart';
import 'package:artist_management_system/features/user/domain/usecases/update_user_usecase.dart';
import 'package:artist_management_system/features/user/domain/usecases/watch_user_usecase.dart';
import 'package:artist_management_system/features/user/presentation/bloc/user_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/mock_repositories.dart';
import '../../../helpers/test_fixtures.dart';

UserBloc _makeBloc(MockUserRepository repo) => UserBloc(
  watchUsers: WatchUsers(repo),
  updateUser: UpdateUser(repo),
  deleteUser: DeleteUser(repo),
);

void main() {
  late MockUserRepository repo;

  setUp(() => repo = MockUserRepository());

  test('initial state is UserInitial', () {
    expect(_makeBloc(repo).state, isA<UserInitial>());
  });

  group('UserWatchStarted', () {
    blocTest<UserBloc, UserState>(
      'emits [Loading, Loaded] with users',
      build: () {
        repo.stubWatch(Stream.value(Right([tUser()])));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(UserWatchStarted()),
      expect: () => [
        isA<UserLoading>(),
        isA<UserLoaded>().having((s) => s.users, 'users', [tUser()]),
      ],
    );

    blocTest<UserBloc, UserState>(
      'emits [Loading, Loaded(empty)] when no users',
      build: () {
        repo.stubWatch(Stream.value(const Right([])));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(UserWatchStarted()),
      expect: () => [
        isA<UserLoading>(),
        isA<UserLoaded>().having((s) => s.users, 'users', isEmpty),
      ],
    );

    blocTest<UserBloc, UserState>(
      'emits [Loading, UserError] on stream failure',
      build: () {
        repo.stubWatch(
          Stream.value(Left(const ServerFailure('Firestore error'))),
        );
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(UserWatchStarted()),
      expect: () => [
        isA<UserLoading>(),
        isA<UserError>().having((s) => s.message, 'message', 'Firestore error'),
      ],
    );

    blocTest<UserBloc, UserState>(
      'emits multiple Loaded states as stream updates',
      build: () {
        repo.stubWatch(
          Stream.fromIterable([
            Right([tUser(id: 'u1')]),
            Right([tUser(id: 'u1'), tUser(id: 'u2')]),
          ]),
        );
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(UserWatchStarted()),
      expect: () => [
        isA<UserLoading>(),
        isA<UserLoaded>().having((s) => s.users.length, 'count', 1),
        isA<UserLoaded>().having((s) => s.users.length, 'count', 2),
      ],
    );

    blocTest<UserBloc, UserState>(
      'Loaded state contains correct user data',
      build: () {
        repo.stubWatch(Stream.value(Right([tSuperAdmin()])));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(UserWatchStarted()),
      expect: () => [
        isA<UserLoading>(),
        isA<UserLoaded>().having(
          (s) => s.users.first.role,
          'role',
          'superadmin',
        ),
      ],
    );
  });

  group('UserUpdateRequested', () {
    blocTest<UserBloc, UserState>(
      'emits nothing on success',
      build: () {
        repo.stubUpdate(const Right(null));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(UserUpdateRequested(tUser())),
      expect: () => [],
    );

    blocTest<UserBloc, UserState>(
      'emits UserError on failure',
      build: () {
        repo.stubUpdate(Left(const ServerFailure('Update failed')));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(UserUpdateRequested(tUser())),
      expect: () => [
        isA<UserError>().having((s) => s.message, 'message', 'Update failed'),
      ],
    );
  });

  group('UserDeleteRequested', () {
    blocTest<UserBloc, UserState>(
      'emits nothing on success',
      build: () {
        repo.stubDelete(const Right(null));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(const UserDeleteRequested('user-1')),
      expect: () => [],
    );

    blocTest<UserBloc, UserState>(
      'emits UserError on failure',
      build: () {
        repo.stubDelete(Left(const ServerFailure('Delete failed')));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(const UserDeleteRequested('user-1')),
      expect: () => [
        isA<UserError>().having((s) => s.message, 'message', 'Delete failed'),
      ],
    );

    blocTest<UserBloc, UserState>(
      'emits UserError with correct message from AuthFailure',
      build: () {
        repo.stubDelete(Left(const AuthFailure('Permission denied')));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(const UserDeleteRequested('user-1')),
      expect: () => [
        isA<UserError>().having(
          (s) => s.message,
          'message',
          'Permission denied',
        ),
      ],
    );
  });

  group('State equality', () {
    test('UserLoaded with same users are equal', () {
      expect(UserLoaded([tUser()]), equals(UserLoaded([tUser()])));
    });

    test('UserLoaded with different users are not equal', () {
      expect(
        UserLoaded([tUser(id: 'a')]),
        isNot(equals(UserLoaded([tUser(id: 'b')]))),
      );
    });

    test('UserError with same message are equal', () {
      expect(const UserError('err'), equals(const UserError('err')));
    });

    test('UserError with different messages are not equal', () {
      expect(const UserError('err1'), isNot(equals(const UserError('err2'))));
    });
  });
}
