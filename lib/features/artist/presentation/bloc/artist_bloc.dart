import 'package:artist_management_system/features/artist/domain/entities/artist.dart';
import 'package:artist_management_system/features/artist/domain/usecases/create_artist_usecase.dart';
import 'package:artist_management_system/features/artist/domain/usecases/delete_artisit_usecase.dart';
import 'package:artist_management_system/features/artist/domain/usecases/update_artist_usecase.dart';
import 'package:artist_management_system/features/artist/domain/usecases/watch_artist_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
part 'artist_event.dart';
part 'artist_state.dart';

class ArtistBloc extends Bloc<ArtistEvent, ArtistState> {
  final WatchArtists watchArtists;
  final CreateArtist createArtist;
  final UpdateArtist updateArtist;
  final DeleteArtist deleteArtist;
  final _uuid = const Uuid();

  ArtistBloc({
    required this.watchArtists,
    required this.createArtist,
    required this.updateArtist,
    required this.deleteArtist,
  }) : super(ArtistInitial()) {
    on<ArtistWatchStarted>(_onWatchStarted);
    on<ArtistCreateRequested>(_onCreateRequested);
    on<ArtistUpdateRequested>(_onUpdateRequested);
    on<ArtistDeleteRequested>(_onDeleteRequested);
  }

  Future<void> _onWatchStarted(
    ArtistWatchStarted event,
    Emitter<ArtistState> emit,
  ) async {
    emit(ArtistLoading());
    await emit.forEach(
      watchArtists(),
      onData: (result) => result.fold(
        (failure) => ArtistError(failure.message),
        (artists) => ArtistLoaded(artists),
      ),
    );
  }

  Future<void> _onCreateRequested(
    ArtistCreateRequested event,
    Emitter<ArtistState> emit,
  ) async {
    final now = DateTime.now();
    final artist = ArtistEntity(
      id: _uuid.v4(),
      name: event.name,
      gender: event.gender,
      address: event.address,
      firstReleaseYear: event.firstReleaseYear,
      noOfAlbumsReleased: event.noOfAlbumsReleased,
      dob: event.dob,
      createdAt: now,
      updatedAt: now,
    );
    final result = await createArtist(CreateArtistParams(artist));
    result.fold((failure) => emit(ArtistError(failure.message)), (_) {});
  }

  Future<void> _onUpdateRequested(
    ArtistUpdateRequested event,
    Emitter<ArtistState> emit,
  ) async {
    final result = await updateArtist(UpdateArtistParams(event.artist));
    result.fold((failure) => emit(ArtistError(failure.message)), (_) {});
  }

  Future<void> _onDeleteRequested(
    ArtistDeleteRequested event,
    Emitter<ArtistState> emit,
  ) async {
    final result = await deleteArtist(DeleteArtistParams(event.artistId));
    result.fold((failure) => emit(ArtistError(failure.message)), (_) {});
  }
}
