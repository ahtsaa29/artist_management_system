import 'package:artist_management_system/core/error/exceptions.dart';
import 'package:artist_management_system/core/error/failures.dart';
import 'package:artist_management_system/features/song/data/models/song_model.dart';
import 'package:artist_management_system/features/song/data/repositories/song_repository_impl.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/song_helpers.dart';

void main() {
  late MockSongRemoteDataSource ds;
  late SongRepositoryImpl repo;

  setUp(() {
    ds = MockSongRemoteDataSource();
    repo = SongRepositoryImpl(remoteDataSource: ds);
  });

  group('watchSongsForArtist', () {
    test('returns Right(songs) when datasource emits models', () async {
      ds.stubWatch(Stream.value([tSongModel()]));
      final result = await repo.watchSongsForArtist(tArtistId).first;
      result.fold((_) => fail('Should be Right'), (songs) {
        expect(songs.length, 1);
        expect(songs.first.id, tSongId);
        expect(songs.first.title, 'Test Song');
      });
    });

    test('returns Right([]) when datasource emits empty list', () async {
      ds.stubWatch(Stream.value([]));
      final result = await repo.watchSongsForArtist(tArtistId).first;
      result.fold(
        (_) => fail('Should be Right'),
        (songs) => expect(songs, isEmpty),
      );
    });

    test('returns Right with songs that have video', () async {
      ds.stubWatch(Stream.value([tSongModelWithVideo()]));
      final result = await repo.watchSongsForArtist(tArtistId).first;
      result.fold(
        (_) => fail('Should be Right'),
        (songs) => expect(songs.first.hasVideo, isTrue),
      );
    });

    test('emits multiple updates as stream progresses', () async {
      ds.stubWatch(
        Stream.fromIterable([
          [tSongModel()],
          [tSongModel(), tSongModel(mp4Url: tVideoUrl)],
          <SongModel>[],
        ]),
      );
      final results = await repo.watchSongsForArtist(tArtistId).toList();
      expect(results.length, 3);
      results[0].fold((_) => fail(''), (s) => expect(s.length, 1));
      results[1].fold((_) => fail(''), (s) => expect(s.length, 2));
      results[2].fold((_) => fail(''), (s) => expect(s, isEmpty));
    });
  });

  group('createSong', () {
    test('returns Right(null) on success', () async {
      final result = await repo.createSong(tSong());
      expect(result, const Right(null));
    });

    test('maps ServerException → Left(ServerFailure)', () async {
      ds.stubCreateError(const ServerException('Failed to create song.'));
      final result = await repo.createSong(tSong());
      result.fold((f) {
        expect(f, isA<ServerFailure>());
        expect(f.message, 'Failed to create song.');
      }, (_) => fail('Should be Left'));
    });

    test('preserves error message from datasource', () async {
      ds.stubCreateError(const ServerException('Custom create error'));
      final result = await repo.createSong(tSong());
      result.fold(
        (f) => expect(f.message, 'Custom create error'),
        (_) => fail('Should be Left'),
      );
    });
  });

  group('updateSong', () {
    test('returns Right(null) on success', () async {
      final result = await repo.updateSong(tSong());
      expect(result, const Right(null));
    });

    test('maps ServerException → Left(ServerFailure)', () async {
      ds.stubUpdateError(const ServerException('Failed to update song.'));
      final result = await repo.updateSong(tSong());
      result.fold((f) {
        expect(f, isA<ServerFailure>());
        expect(f.message, 'Failed to update song.');
      }, (_) => fail('Should be Left'));
    });

    test('preserves error message from datasource', () async {
      ds.stubUpdateError(const ServerException('Custom update error'));
      final result = await repo.updateSong(tSong());
      result.fold(
        (f) => expect(f.message, 'Custom update error'),
        (_) => fail('Should be Left'),
      );
    });
  });

  group('deleteSong', () {
    test('returns Right(null) on success', () async {
      final result = await repo.deleteSong(tSongId);
      expect(result, const Right(null));
    });

    test('maps ServerException → Left(ServerFailure)', () async {
      ds.stubDeleteError(const ServerException('Failed to delete song.'));
      final result = await repo.deleteSong(tSongId);
      result.fold((f) {
        expect(f, isA<ServerFailure>());
        expect(f.message, 'Failed to delete song.');
      }, (_) => fail('Should be Left'));
    });

    test('preserves error message from datasource', () async {
      ds.stubDeleteError(const ServerException('Custom delete error'));
      final result = await repo.deleteSong(tSongId);
      result.fold(
        (f) => expect(f.message, 'Custom delete error'),
        (_) => fail('Should be Left'),
      );
    });
  });
}
