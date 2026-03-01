import 'package:artist_management_system/core/error/exceptions.dart';
import 'package:artist_management_system/features/song/data/models/song_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

abstract class SongRemoteDataSource {
  Stream<List<SongModel>> watchSongsForArtist(String artistId);
  Future<void> createSong(SongModel song);
  Future<void> updateSong(SongModel song);
  Future<void> deleteSong(String songId);
}

class SongRemoteDataSourceImpl implements SongRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  static const _songs = 'songs';

  const SongRemoteDataSourceImpl({
    required this.firestore,
    required this.storage,
  });

  CollectionReference get _col => firestore.collection(_songs);

  @override
  Stream<List<SongModel>> watchSongsForArtist(String artistId) {
    return _col
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => SongModel.fromFirestore(d))
              .where((s) => s.artistId == artistId)
              .toList(),
        )
        .handleError((e) {
          throw ServerException(e.toString());
        });
  }

  @override
  Future<void> createSong(SongModel song) async {
    try {
      await _col.doc(song.id).set(song.toMap());
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to create song.');
    }
  }

  @override
  Future<void> updateSong(SongModel song) async {
    try {
      final updated = SongModel.fromEntity(
        song.copyWith(updatedAt: DateTime.now()),
      );
      await _col.doc(song.id).update(updated.toMap());
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update song.');
    }
  }

  @override
  Future<void> deleteSong(String songId) async {
    try {
      await _col.doc(songId).delete();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete song.');
    }
  }
}
