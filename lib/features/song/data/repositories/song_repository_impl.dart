import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/song.dart';
import '../../domain/repository/song_repository.dart';
import '../datasources/song_remote_datasource.dart';
import '../models/song_model.dart';

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
  Future<Either<Failure, void>> createSong(
    SongEntity song, {
    File? videoFile,
  }) async {
    try {
      await remoteDataSource.createSong(
        SongModel.fromEntity(song),
        videoFile: videoFile,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateSong(
    SongEntity song, {
    File? videoFile,
  }) async {
    try {
      await remoteDataSource.updateSong(
        SongModel.fromEntity(song),
        videoFile: videoFile,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSong(
    String songId, {
    String? mp4Url,
  }) async {
    try {
      await remoteDataSource.deleteSong(songId, mp4Url: mp4Url);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
