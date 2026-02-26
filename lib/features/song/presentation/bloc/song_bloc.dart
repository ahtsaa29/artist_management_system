import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/song.dart';
import '../../domain/usecases/song_usecases.dart';

part 'song_event.dart';
part 'song_state.dart';

class SongBloc extends Bloc<SongEvent, SongState> {
  final WatchSongsForArtist watchSongsForArtist;
  final CreateSong createSong;
  final UpdateSong updateSong;
  final DeleteSong deleteSong;
  final _uuid = const Uuid();

  SongBloc({
    required this.watchSongsForArtist,
    required this.createSong,
    required this.updateSong,
    required this.deleteSong,
  }) : super(SongInitial()) {
    on<SongWatchStarted>(_onWatchStarted);
    on<SongCreateRequested>(_onCreateRequested);
    on<SongUpdateRequested>(_onUpdateRequested);
    on<SongDeleteRequested>(_onDeleteRequested);
  }

  Future<void> _onWatchStarted(
    SongWatchStarted event,
    Emitter<SongState> emit,
  ) async {
    emit(SongLoading());
    await emit.forEach(
      watchSongsForArtist(event.artistId),
      onData: (result) => result.fold(
        (failure) => SongError(failure.message),
        (songs) => SongLoaded(songs),
      ),
    );
  }

  Future<void> _onCreateRequested(
    SongCreateRequested event,
    Emitter<SongState> emit,
  ) async {
    if (event.videoFile != null) emit(const SongUploading(0.0));

    final now = DateTime.now();
    final song = SongEntity(
      id: _uuid.v4(),
      artistId: event.artistId,
      title: event.title,
      albumName: event.albumName,
      genre: event.genre,
      createdAt: now,
      updatedAt: now,
    );

    final result = await createSong(
      CreateSongParams(song: song, videoFile: event.videoFile),
    );
    result.fold((failure) => emit(SongError(failure.message)), (_) {});
  }

  Future<void> _onUpdateRequested(
    SongUpdateRequested event,
    Emitter<SongState> emit,
  ) async {
    if (event.videoFile != null) emit(const SongUploading(0.0));

    final result = await updateSong(
      UpdateSongParams(song: event.song, videoFile: event.videoFile),
    );
    result.fold((failure) => emit(SongError(failure.message)), (_) {});
  }

  Future<void> _onDeleteRequested(
    SongDeleteRequested event,
    Emitter<SongState> emit,
  ) async {
    final result = await deleteSong(
      DeleteSongParams(songId: event.songId, mp4Url: event.mp4Url),
    );
    result.fold((failure) => emit(SongError(failure.message)), (_) {});
  }
}
