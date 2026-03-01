import 'package:artist_management_system/core/error/failures.dart';
import 'package:artist_management_system/features/song/domain/entities/song.dart';
import 'package:artist_management_system/features/song/domain/repository/song_repository.dart';
import 'package:dartz/dartz.dart';

class WatchSongsForArtist {
  final SongRepository repository;
  const WatchSongsForArtist(this.repository);

  Stream<Either<Failure, List<SongEntity>>> call(String artistId) {
    return repository.watchSongsForArtist(artistId);
  }
}
