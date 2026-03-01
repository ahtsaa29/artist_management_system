import 'package:artist_management_system/features/song/data/datasources/song_remote_datasource.dart';
import 'package:artist_management_system/features/song/data/models/song_model.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/song_helpers.dart';

/// Seeds a song document into fake Firestore.
Future<void> _seedSong(FakeFirebaseFirestore fs, SongModel model) async {
  await fs.collection('songs').doc(model.id).set({...model.toMap()});
}

void main() {
  late FakeFirebaseFirestore fakeFs;
  late MockFirebaseStorage fakeStorage;
  late SongRemoteDataSourceImpl ds;

  setUp(() {
    fakeFs = FakeFirebaseFirestore();
    fakeStorage = MockFirebaseStorage();
    ds = SongRemoteDataSourceImpl(firestore: fakeFs, storage: fakeStorage);
  });

  // ─── watchSongsForArtist ──────────────────────────────────────────────────
  group('watchSongsForArtist', () {
    test('returns empty list when no songs exist for artist', () async {
      final songs = await ds.watchSongsForArtist(tArtistId).first;
      expect(songs, isEmpty);
    });

    test('returns songs belonging to the given artist', () async {
      await _seedSong(fakeFs, tSongModel());
      final songs = await ds.watchSongsForArtist(tArtistId).first;
      expect(songs.length, 1);
      expect(songs.first.artistId, tArtistId);
      expect(songs.first.title, 'Test Song');
    });

    test('does not return songs from a different artist', () async {
      await _seedSong(fakeFs, tSongModel());
      final songs = await ds.watchSongsForArtist('different-artist').first;
      expect(songs, isEmpty);
    });

    test('returns multiple songs for same artist', () async {
      await _seedSong(fakeFs, tSongModel());
      await _seedSong(
        fakeFs,
        SongModel(
          id: 'song-2',
          artistId: tArtistId,
          title: 'Song 2',
          albumName: 'Album 2',
          genre: 'jazz',
          createdAt: tNow,
          updatedAt: tNow,
        ),
      );
      final songs = await ds.watchSongsForArtist(tArtistId).first;
      expect(songs.length, 2);
    });

    test('returned songs are SongModel instances', () async {
      await _seedSong(fakeFs, tSongModel());
      final songs = await ds.watchSongsForArtist(tArtistId).first;
      expect(songs.first, isA<SongModel>());
    });
  });

  // ─── createSong ───────────────────────────────────────────────────────────
  group('createSong', () {
    test('writes song document to Firestore', () async {
      await ds.createSong(tSongModel());
      final doc = await fakeFs.collection('songs').doc(tSongId).get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['title'], 'Test Song');
    });

    test('writes correct artist_id to Firestore', () async {
      await ds.createSong(tSongModel());
      final doc = await fakeFs.collection('songs').doc(tSongId).get();
      expect(doc.data()!['artist_id'], tArtistId);
    });

    test('writes correct genre to Firestore', () async {
      await ds.createSong(tSongModel());
      final doc = await fakeFs.collection('songs').doc(tSongId).get();
      expect(doc.data()!['genre'], 'rock');
    });

    test('stores null mp4_url when no video', () async {
      await ds.createSong(tSongModel());
      final doc = await fakeFs.collection('songs').doc(tSongId).get();
      expect(doc.data()!['mp4_url'], isNull);
    });

    test('completes without throwing when videoFile is null', () async {
      expect(() => ds.createSong(tSongModel()), returnsNormally);
    });
  });

  // ─── updateSong ───────────────────────────────────────────────────────────
  group('updateSong', () {
    test('updates existing document in Firestore', () async {
      await _seedSong(fakeFs, tSongModel());
      final updatedModel = SongModel(
        id: tSongId,
        artistId: tArtistId,
        title: 'Updated Title',
        albumName: 'Updated Album',
        genre: 'jazz',
        createdAt: tNow,
        updatedAt: tNow,
      );
      await ds.updateSong(updatedModel);
      final doc = await fakeFs.collection('songs').doc(tSongId).get();
      expect(doc.data()!['title'], 'Updated Title');
      expect(doc.data()!['album_name'], 'Updated Album');
      expect(doc.data()!['genre'], 'jazz');
    });

    test('completes without throwing when videoFile is null', () async {
      await _seedSong(fakeFs, tSongModel());
      expect(() => ds.updateSong(tSongModel()), returnsNormally);
    });
  });

  // ─── deleteSong ───────────────────────────────────────────────────────────
  group('deleteSong', () {
    test('removes document from Firestore', () async {
      await _seedSong(fakeFs, tSongModel());
      await ds.deleteSong(tSongId);
      final doc = await fakeFs.collection('songs').doc(tSongId).get();
      expect(doc.exists, isFalse);
    });

    test('completes without error when no mp4Url provided', () async {
      await _seedSong(fakeFs, tSongModel());
      expect(() => ds.deleteSong(tSongId), returnsNormally);
    });

    test('completes without error when mp4Url provided', () async {
      await _seedSong(fakeFs, tSongModelWithVideo());
      expect(() => ds.deleteSong(tSongId), returnsNormally);
    });

    test('does not throw if song document does not exist', () async {
      expect(() => ds.deleteSong('non-existent-id'), returnsNormally);
    });
  });
}
