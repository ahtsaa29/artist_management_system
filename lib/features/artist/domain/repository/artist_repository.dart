import 'package:artist_management_system/core/error/failures.dart';
import 'package:artist_management_system/features/artist/domain/entities/artist.dart';
import 'package:dartz/dartz.dart';

abstract class ArtistRepository {
  Stream<Either<Failure, List<ArtistEntity>>> watchArtists();
  Future<Either<Failure, void>> createArtist(ArtistEntity artist);
  Future<Either<Failure, void>> updateArtist(ArtistEntity artist);
  Future<Either<Failure, void>> deleteArtist(String artistId);
}
