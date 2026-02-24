import 'package:artist_management_system/core/error/failures.dart';
import 'package:artist_management_system/features/user/domain/usecases/user_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/mock_repositories.dart';
import '../../../helpers/test_fixtures.dart';

void main() {
  late MockUserRepository repo;

  setUp(() => repo = MockUserRepository());

  group('WatchUsers', () {
    late WatchUsers usecase;
    setUp(() => usecase = WatchUsers(repo));

    test('returns stream of users on success', () async {
      repo.stubWatch(Stream.value(Right([tUser()])));
      final result = await usecase().first;
      result.fold(
        (_) => fail('Should be Right'),
        (users) => expect(users, [tUser()]),
      );
    });

    test('returns stream of empty list when no users', () async {
      repo.stubWatch(Stream.value(const Right([])));
      final result = await usecase().first;
      result.fold(
        (_) => fail('Should be Right'),
        (users) => expect(users, isEmpty),
      );
    });

    test('returns failure on error', () async {
      repo.stubWatch(Stream.value(Left(const ServerFailure('error'))));
      final result = await usecase().first;
      expect(result.isLeft(), isTrue);
    });

    test('emits multiple updates', () async {
      repo.stubWatch(
        Stream.fromIterable([
          Right([tUser(id: 'u1')]),
          Right([tUser(id: 'u1'), tUser(id: 'u2')]),
        ]),
      );
      final results = await usecase().toList();
      expect(results.length, 2);
    });
  });

  group('UpdateUser', () {
    late UpdateUser usecase;
    setUp(() => usecase = UpdateUser(repo));

    test('returns Right(null) on success', () async {
      repo.stubUpdate(const Right(null));
      final result = await usecase(UpdateUserParams(tUser()));
      expect(result, const Right(null));
    });

    test('returns ServerFailure on error', () async {
      repo.stubUpdate(Left(const ServerFailure('Update failed')));
      final result = await usecase(UpdateUserParams(tUser()));
      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f.message, 'Update failed'),
        (_) => fail('Should be failure'),
      );
    });

    test('UpdateUserParams equality works', () {
      expect(UpdateUserParams(tUser()), equals(UpdateUserParams(tUser())));
    });

    test('UpdateUserParams with different users are not equal', () {
      expect(
        UpdateUserParams(tUser(id: 'a')),
        isNot(equals(UpdateUserParams(tUser(id: 'b')))),
      );
    });
  });

  group('DeleteUser', () {
    late DeleteUser usecase;
    setUp(() => usecase = DeleteUser(repo));

    test('returns Right(null) on success', () async {
      repo.stubDelete(const Right(null));
      final result = await usecase(const DeleteUserParams('user-1'));
      expect(result, const Right(null));
    });

    test('returns ServerFailure on error', () async {
      repo.stubDelete(Left(const ServerFailure('Delete failed')));
      final result = await usecase(const DeleteUserParams('user-1'));
      expect(result.isLeft(), isTrue);
    });

    test('DeleteUserParams equality works', () {
      expect(
        const DeleteUserParams('id-1'),
        equals(const DeleteUserParams('id-1')),
      );
    });

    test('DeleteUserParams with different ids are not equal', () {
      expect(
        const DeleteUserParams('id-1'),
        isNot(equals(const DeleteUserParams('id-2'))),
      );
    });
  });
}
