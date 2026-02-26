import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/song.dart';

abstract class SongRepository {
  Stream<Either<Failure, List<SongEntity>>> watchSongsForArtist(
    String artistId,
  );
  Future<Either<Failure, void>> createSong(SongEntity song, {File? videoFile});
  Future<Either<Failure, void>> updateSong(SongEntity song, {File? videoFile});
  Future<Either<Failure, void>> deleteSong(String songId, {String? mp4Url});
}
