part of 'song_bloc.dart';

abstract class SongState extends Equatable {
  const SongState();
  @override
  List<Object?> get props => [];
}

class SongInitial extends SongState {}

class SongLoading extends SongState {}

class SongUploading extends SongState {
  final double progress;
  const SongUploading(this.progress);
  @override
  List<Object> get props => [progress];
}

class SongLoaded extends SongState {
  final List<SongEntity> songs;
  const SongLoaded(this.songs);
  @override
  List<Object> get props => [songs];
}

class SongError extends SongState {
  final String message;
  const SongError(this.message);
  @override
  List<Object> get props => [message];
}
