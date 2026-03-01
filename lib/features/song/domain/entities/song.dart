import 'package:equatable/equatable.dart';

class SongEntity extends Equatable {
  final String id;
  final String artistId;
  final String title;
  final String albumName;
  final String genre;
  final String? mp4Url;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SongEntity({
    required this.id,
    required this.artistId,
    required this.title,
    required this.albumName,
    required this.genre,
    this.mp4Url,
    required this.createdAt,
    required this.updatedAt,
  });

  SongEntity copyWith({
    String? id,
    String? artistId,
    String? title,
    String? albumName,
    String? genre,
    String? mp4Url,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SongEntity(
      id: id ?? this.id,
      artistId: artistId ?? this.artistId,
      title: title ?? this.title,
      albumName: albumName ?? this.albumName,
      genre: genre ?? this.genre,
      mp4Url: mp4Url ?? this.mp4Url,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get hasVideo => mp4Url != null && mp4Url!.isNotEmpty;

  @override
  List<Object?> get props => [id, artistId, title, albumName, genre, mp4Url];
}
