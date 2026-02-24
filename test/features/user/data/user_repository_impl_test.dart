import 'package:artist_management_system/core/error/exceptions.dart';
import 'package:artist_management_system/core/error/failures.dart';
import 'package:artist_management_system/features/user/data/repositories/user_repository_impl.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/mock_datasources.dart';
import '../../../helpers/test_fixtures.dart';
import '../../../helpers/user_model_fixture.dart';

void main() {
  late MockUserRemoteDataSource ds;
  late UserRepositoryImpl repo;

  setUp(() {
    ds = MockUserRemoteDataSource();
    repo = UserRepositoryImpl(remoteDataSource: ds);
  });

  group('watchUsers', () {
    test('returns stream of Right(users) on success', () async {
      ds.stubWatch(Stream.value([tUserModel()]));
      final result = await repo.watchUsers().first;
      result.fold(
        (_) => fail('Should be Right'),
        (users) => expect(users.length, 1),
      );
    });

    test('returns Right([]) when no users', () async {
      ds.stubWatch(Stream.value([]));
      final result = await repo.watchUsers().first;
      result.fold(
        (_) => fail('Should be Right'),
        (users) => expect(users, isEmpty),
      );
    });

    test('emits multiple stream updates', () async {
      ds.stubWatch(
        Stream.fromIterable([
          [tUserModel()],
          [tUserModel(), tSuperAdminModel()],
        ]),
      );
      final results = await repo.watchUsers().toList();
      expect(results.length, 2);
    });
  });

  group('updateUser', () {
    test('returns Right(null) on success', () async {
      final result = await repo.updateUser(tUser());
      expect(result, const Right(null));
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      ds.stubUpdateError(const ServerException('Failed to update user.'));
      final result = await repo.updateUser(tUser());
      result.fold((f) {
        expect(f, isA<ServerFailure>());
        expect(f.message, 'Failed to update user.');
      }, (_) => fail('Should be Left'));
    });
  });

  group('deleteUser', () {
    test('returns Right(null) on success', () async {
      final result = await repo.deleteUser('user-1');
      expect(result, const Right(null));
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      ds.stubDeleteError(const ServerException('Failed to delete user.'));
      final result = await repo.deleteUser('user-1');
      result.fold((f) {
        expect(f, isA<ServerFailure>());
        expect(f.message, 'Failed to delete user.');
      }, (_) => fail('Should be Left'));
    });
  });
}
