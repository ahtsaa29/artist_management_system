import 'package:artist_management_system/features/song/domain/entities/song.dart';
import 'package:artist_management_system/features/song/domain/usecases/create_song_usecase.dart';
import 'package:artist_management_system/features/song/domain/usecases/delete_song_usecase.dart';
import 'package:artist_management_system/features/song/domain/usecases/update_song_usecase.dart';
import 'package:artist_management_system/features/song/domain/usecases/watch_song_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
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

    final result = await createSong(CreateSongParams(song: song));
    result.fold((failure) => emit(SongError(failure.message)), (_) {});
  }

  Future<void> _onUpdateRequested(
    SongUpdateRequested event,
    Emitter<SongState> emit,
  ) async {
    final result = await updateSong(UpdateSongParams(song: event.song));
    result.fold((failure) => emit(SongError(failure.message)), (_) {});
  }

  Future<void> _onDeleteRequested(
    SongDeleteRequested event,
    Emitter<SongState> emit,
  ) async {
    final result = await deleteSong(DeleteSongParams(songId: event.songId));
    result.fold((failure) => emit(SongError(failure.message)), (_) {});
  }
}
