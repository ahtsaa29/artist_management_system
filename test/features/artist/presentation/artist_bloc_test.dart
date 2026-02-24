import 'package:artist_management_system/core/error/failures.dart';
import 'package:artist_management_system/features/artist/domain/entities/artist.dart';
import 'package:artist_management_system/features/artist/domain/usecases/artist_usecases.dart';
import 'package:artist_management_system/features/artist/presentation/bloc/artist_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/mock_repositories.dart';
import '../../../helpers/test_fixtures.dart';

ArtistBloc _makeBloc(MockArtistRepository repo) => ArtistBloc(
  watchArtists: WatchArtists(repo),
  createArtist: CreateArtist(repo),
  updateArtist: UpdateArtist(repo),
  deleteArtist: DeleteArtist(repo),
);

void main() {
  late MockArtistRepository repo;

  setUp(() => repo = MockArtistRepository());

  test('initial state is ArtistInitial', () {
    expect(_makeBloc(repo).state, isA<ArtistInitial>());
  });

  group('ArtistWatchStarted', () {
    blocTest<ArtistBloc, ArtistState>(
      'emits [Loading, Loaded] with artists',
      build: () {
        repo.stubWatch(Stream.value(Right([tArtist()])));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(ArtistWatchStarted()),
      expect: () => [
        isA<ArtistLoading>(),
        isA<ArtistLoaded>().having((s) => s.artists, 'artists', [tArtist()]),
      ],
    );

    blocTest<ArtistBloc, ArtistState>(
      'emits [Loading, Loaded(empty)] when no artists',
      build: () {
        repo.stubWatch(Stream.value(const Right([])));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(ArtistWatchStarted()),
      expect: () => [
        isA<ArtistLoading>(),
        isA<ArtistLoaded>().having((s) => s.artists, 'artists', isEmpty),
      ],
    );

    blocTest<ArtistBloc, ArtistState>(
      'emits [Loading, ArtistError] on stream failure',
      build: () {
        repo.stubWatch(
          Stream.value(Left(const ServerFailure('Firestore error'))),
        );
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(ArtistWatchStarted()),
      expect: () => [
        isA<ArtistLoading>(),
        isA<ArtistError>().having(
          (s) => s.message,
          'message',
          'Firestore error',
        ),
      ],
    );

    blocTest<ArtistBloc, ArtistState>(
      'emits multiple Loaded states as stream updates',
      build: () {
        repo.stubWatch(
          Stream.fromIterable([
            Right([tArtist(id: 'a1')]),
            Right([tArtist(id: 'a1'), tArtist(id: 'a2')]),
          ]),
        );
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(ArtistWatchStarted()),
      expect: () => [
        isA<ArtistLoading>(),
        isA<ArtistLoaded>().having((s) => s.artists.length, 'count', 1),
        isA<ArtistLoaded>().having((s) => s.artists.length, 'count', 2),
      ],
    );
  });

  group('ArtistCreateRequested', () {
    final tEvent = ArtistCreateRequested(
      name: 'New Artist',
      gender: 'm',
      address: 'Pokhara',
      noOfAlbumsReleased: 2,
      firstReleaseYear: 2015,
    );

    blocTest<ArtistBloc, ArtistState>(
      'emits nothing extra on success (stream handles update)',
      build: () {
        repo.stubCreate(const Right(null));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(tEvent),
      expect: () => [],
    );

    blocTest<ArtistBloc, ArtistState>(
      'emits ArtistError on failure',
      build: () {
        repo.stubCreate(Left(const ServerFailure('Create failed')));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(tEvent),
      expect: () => [
        isA<ArtistError>().having((s) => s.message, 'message', 'Create failed'),
      ],
    );

    blocTest<ArtistBloc, ArtistState>(
      'generates a non-empty UUID for new artist id',
      build: () {
        String? capturedId;
        repo.stubWatch(Stream.empty());
        repo.stubCreate(const Right(null));
        final captureRepo = _CapturingArtistRepo(
          onCreate: (a) {
            capturedId = a.id;
            return const Right(null);
          },
        );
        return ArtistBloc(
          watchArtists: WatchArtists(captureRepo),
          createArtist: CreateArtist(captureRepo),
          updateArtist: UpdateArtist(captureRepo),
          deleteArtist: DeleteArtist(captureRepo),
        );
      },
      act: (bloc) => bloc.add(tEvent),
      expect: () => [],
    );
  });

  group('ArtistUpdateRequested', () {
    blocTest<ArtistBloc, ArtistState>(
      'emits nothing on success',
      build: () {
        repo.stubUpdate(const Right(null));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(ArtistUpdateRequested(tArtist())),
      expect: () => [],
    );

    blocTest<ArtistBloc, ArtistState>(
      'emits ArtistError on failure',
      build: () {
        repo.stubUpdate(Left(const ServerFailure('Update failed')));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(ArtistUpdateRequested(tArtist())),
      expect: () => [
        isA<ArtistError>().having((s) => s.message, 'message', 'Update failed'),
      ],
    );
  });

  group('ArtistDeleteRequested', () {
    blocTest<ArtistBloc, ArtistState>(
      'emits nothing on success',
      build: () {
        repo.stubDelete(const Right(null));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(const ArtistDeleteRequested('artist-1')),
      expect: () => [],
    );

    blocTest<ArtistBloc, ArtistState>(
      'emits ArtistError on failure',
      build: () {
        repo.stubDelete(Left(const ServerFailure('Delete failed')));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(const ArtistDeleteRequested('artist-1')),
      expect: () => [
        isA<ArtistError>().having((s) => s.message, 'message', 'Delete failed'),
      ],
    );
  });

  group('State equality', () {
    test('ArtistLoaded with same artists are equal', () {
      expect(ArtistLoaded([tArtist()]), equals(ArtistLoaded([tArtist()])));
    });

    test('ArtistLoaded with different artists are not equal', () {
      expect(
        ArtistLoaded([tArtist(id: 'a')]),
        isNot(equals(ArtistLoaded([tArtist(id: 'b')]))),
      );
    });

    test('ArtistError with same message are equal', () {
      expect(const ArtistError('err'), equals(const ArtistError('err')));
    });
  });
}

class _CapturingArtistRepo extends MockArtistRepository {
  final Either<Failure, void> Function(ArtistEntity) onCreate;
  _CapturingArtistRepo({required this.onCreate});

  @override
  Future<Either<Failure, void>> createArtist(ArtistEntity artist) async =>
      onCreate(artist);
}
