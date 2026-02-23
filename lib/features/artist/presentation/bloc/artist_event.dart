part of 'artist_bloc.dart';

abstract class ArtistEvent extends Equatable {
  const ArtistEvent();
  @override
  List<Object?> get props => [];
}

class ArtistWatchStarted extends ArtistEvent {}

class ArtistCreateRequested extends ArtistEvent {
  final String name;
  final String gender;
  final String address;
  final int? firstReleaseYear;
  final int noOfAlbumsReleased;
  final DateTime? dob;

  const ArtistCreateRequested({
    required this.name,
    required this.gender,
    required this.address,
    this.firstReleaseYear,
    required this.noOfAlbumsReleased,
    this.dob,
  });

  @override
  List<Object?> get props => [
    name,
    gender,
    address,
    firstReleaseYear,
    noOfAlbumsReleased,
    dob,
  ];
}

class ArtistUpdateRequested extends ArtistEvent {
  final ArtistEntity artist;
  const ArtistUpdateRequested(this.artist);
  @override
  List<Object> get props => [artist];
}

class ArtistDeleteRequested extends ArtistEvent {
  final String artistId;
  const ArtistDeleteRequested(this.artistId);
  @override
  List<Object> get props => [artistId];
}
