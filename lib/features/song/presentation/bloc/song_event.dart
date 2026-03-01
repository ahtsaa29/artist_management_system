part of 'song_bloc.dart';

abstract class SongEvent extends Equatable {
  const SongEvent();
  @override
  List<Object?> get props => [];
}

class SongWatchStarted extends SongEvent {
  final String artistId;
  const SongWatchStarted(this.artistId);
  @override
  List<Object> get props => [artistId];
}

class SongCreateRequested extends SongEvent {
  final String artistId;
  final String title;
  final String albumName;
  final String genre;

  const SongCreateRequested({
    required this.artistId,
    required this.title,
    required this.albumName,
    required this.genre,
  });

  @override
  List<Object?> get props => [artistId, title, albumName, genre];
}

class SongUpdateRequested extends SongEvent {
  final SongEntity song;

  const SongUpdateRequested({required this.song});

  @override
  List<Object?> get props => [song];
}

class SongDeleteRequested extends SongEvent {
  final String songId;

  const SongDeleteRequested({required this.songId});

  @override
  List<Object?> get props => [songId];
}
