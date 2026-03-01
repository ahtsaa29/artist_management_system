import 'package:artist_management_system/core/error/failures.dart';
import 'package:artist_management_system/features/artist/domain/entities/artist.dart';
import 'package:artist_management_system/features/artist/domain/repository/artist_repository.dart';
import 'package:dartz/dartz.dart';

class WatchArtists {
  final ArtistRepository repository;
  const WatchArtists(this.repository);

  Stream<Either<Failure, List<ArtistEntity>>> call() {
    return repository.watchArtists();
  }
}
