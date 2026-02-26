import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/error/exceptions.dart';
import '../models/song_model.dart';

abstract class SongRemoteDataSource {
  Stream<List<SongModel>> watchSongsForArtist(String artistId);
  Future<void> createSong(SongModel song, {File? videoFile});
  Future<void> updateSong(SongModel song, {File? videoFile});
  Future<void> deleteSong(String songId, {String? mp4Url});
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

  // ─── Watch ──────────────────────────────────────────────────────────────

  @override
  Stream<List<SongModel>> watchSongsForArtist(String artistId) {
    return _col
        .where('artist_id', isEqualTo: artistId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => SongModel.fromFirestore(d)).toList(),
        )
        .handleError((e) => throw ServerException(e.toString()));
  }

  // ─── Create ─────────────────────────────────────────────────────────────

  @override
  Future<void> createSong(SongModel song, {File? videoFile}) async {
    try {
      String? mp4Url;
      if (videoFile != null) {
        mp4Url = await _uploadVideo(song.id, videoFile);
      }
      final model = mp4Url != null
          ? SongModel.fromEntity(song.copyWith(mp4Url: mp4Url))
          : song;
      await _col.doc(song.id).set(model.toMap());
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to create song.');
    }
  }

  // ─── Update ─────────────────────────────────────────────────────────────

  @override
  Future<void> updateSong(SongModel song, {File? videoFile}) async {
    try {
      String? mp4Url = song.mp4Url;

      if (videoFile != null) {
        // Delete old video if exists
        if (mp4Url != null && mp4Url.isNotEmpty) {
          await _deleteVideoByUrl(mp4Url);
        }
        mp4Url = await _uploadVideo(song.id, videoFile);
      }

      final updated = SongModel.fromEntity(
        song.copyWith(mp4Url: mp4Url, updatedAt: DateTime.now()),
      );
      await _col.doc(song.id).update(updated.toMap());
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update song.');
    }
  }

  // ─── Delete ─────────────────────────────────────────────────────────────

  @override
  Future<void> deleteSong(String songId, {String? mp4Url}) async {
    try {
      // Delete video from Storage first if it exists
      if (mp4Url != null && mp4Url.isNotEmpty) {
        await _deleteVideoByUrl(mp4Url);
      }
      await _col.doc(songId).delete();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete song.');
    }
  }

  // ─── Storage helpers ─────────────────────────────────────────────────────

  /// Uploads MP4 to Firebase Storage and returns the download URL.
  Future<String> _uploadVideo(String songId, File file) async {
    final ref = storage.ref('songs/$songId.mp4');
    final task = await ref.putFile(
      file,
      SettableMetadata(contentType: 'video/mp4'),
    );
    return task.ref.getDownloadURL();
  }

  /// Deletes a video from Firebase Storage using its download URL.
  Future<void> _deleteVideoByUrl(String url) async {
    try {
      await storage.refFromURL(url).delete();
    } catch (_) {
      // Ignore — file may have already been deleted
    }
  }
}
