import 'package:artist_management_system/core/error/failures.dart';
import 'package:artist_management_system/features/song/domain/entities/song.dart';
import 'package:dartz/dartz.dart';

abstract class SongRepository {
  Stream<Either<Failure, List<SongEntity>>> watchSongsForArtist(
    String artistId,
  );
  Future<Either<Failure, void>> createSong(SongEntity song);
  Future<Either<Failure, void>> updateSong(SongEntity song);
  Future<Either<Failure, void>> deleteSong(String songId);
}
