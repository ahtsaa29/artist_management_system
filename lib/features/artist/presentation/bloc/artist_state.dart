part of 'artist_bloc.dart';

sealed class ArtistState extends Equatable {
  const ArtistState();
  
  @override
  List<Object> get props => [];
}

final class ArtistInitial extends ArtistState {}
