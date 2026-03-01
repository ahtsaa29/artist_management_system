import 'package:artist_management_system/core/error/exceptions.dart';
import 'package:artist_management_system/core/error/failures.dart';
import 'package:artist_management_system/features/song/data/datasources/song_remote_datasource.dart';
import 'package:artist_management_system/features/song/data/models/song_model.dart';
import 'package:artist_management_system/features/song/domain/entities/song.dart';
import 'package:artist_management_system/features/song/domain/repository/song_repository.dart';
import 'package:dartz/dartz.dart';

class SongRepositoryImpl implements SongRepository {
  final SongRemoteDataSource remoteDataSource;

  const SongRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<Either<Failure, List<SongEntity>>> watchSongsForArtist(
    String artistId,
  ) {
    return remoteDataSource
        .watchSongsForArtist(artistId)
        .map<Either<Failure, List<SongEntity>>>((songs) => Right(songs))
        .handleError((e) => Left(ServerFailure(e.toString())));
  }

  @override
  Future<Either<Failure, void>> createSong(SongEntity song) async {
    try {
      await remoteDataSource.createSong(SongModel.fromEntity(song));
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateSong(SongEntity song) async {
    try {
      await remoteDataSource.updateSong(SongModel.fromEntity(song));
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSong(String songId) async {
    try {
      await remoteDataSource.deleteSong(songId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
