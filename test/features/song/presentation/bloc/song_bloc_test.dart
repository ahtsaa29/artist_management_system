import 'package:artist_management_system/features/song/domain/entities/song.dart';
import 'package:artist_management_system/core/error/failures.dart';
import 'package:artist_management_system/features/song/domain/usecases/create_song_usecase.dart';
import 'package:artist_management_system/features/song/domain/usecases/delete_song_usecase.dart';
import 'package:artist_management_system/features/song/domain/usecases/update_song_usecase.dart';
import 'package:artist_management_system/features/song/domain/usecases/watch_song_usecase.dart';
import 'package:artist_management_system/features/song/presentation/bloc/song_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/song_helpers.dart';

SongBloc _bloc(MockSongRepository repo) => SongBloc(
  watchSongsForArtist: WatchSongsForArtist(repo),
  createSong: CreateSong(repo),
  updateSong: UpdateSong(repo),
  deleteSong: DeleteSong(repo),
);

void main() {
  late MockSongRepository repo;

  setUp(() => repo = MockSongRepository());

  test('initial state is SongInitial', () {
    expect(_bloc(repo).state, isA<SongInitial>());
  });

  // ─── SongWatchStarted ─────────────────────────────────────────────────────
  group('SongWatchStarted', () {
    blocTest<SongBloc, SongState>(
      'emits [Loading, Loaded(songs)] on success',
      build: () {
        repo.stubWatch(Stream.value(Right([tSong()])));
        return _bloc(repo);
      },
      act: (b) => b.add(const SongWatchStarted(tArtistId)),
      expect: () => [
        isA<SongLoading>(),
        isA<SongLoaded>().having((s) => s.songs, 'songs', [tSong()]),
      ],
    );

    blocTest<SongBloc, SongState>(
      'emits [Loading, Loaded(empty)] when no songs',
      build: () {
        repo.stubWatch(Stream.value(const Right([])));
        return _bloc(repo);
      },
      act: (b) => b.add(const SongWatchStarted(tArtistId)),
      expect: () => [
        isA<SongLoading>(),
        isA<SongLoaded>().having((s) => s.songs, 'songs', isEmpty),
      ],
    );

    blocTest<SongBloc, SongState>(
      'emits [Loading, SongError] on stream failure',
      build: () {
        repo.stubWatch(
          Stream.value(Left(const ServerFailure('Firestore error'))),
        );
        return _bloc(repo);
      },
      act: (b) => b.add(const SongWatchStarted(tArtistId)),
      expect: () => [
        isA<SongLoading>(),
        isA<SongError>().having((s) => s.message, 'message', 'Firestore error'),
      ],
    );

    blocTest<SongBloc, SongState>(
      'emits multiple Loaded states as stream updates',
      build: () {
        repo.stubWatch(
          Stream.fromIterable([
            Right([tSong(id: 's1')]),
            Right([tSong(id: 's1'), tSong(id: 's2')]),
            Right([tSong(id: 's1'), tSong(id: 's2'), tSong(id: 's3')]),
          ]),
        );
        return _bloc(repo);
      },
      act: (b) => b.add(const SongWatchStarted(tArtistId)),
      expect: () => [
        isA<SongLoading>(),
        isA<SongLoaded>().having((s) => s.songs.length, 'count', 1),
        isA<SongLoaded>().having((s) => s.songs.length, 'count', 2),
        isA<SongLoaded>().having((s) => s.songs.length, 'count', 3),
      ],
    );
  });

  // ─── SongCreateRequested ──────────────────────────────────────────────────
  group('SongCreateRequested', () {
    final tCreateEvent = SongCreateRequested(
      artistId: tArtistId,
      title: 'New Song',
      albumName: 'New Album',
      genre: 'pop',
    );

    blocTest<SongBloc, SongState>(
      'emits nothing on success',
      build: () => _bloc(repo),
      act: (b) => b.add(tCreateEvent),
      expect: () => [],
    );

    blocTest<SongBloc, SongState>(
      'emits SongError on create failure',
      build: () {
        repo.stubCreate(Left(const ServerFailure('Failed to create song.')));
        return _bloc(repo);
      },
      act: (b) => b.add(tCreateEvent),
      expect: () => [
        isA<SongError>().having(
          (s) => s.message,
          'message',
          'Failed to create song.',
        ),
      ],
    );

    blocTest<SongBloc, SongState>(
      'created song uses a UUID as id (non-empty)',
      build: () {
        String? capturedId;
        final capturingRepo = _IdCapturingRepo(
          onCreate: (song) {
            capturedId = song.id;
            return const Right(null);
          },
        );
        addTearDown(() => expect(capturedId, isNotEmpty));
        return _bloc(capturingRepo);
      },
      act: (b) => b.add(tCreateEvent),
      expect: () => [],
    );
  });

  // ─── SongUpdateRequested ──────────────────────────────────────────────────
  group('SongUpdateRequested', () {
    blocTest<SongBloc, SongState>(
      'emits nothing on success',
      build: () => _bloc(repo),
      act: (b) => b.add(SongUpdateRequested(song: tSong())),
      expect: () => [],
    );

    blocTest<SongBloc, SongState>(
      'emits SongError on update failure',
      build: () {
        repo.stubUpdate(Left(const ServerFailure('Failed to update song.')));
        return _bloc(repo);
      },
      act: (b) => b.add(SongUpdateRequested(song: tSong())),
      expect: () => [
        isA<SongError>().having(
          (s) => s.message,
          'message',
          'Failed to update song.',
        ),
      ],
    );
  });

  // ─── SongDeleteRequested ──────────────────────────────────────────────────
  group('SongDeleteRequested', () {
    blocTest<SongBloc, SongState>(
      'emits nothing on success',
      build: () => _bloc(repo),
      act: (b) => b.add(const SongDeleteRequested(songId: tSongId)),
      expect: () => [],
    );

    blocTest<SongBloc, SongState>(
      'emits SongError on delete failure',
      build: () {
        repo.stubDelete(Left(const ServerFailure('Failed to delete song.')));
        return _bloc(repo);
      },
      act: (b) => b.add(const SongDeleteRequested(songId: tSongId)),
      expect: () => [
        isA<SongError>().having(
          (s) => s.message,
          'message',
          'Failed to delete song.',
        ),
      ],
    );
  });

  // ─── State equality ───────────────────────────────────────────────────────
  group('State equality', () {
    test('SongInitial instances are equal', () {
      expect(SongInitial(), equals(SongInitial()));
    });

    test('SongLoading instances are equal', () {
      expect(SongLoading(), equals(SongLoading()));
    });

    test('SongLoaded equal when same songs', () {
      expect(SongLoaded([tSong()]), equals(SongLoaded([tSong()])));
    });

    test('SongLoaded not equal with different songs', () {
      expect(
        SongLoaded([tSong(id: 'a')]),
        isNot(equals(SongLoaded([tSong(id: 'b')]))),
      );
    });

    test('SongError equal when same message', () {
      expect(const SongError('err'), equals(const SongError('err')));
    });

    test('SongError not equal with different messages', () {
      expect(const SongError('err1'), isNot(equals(const SongError('err2'))));
    });
  });
}

class _IdCapturingRepo extends MockSongRepository {
  final Either<Failure, void> Function(SongEntity)? onCreate;

  _IdCapturingRepo({this.onCreate});

  @override
  Future<Either<Failure, void>> createSong(SongEntity song) async =>
      onCreate?.call(song) ?? const Right(null);
}
