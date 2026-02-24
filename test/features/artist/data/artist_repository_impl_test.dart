import 'package:artist_management_system/core/error/exceptions.dart';
import 'package:artist_management_system/core/error/failures.dart';
import 'package:artist_management_system/features/artist/data/repositories/artist_repository_impl.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/mock_datasources.dart';
import '../../../helpers/test_fixtures.dart';
import '../../../helpers/user_model_fixture.dart';

void main() {
  late MockArtistRemoteDataSource ds;
  late ArtistRepositoryImpl repo;

  setUp(() {
    ds = MockArtistRemoteDataSource();
    repo = ArtistRepositoryImpl(remoteDataSource: ds);
  });

  group('watchArtists', () {
    test('returns stream of Right(artists) on success', () async {
      ds.stubWatch(Stream.value([tArtistModel()]));
      final result = await repo.watchArtists().first;
      result.fold(
        (_) => fail('Should be Right'),
        (artists) => expect(artists.length, 1),
      );
    });

    test('returns stream of Right([]) when empty', () async {
      ds.stubWatch(Stream.value([]));
      final result = await repo.watchArtists().first;
      result.fold(
        (_) => fail('Should be Right'),
        (artists) => expect(artists, isEmpty),
      );
    });

    test('emits multiple updates', () async {
      ds.stubWatch(
        Stream.fromIterable([
          [tArtistModel()],
          [tArtistModel(), tArtistModel()],
        ]),
      );
      final results = await repo.watchArtists().toList();
      expect(results.length, 2);
    });
  });

  group('createArtist', () {
    test('returns Right(null) on success', () async {
      final result = await repo.createArtist(tArtist());
      expect(result, const Right(null));
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      ds.stubCreateError(const ServerException('Failed to create artist.'));
      final result = await repo.createArtist(tArtist());
      result.fold((f) {
        expect(f, isA<ServerFailure>());
        expect(f.message, 'Failed to create artist.');
      }, (_) => fail('Should be Left'));
    });
  });

  group('updateArtist', () {
    test('returns Right(null) on success', () async {
      final result = await repo.updateArtist(tArtist());
      expect(result, const Right(null));
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      ds.stubUpdateError(const ServerException('Failed to update artist.'));
      final result = await repo.updateArtist(tArtist());
      result.fold((f) {
        expect(f, isA<ServerFailure>());
        expect(f.message, 'Failed to update artist.');
      }, (_) => fail('Should be Left'));
    });
  });

  group('deleteArtist', () {
    test('returns Right(null) on success', () async {
      final result = await repo.deleteArtist('artist-1');
      expect(result, const Right(null));
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      ds.stubDeleteError(const ServerException('Failed to delete artist.'));
      final result = await repo.deleteArtist('artist-1');
      result.fold((f) {
        expect(f, isA<ServerFailure>());
        expect(f.message, 'Failed to delete artist.');
      }, (_) => fail('Should be Left'));
    });
  });
}
