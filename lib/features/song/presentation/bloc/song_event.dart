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
  final File? videoFile;

  const SongCreateRequested({
    required this.artistId,
    required this.title,
    required this.albumName,
    required this.genre,
    this.videoFile,
  });

  @override
  List<Object?> get props => [artistId, title, albumName, genre, videoFile];
}

class SongUpdateRequested extends SongEvent {
  final SongEntity song;
  final File? videoFile;

  const SongUpdateRequested({required this.song, this.videoFile});

  @override
  List<Object?> get props => [song, videoFile];
}

class SongDeleteRequested extends SongEvent {
  final String songId;
  final String? mp4Url;

  const SongDeleteRequested({required this.songId, this.mp4Url});

  @override
  List<Object?> get props => [songId, mp4Url];
}
