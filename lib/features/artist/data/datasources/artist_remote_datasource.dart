import 'package:artist_management_system/core/error/exceptions.dart';
import 'package:artist_management_system/features/artist/data/models/artist_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ArtistRemoteDataSource {
  Stream<List<ArtistModel>> watchArtists();
  Future<void> createArtist(ArtistModel artist);
  Future<void> updateArtist(ArtistModel artist);
  Future<void> deleteArtist(String artistId);
}

class ArtistRemoteDataSourceImpl implements ArtistRemoteDataSource {
  final FirebaseFirestore firestore;
  static const _artists = 'artists';
  static const _songs = 'songs';

  const ArtistRemoteDataSourceImpl({required this.firestore});

  CollectionReference get _col => firestore.collection(_artists);

  @override
  Stream<List<ArtistModel>> watchArtists() {
    return _col
        .orderBy('created_at', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => ArtistModel.fromFirestore(d)).toList(),
        )
        .handleError((e) {
          throw ServerException(e.toString());
        });
  }

  @override
  Future<void> createArtist(ArtistModel artist) async {
    try {
      await _col.doc(artist.id).set(artist.toMap());
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to create artist.');
    }
  }

  @override
  Future<void> updateArtist(ArtistModel artist) async {
    try {
      final updated = ArtistModel.fromEntity(
        artist.copyWith(updatedAt: DateTime.now()),
      );
      await _col.doc(artist.id).update(updated.toMap());
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update artist.');
    }
  }

  @override
  Future<void> deleteArtist(String artistId) async {
    try {
      final songs = await firestore
          .collection(_songs)
          .where('artist_id', isEqualTo: artistId)
          .get();
      for (final doc in songs.docs) {
        await doc.reference.delete();
      }
      await _col.doc(artistId).delete();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete artist.');
    }
  }
}
