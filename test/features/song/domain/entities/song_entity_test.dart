import 'package:artist_management_system/features/song/domain/entities/song.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/song_helpers.dart';

void main() {
  group('SongEntity', () {
    // ─── hasVideo ──────────────────────────────────────────────────────────
    group('hasVideo', () {
      test('returns false when mp4Url is null', () {
        expect(tSong().hasVideo, isFalse);
      });

      test('returns false when mp4Url is empty string', () {
        expect(tSong(mp4Url: '').hasVideo, isFalse);
      });

      test('returns true when mp4Url is a non-empty URL', () {
        expect(tSongWithVideo().hasVideo, isTrue);
      });
    });

    // ─── copyWith ──────────────────────────────────────────────────────────
    group('copyWith', () {
      test('returns identical entity when no args supplied', () {
        expect(tSong().copyWith(), equals(tSong()));
      });

      test('overrides only title and genre', () {
        final updated = tSong().copyWith(title: 'New', genre: 'jazz');
        expect(updated.title, 'New');
        expect(updated.genre, 'jazz');
        expect(updated.id, tSong().id);
        expect(updated.artistId, tSong().artistId);
        expect(updated.albumName, tSong().albumName);
      });

      test('can set mp4Url via copyWith', () {
        final updated = tSong().copyWith(mp4Url: tVideoUrl);
        expect(updated.hasVideo, isTrue);
        expect(updated.mp4Url, tVideoUrl);
      });

      test('can clear mp4Url with empty string', () {
        final updated = tSongWithVideo().copyWith(mp4Url: '');
        expect(updated.hasVideo, isFalse);
      });

      test('can update artistId', () {
        final updated = tSong().copyWith(artistId: 'artist-99');
        expect(updated.artistId, 'artist-99');
      });

      test('can update albumName', () {
        final updated = tSong().copyWith(albumName: 'Greatest Hits');
        expect(updated.albumName, 'Greatest Hits');
      });

      test('can update createdAt', () {
        final newDate = DateTime(2025);
        final updated = tSong().copyWith(createdAt: newDate);
        expect(updated.createdAt, newDate);
      });
    });

    // ─── Equatable props ───────────────────────────────────────────────────
    group('Equatable', () {
      test('same values are equal', () {
        expect(tSong(), equals(tSong()));
      });

      test('different ids are not equal', () {
        expect(tSong(id: 'a'), isNot(equals(tSong(id: 'b'))));
      });

      test('different artistIds are not equal', () {
        expect(tSong(artistId: 'a1'), isNot(equals(tSong(artistId: 'a2'))));
      });

      test('different titles are not equal', () {
        expect(tSong(title: 'A'), isNot(equals(tSong(title: 'B'))));
      });

      test('different albumNames are not equal', () {
        expect(
          tSong(albumName: 'Album A'),
          isNot(equals(tSong(albumName: 'Album B'))),
        );
      });

      test('different genres are not equal', () {
        expect(tSong(genre: 'rock'), isNot(equals(tSong(genre: 'jazz'))));
      });

      test('different mp4Urls are not equal', () {
        expect(tSong(mp4Url: 'url-a'), isNot(equals(tSong(mp4Url: 'url-b'))));
      });

      test('song with video and without video are not equal', () {
        expect(tSong(), isNot(equals(tSongWithVideo())));
      });

      test(
        'createdAt and updatedAt are NOT in props — do not affect equality',
        () {
          final s1 = SongEntity(
            id: 'x',
            artistId: 'a',
            title: 't',
            albumName: 'al',
            genre: 'g',
            createdAt: DateTime(2020),
            updatedAt: DateTime(2020),
          );
          final s2 = SongEntity(
            id: 'x',
            artistId: 'a',
            title: 't',
            albumName: 'al',
            genre: 'g',
            createdAt: DateTime(2099),
            updatedAt: DateTime(2099),
          );
          expect(s1, equals(s2));
        },
      );

      test('props list contains correct fields', () {
        final song = tSong();
        expect(song.props, [
          song.id,
          song.artistId,
          song.title,
          song.albumName,
          song.genre,
          song.mp4Url,
        ]);
      });
    });
  });
}
