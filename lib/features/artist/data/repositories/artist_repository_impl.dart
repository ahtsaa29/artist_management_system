import 'package:artist_management_system/core/error/exceptions.dart';
import 'package:artist_management_system/core/error/failures.dart';
import 'package:artist_management_system/features/artist/data/datasources/artist_remote_datasource.dart';
import 'package:artist_management_system/features/artist/data/models/artist_model.dart';
import 'package:artist_management_system/features/artist/domain/entities/artist.dart';
import 'package:artist_management_system/features/artist/domain/repository/artist_repository.dart';
import 'package:dartz/dartz.dart';

class ArtistRepositoryImpl implements ArtistRepository {
  final ArtistRemoteDataSource remoteDataSource;

  const ArtistRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<Either<Failure, List<ArtistEntity>>> watchArtists() {
    return remoteDataSource
        .watchArtists()
        .map<Either<Failure, List<ArtistEntity>>>((artists) => Right(artists))
        .handleError((e) {
          return Left(ServerFailure(e.toString()));
        });
  }

  @override
  Future<Either<Failure, void>> createArtist(ArtistEntity artist) async {
    try {
      await remoteDataSource.createArtist(ArtistModel.fromEntity(artist));
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateArtist(ArtistEntity artist) async {
    try {
      await remoteDataSource.updateArtist(ArtistModel.fromEntity(artist));
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteArtist(String artistId) async {
    try {
      await remoteDataSource.deleteArtist(artistId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
