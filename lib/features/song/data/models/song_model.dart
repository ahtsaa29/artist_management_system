import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/song.dart';

class SongModel extends SongEntity {
  const SongModel({
    required super.id,
    required super.artistId,
    required super.title,
    required super.albumName,
    required super.genre,
    super.mp4Url,
    required super.createdAt,
    required super.updatedAt,
  });

  factory SongModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SongModel(
      id: doc.id,
      artistId: data['artist_id'] ?? '',
      title: data['title'] ?? '',
      albumName: data['album_name'] ?? '',
      genre: data['genre'] ?? '',
      mp4Url: data['mp4_url'],
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
    );
  }

  factory SongModel.fromEntity(SongEntity entity) {
    return SongModel(
      id: entity.id,
      artistId: entity.artistId,
      title: entity.title,
      albumName: entity.albumName,
      genre: entity.genre,
      mp4Url: entity.mp4Url,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'artist_id': artistId,
      'title': title,
      'album_name': albumName,
      'genre': genre,
      'mp4_url': mp4Url,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }
}
