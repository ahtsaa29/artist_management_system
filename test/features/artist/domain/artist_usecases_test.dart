import 'package:artist_management_system/core/error/failures.dart';
import 'package:artist_management_system/features/artist/domain/usecases/artist_usecases.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/mock_repositories.dart';
import '../../../helpers/test_fixtures.dart';

void main() {
  late MockArtistRepository repo;

  setUp(() => repo = MockArtistRepository());

  group('WatchArtists', () {
    late WatchArtists usecase;
    setUp(() => usecase = WatchArtists(repo));

    test('returns stream of artists on success', () async {
      repo.stubWatch(Stream.value(Right([tArtist()])));
      final result = await usecase().first;
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be Right'),
        (artists) => expect(artists, [tArtist()]),
      );
    });

    test('returns stream of empty list when no artists', () async {
      repo.stubWatch(Stream.value(const Right([])));
      final result = await usecase().first;
      result.fold(
        (_) => fail('Should be Right'),
        (artists) => expect(artists, isEmpty),
      );
    });

    test('returns failure on stream error', () async {
      repo.stubWatch(
        Stream.value(Left(const ServerFailure('Firestore error'))),
      );
      final result = await usecase().first;
      expect(result.isLeft(), isTrue);
    });

    test('emits multiple values over time', () async {
      final first = [tArtist(id: 'a1')];
      final second = [tArtist(id: 'a1'), tArtist(id: 'a2')];
      repo.stubWatch(Stream.fromIterable([Right(first), Right(second)]));
      final results = await usecase().toList();
      expect(results.length, 2);
    });
  });

  group('CreateArtist', () {
    late CreateArtist usecase;
    setUp(() => usecase = CreateArtist(repo));

    test('returns Right(null) on success', () async {
      repo.stubCreate(const Right(null));
      final result = await usecase(CreateArtistParams(tArtist()));
      expect(result, const Right(null));
    });

    test('returns ServerFailure on error', () async {
      repo.stubCreate(Left(const ServerFailure('Create failed')));
      final result = await usecase(CreateArtistParams(tArtist()));
      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f.message, 'Create failed'),
        (_) => fail('Should be failure'),
      );
    });

    test('CreateArtistParams equality works', () {
      final p1 = CreateArtistParams(tArtist());
      final p2 = CreateArtistParams(tArtist());
      expect(p1, equals(p2));
    });
  });

  group('UpdateArtist', () {
    late UpdateArtist usecase;
    setUp(() => usecase = UpdateArtist(repo));

    test('returns Right(null) on success', () async {
      repo.stubUpdate(const Right(null));
      final result = await usecase(UpdateArtistParams(tArtist()));
      expect(result, const Right(null));
    });

    test('returns ServerFailure on error', () async {
      repo.stubUpdate(Left(const ServerFailure('Update failed')));
      final result = await usecase(UpdateArtistParams(tArtist()));
      expect(result.isLeft(), isTrue);
    });

    test('UpdateArtistParams equality works', () {
      expect(
        UpdateArtistParams(tArtist()),
        equals(UpdateArtistParams(tArtist())),
      );
    });
  });

  group('DeleteArtist', () {
    late DeleteArtist usecase;
    setUp(() => usecase = DeleteArtist(repo));

    test('returns Right(null) on success', () async {
      repo.stubDelete(const Right(null));
      final result = await usecase(const DeleteArtistParams('artist-1'));
      expect(result, const Right(null));
    });

    test('returns ServerFailure on error', () async {
      repo.stubDelete(Left(const ServerFailure('Delete failed')));
      final result = await usecase(const DeleteArtistParams('artist-1'));
      expect(result.isLeft(), isTrue);
    });

    test('DeleteArtistParams equality works', () {
      expect(
        const DeleteArtistParams('id-1'),
        equals(const DeleteArtistParams('id-1')),
      );
    });

    test('DeleteArtistParams with different ids are not equal', () {
      expect(
        const DeleteArtistParams('id-1'),
        isNot(equals(const DeleteArtistParams('id-2'))),
      );
    });
  });
}
