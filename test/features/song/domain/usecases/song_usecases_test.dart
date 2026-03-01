import 'package:artist_management_system/features/song/domain/entities/song.dart';
import 'package:artist_management_system/core/error/failures.dart';
import 'package:artist_management_system/features/song/domain/usecases/create_song_usecase.dart';
import 'package:artist_management_system/features/song/domain/usecases/delete_song_usecase.dart';
import 'package:artist_management_system/features/song/domain/usecases/update_song_usecase.dart';
import 'package:artist_management_system/features/song/domain/usecases/watch_song_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/song_helpers.dart';

class _ArtistIdCapturingRepo extends MockSongRepository {
  String? capturedArtistId;

  @override
  Stream<Either<Failure, List<SongEntity>>> watchSongsForArtist(
    String artistId,
  ) {
    capturedArtistId = artistId;
    return Stream.value(const Right([]));
  }
}

void main() {
  late MockSongRepository repo;

  setUp(() => repo = MockSongRepository());

  // ─── WatchSongsForArtist ──────────────────────────────────────────────────
  group('WatchSongsForArtist', () {
    late WatchSongsForArtist usecase;
    setUp(() => usecase = WatchSongsForArtist(repo));

    test('emits Right(songs) from repository stream', () async {
      repo.stubWatch(Stream.value(Right([tSong()])));
      final result = await usecase(tArtistId).first;
      result.fold(
        (_) => fail('Should be Right'),
        (songs) => expect(songs, [tSong()]),
      );
    });

    test('emits Right([]) when no songs exist', () async {
      repo.stubWatch(Stream.value(const Right([])));
      final result = await usecase(tArtistId).first;
      result.fold(
        (_) => fail('Should be Right'),
        (songs) => expect(songs, isEmpty),
      );
    });

    test('emits Left(failure) when repository fails', () async {
      repo.stubWatch(
        Stream.value(Left(const ServerFailure('Firestore error'))),
      );
      final result = await usecase(tArtistId).first;
      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f.message, 'Firestore error'),
        (_) => fail('Should be Left'),
      );
    });

    test('emits multiple events as stream updates', () async {
      repo.stubWatch(
        Stream.fromIterable([
          Right([tSong(id: 's1')]),
          Right([tSong(id: 's1'), tSong(id: 's2')]),
          Right([tSong(id: 's1'), tSong(id: 's2'), tSong(id: 's3')]),
        ]),
      );
      final results = await usecase(tArtistId).toList();
      expect(results.length, 3);
    });

    test('passes the exact artistId to the repository', () async {
      final capturingRepo = _ArtistIdCapturingRepo();
      final uc = WatchSongsForArtist(capturingRepo);
      await uc('specific-artist-id').first;
      expect(capturingRepo.capturedArtistId, 'specific-artist-id');
    });
  });

  // ─── CreateSong ───────────────────────────────────────────────────────────
  group('CreateSong', () {
    late CreateSong usecase;
    setUp(() => usecase = CreateSong(repo));

    test('returns Right(null) on success', () async {
      repo.stubCreate(const Right(null));
      final result = await usecase(CreateSongParams(song: tSong()));
      expect(result, const Right(null));
    });

    test('returns Left(ServerFailure) on error', () async {
      repo.stubCreate(Left(const ServerFailure('Failed to create song.')));
      final result = await usecase(CreateSongParams(song: tSong()));
      result.fold((f) {
        expect(f, isA<ServerFailure>());
        expect(f.message, 'Failed to create song.');
      }, (_) => fail('Should be Left'));
    });

    group('CreateSongParams', () {
      test('equal when song is the same', () {
        expect(
          CreateSongParams(song: tSong()),
          equals(CreateSongParams(song: tSong())),
        );
      });

      test('not equal when songs differ', () {
        expect(
          CreateSongParams(song: tSong(id: 'a')),
          isNot(equals(CreateSongParams(song: tSong(id: 'b')))),
        );
      });
    });
  });

  // ─── UpdateSong ───────────────────────────────────────────────────────────
  group('UpdateSong', () {
    late UpdateSong usecase;
    setUp(() => usecase = UpdateSong(repo));

    test('returns Right(null) on success', () async {
      repo.stubUpdate(const Right(null));
      final result = await usecase(UpdateSongParams(song: tSong()));
      expect(result, const Right(null));
    });

    test('returns Left(ServerFailure) on error', () async {
      repo.stubUpdate(Left(const ServerFailure('Failed to update song.')));
      final result = await usecase(UpdateSongParams(song: tSong()));
      result.fold(
        (f) => expect(f.message, 'Failed to update song.'),
        (_) => fail('Should be Left'),
      );
    });

    test('forwards updated song to repository', () async {
      SongEntity? captured;
      final capturingRepo = _CapturingRepo(
        onUpdate: (s) {
          captured = s;
          return const Right(null);
        },
      );
      final uc = UpdateSong(capturingRepo);
      final updated = tSong().copyWith(title: 'Updated Title');
      await uc(UpdateSongParams(song: updated));
      expect(captured?.title, 'Updated Title');
    });

    group('UpdateSongParams', () {
      test('equal when song is the same', () {
        expect(
          UpdateSongParams(song: tSong()),
          equals(UpdateSongParams(song: tSong())),
        );
      });

      test('not equal when songs differ', () {
        expect(
          UpdateSongParams(song: tSong(id: 'a')),
          isNot(equals(UpdateSongParams(song: tSong(id: 'b')))),
        );
      });
    });
  });

  // ─── DeleteSong ───────────────────────────────────────────────────────────
  group('DeleteSong', () {
    late DeleteSong usecase;
    setUp(() => usecase = DeleteSong(repo));

    test('returns Right(null) on success', () async {
      repo.stubDelete(const Right(null));
      final result = await usecase(const DeleteSongParams(songId: tSongId));
      expect(result, const Right(null));
    });

    test('returns Left(ServerFailure) on error', () async {
      repo.stubDelete(Left(const ServerFailure('Failed to delete song.')));
      final result = await usecase(const DeleteSongParams(songId: tSongId));
      result.fold(
        (f) => expect(f.message, 'Failed to delete song.'),
        (_) => fail('Should be Left'),
      );
    });

    group('DeleteSongParams', () {
      test('equal when songId matches', () {
        expect(
          const DeleteSongParams(songId: tSongId),
          equals(const DeleteSongParams(songId: tSongId)),
        );
      });

      test('not equal when songIds differ', () {
        expect(
          const DeleteSongParams(songId: 'a'),
          isNot(equals(const DeleteSongParams(songId: 'b'))),
        );
      });
    });
  });
}

class _CapturingRepo extends MockSongRepository {
  final Either<Failure, void> Function(SongEntity)? onUpdate;

  _CapturingRepo({this.onUpdate});

  @override
  Future<Either<Failure, void>> updateSong(SongEntity song) async =>
      onUpdate?.call(song) ?? const Right(null);
}
