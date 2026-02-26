import 'dart:io';
import 'package:artist_management_system/features/song/domain/entities/song.dart';
import 'package:artist_management_system/core/error/failures.dart';
import 'package:artist_management_system/features/song/domain/usecases/song_usecases.dart';
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

  // ─── Initial state ────────────────────────────────────────────────────────
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

    blocTest<SongBloc, SongState>(
      'Loaded state contains songs with correct data',
      build: () {
        repo.stubWatch(Stream.value(Right([tSongWithVideo()])));
        return _bloc(repo);
      },
      act: (b) => b.add(const SongWatchStarted(tArtistId)),
      expect: () => [
        isA<SongLoading>(),
        isA<SongLoaded>()
            .having((s) => s.songs.first.hasVideo, 'hasVideo', isTrue)
            .having((s) => s.songs.first.mp4Url, 'mp4Url', tVideoUrl),
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
      'emits nothing on success without video (stream handles UI update)',
      build: () => _bloc(repo),
      act: (b) => b.add(tCreateEvent),
      expect: () => [],
    );

    blocTest<SongBloc, SongState>(
      'emits [SongUploading(0.0)] when videoFile is provided',
      build: () => _bloc(repo),
      act: (b) => b.add(
        SongCreateRequested(
          artistId: tArtistId,
          title: 'Song With Video',
          albumName: 'Album',
          genre: 'rock',
          videoFile: File('/tmp/test.mp4'),
        ),
      ),
      expect: () => [
        isA<SongUploading>().having((s) => s.progress, 'progress', 0.0),
      ],
    );

    blocTest<SongBloc, SongState>(
      'emits SongError on create failure without video',
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
      'emits [SongUploading, SongError] when video provided but create fails',
      build: () {
        repo.stubCreate(Left(const ServerFailure('Storage error')));
        return _bloc(repo);
      },
      act: (b) => b.add(
        SongCreateRequested(
          artistId: tArtistId,
          title: 'Song',
          albumName: 'Album',
          genre: 'rock',
          videoFile: File('/tmp/test.mp4'),
        ),
      ),
      expect: () => [
        isA<SongUploading>(),
        isA<SongError>().having((s) => s.message, 'message', 'Storage error'),
      ],
    );

    blocTest<SongBloc, SongState>(
      'created song uses a UUID as id (non-empty)',
      build: () {
        String? capturedId;
        final capturingRepo = _IdCapturingRepo(
          onCreate: (song, _) {
            capturedId = song.id;
            return const Right(null);
          },
        );
        // ignore: unused_local_variable
        final b = _bloc(capturingRepo);
        addTearDown(() => expect(capturedId, isNotEmpty));
        return b;
      },
      act: (b) => b.add(tCreateEvent),
      expect: () => [],
    );
  });

  // ─── SongUpdateRequested ──────────────────────────────────────────────────
  group('SongUpdateRequested', () {
    blocTest<SongBloc, SongState>(
      'emits nothing on success without video',
      build: () => _bloc(repo),
      act: (b) => b.add(SongUpdateRequested(song: tSong())),
      expect: () => [],
    );

    blocTest<SongBloc, SongState>(
      'emits [SongUploading(0.0)] when videoFile is provided',
      build: () => _bloc(repo),
      act: (b) => b.add(
        SongUpdateRequested(
          song: tSongWithVideo(),
          videoFile: File('/tmp/new.mp4'),
        ),
      ),
      expect: () => [
        isA<SongUploading>().having((s) => s.progress, 'progress', 0.0),
      ],
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

    blocTest<SongBloc, SongState>(
      'emits [SongUploading, SongError] when video + update fails',
      build: () {
        repo.stubUpdate(Left(const ServerFailure('Storage error')));
        return _bloc(repo);
      },
      act: (b) => b.add(
        SongUpdateRequested(song: tSong(), videoFile: File('/tmp/replace.mp4')),
      ),
      expect: () => [isA<SongUploading>(), isA<SongError>()],
    );
  });

  // ─── SongDeleteRequested ──────────────────────────────────────────────────
  group('SongDeleteRequested', () {
    blocTest<SongBloc, SongState>(
      'emits nothing on success without video',
      build: () => _bloc(repo),
      act: (b) => b.add(const SongDeleteRequested(songId: tSongId)),
      expect: () => [],
    );

    blocTest<SongBloc, SongState>(
      'emits nothing on success with mp4Url (storage cleaned in datasource)',
      build: () => _bloc(repo),
      act: (b) =>
          b.add(const SongDeleteRequested(songId: tSongId, mp4Url: tVideoUrl)),
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

    blocTest<SongBloc, SongState>(
      'passes mp4Url to delete usecase',
      build: () {
        String? capturedUrl;
        final capturingRepo = _IdCapturingRepo(
          onDelete: (_, url) {
            capturedUrl = url;
            return const Right(null);
          },
        );
        addTearDown(() => expect(capturedUrl, tVideoUrl));
        return _bloc(capturingRepo);
      },
      act: (b) =>
          b.add(const SongDeleteRequested(songId: tSongId, mp4Url: tVideoUrl)),
      expect: () => [],
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

    test('SongUploading equal when same progress', () {
      expect(const SongUploading(0.5), equals(const SongUploading(0.5)));
    });

    test('SongUploading not equal with different progress', () {
      expect(const SongUploading(0.0), isNot(equals(const SongUploading(1.0))));
    });
  });
}

// ─── Capturing repo for argument verification ─────────────────────────────────

class _IdCapturingRepo extends MockSongRepository {
  final Either<Failure, void> Function(SongEntity, File?)? onCreate;
  final Either<Failure, void> Function(String, String?)? onDelete;

  _IdCapturingRepo({this.onCreate, this.onDelete});

  @override
  Future<Either<Failure, void>> createSong(
    SongEntity song, {
    File? videoFile,
  }) async => onCreate?.call(song, videoFile) ?? const Right(null);

  @override
  Future<Either<Failure, void>> deleteSong(
    String songId, {
    String? mp4Url,
  }) async => onDelete?.call(songId, mp4Url) ?? const Right(null);
}
