import 'package:artist_management_system/features/song/data/models/song_model.dart';
import 'package:artist_management_system/features/song/domain/entities/song.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/song_helpers.dart';

// ─── Fake Firestore helpers ───────────────────────────────────────────────────

Future<DocumentSnapshot> _insertAndFetch(
  FakeFirebaseFirestore fs,
  String id,
  Map<String, dynamic> data,
) async {
  await fs.collection('songs').doc(id).set(data);
  return fs.collection('songs').doc(id).get();
}

Map<String, dynamic> _baseData({String? mp4Url}) => {
  'artist_id': tArtistId,
  'title': 'Test Song',
  'album_name': 'Test Album',
  'genre': 'rock',
  'mp4_url': mp4Url,
  'created_at': Timestamp.fromDate(tNow),
  'updated_at': Timestamp.fromDate(tNow),
};

void main() {
  late FakeFirebaseFirestore fs;

  setUp(() => fs = FakeFirebaseFirestore());

  // ─── fromFirestore ────────────────────────────────────────────────────────
  group('SongModel.fromFirestore', () {
    test('maps all fields correctly', () async {
      final doc = await _insertAndFetch(fs, tSongId, _baseData());
      final model = SongModel.fromFirestore(doc);

      expect(model.id, tSongId);
      expect(model.artistId, tArtistId);
      expect(model.title, 'Test Song');
      expect(model.albumName, 'Test Album');
      expect(model.genre, 'rock');
      expect(model.mp4Url, isNull);
      expect(model.createdAt, tNow);
      expect(model.updatedAt, tNow);
    });

    test('maps mp4Url when present', () async {
      final doc = await _insertAndFetch(
        fs,
        tSongId,
        _baseData(mp4Url: tVideoUrl),
      );
      final model = SongModel.fromFirestore(doc);
      expect(model.mp4Url, tVideoUrl);
      expect(model.hasVideo, isTrue);
    });

    test('mp4Url is null when not stored', () async {
      final doc = await _insertAndFetch(fs, tSongId, _baseData());
      final model = SongModel.fromFirestore(doc);
      expect(model.mp4Url, isNull);
      expect(model.hasVideo, isFalse);
    });

    test('defaults missing string fields to empty string', () async {
      final doc = await _insertAndFetch(fs, 's2', {
        'created_at': Timestamp.fromDate(tNow),
        'updated_at': Timestamp.fromDate(tNow),
      });
      final model = SongModel.fromFirestore(doc);

      expect(model.artistId, '');
      expect(model.title, '');
      expect(model.albumName, '');
      expect(model.genre, '');
      expect(model.mp4Url, isNull);
    });

    test('doc.id is used as entity id', () async {
      final doc = await _insertAndFetch(fs, 'custom-id-123', _baseData());
      final model = SongModel.fromFirestore(doc);
      expect(model.id, 'custom-id-123');
    });

    test('is an instance of SongEntity (inheritance correct)', () async {
      final doc = await _insertAndFetch(fs, tSongId, _baseData());
      expect(SongModel.fromFirestore(doc), isA<SongEntity>());
    });
  });

  // ─── fromEntity ───────────────────────────────────────────────────────────
  group('SongModel.fromEntity', () {
    test('copies all fields from entity', () {
      final entity = tSong();
      final model = SongModel.fromEntity(entity);

      expect(model.id, entity.id);
      expect(model.artistId, entity.artistId);
      expect(model.title, entity.title);
      expect(model.albumName, entity.albumName);
      expect(model.genre, entity.genre);
      expect(model.mp4Url, entity.mp4Url);
      expect(model.createdAt, entity.createdAt);
      expect(model.updatedAt, entity.updatedAt);
    });

    test('preserves mp4Url when entity has video', () {
      final model = SongModel.fromEntity(tSongWithVideo());
      expect(model.mp4Url, tVideoUrl);
      expect(model.hasVideo, isTrue);
    });

    test('preserves null mp4Url', () {
      final model = SongModel.fromEntity(tSong());
      expect(model.mp4Url, isNull);
    });

    test('result is an instance of SongEntity', () {
      expect(SongModel.fromEntity(tSong()), isA<SongEntity>());
    });
  });

  // ─── toMap ────────────────────────────────────────────────────────────────
  group('SongModel.toMap', () {
    test('contains all required keys', () {
      final map = tSongModel().toMap();

      expect(map.containsKey('artist_id'), isTrue);
      expect(map.containsKey('title'), isTrue);
      expect(map.containsKey('album_name'), isTrue);
      expect(map.containsKey('genre'), isTrue);
      expect(map.containsKey('mp4_url'), isTrue);
      expect(map.containsKey('created_at'), isTrue);
      expect(map.containsKey('updated_at'), isTrue);
    });

    test('maps string values correctly', () {
      final map = tSongModel().toMap();

      expect(map['artist_id'], tArtistId);
      expect(map['title'], 'Test Song');
      expect(map['album_name'], 'Test Album');
      expect(map['genre'], 'rock');
    });

    test('mp4_url is null when no video', () {
      expect(tSongModel().toMap()['mp4_url'], isNull);
    });

    test('mp4_url is set when video exists', () {
      expect(tSongModelWithVideo().toMap()['mp4_url'], tVideoUrl);
    });

    test('timestamps are Firestore Timestamp type', () {
      final map = tSongModel().toMap();
      expect(map['created_at'], isA<Timestamp>());
      expect(map['updated_at'], isA<Timestamp>());
    });

    test('Timestamp values match original dates', () {
      final map = tSongModel().toMap();
      expect((map['created_at'] as Timestamp).toDate(), tNow);
      expect((map['updated_at'] as Timestamp).toDate(), tNow);
    });

    // ─── Roundtrip ──────────────────────────────────────────────────────────
    group('roundtrip (fromEntity → toMap → fromFirestore)', () {
      test('preserves all fields without video', () async {
        final model = tSongModel();
        await fs.collection('songs').doc(model.id).set(model.toMap());
        final doc = await fs.collection('songs').doc(model.id).get();
        final restored = SongModel.fromFirestore(doc);

        expect(restored.id, model.id);
        expect(restored.artistId, model.artistId);
        expect(restored.title, model.title);
        expect(restored.albumName, model.albumName);
        expect(restored.genre, model.genre);
        expect(restored.mp4Url, isNull);
      });

      test('preserves mp4Url with video', () async {
        final model = tSongModelWithVideo();
        await fs.collection('songs').doc(model.id).set(model.toMap());
        final doc = await fs.collection('songs').doc(model.id).get();
        final restored = SongModel.fromFirestore(doc);

        expect(restored.mp4Url, tVideoUrl);
        expect(restored.hasVideo, isTrue);
      });
    });
  });
}
