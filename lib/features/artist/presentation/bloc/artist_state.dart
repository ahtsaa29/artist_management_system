part of 'artist_bloc.dart';

abstract class ArtistState extends Equatable {
  const ArtistState();
  @override
  List<Object?> get props => [];
}

class ArtistInitial extends ArtistState {}

class ArtistLoading extends ArtistState {}

class ArtistLoaded extends ArtistState {
  final List<ArtistEntity> artists;
  const ArtistLoaded(this.artists);
  @override
  List<Object> get props => [artists];
}

class ArtistError extends ArtistState {
  final String message;
  const ArtistError(this.message);
  @override
  List<Object> get props => [message];
}
