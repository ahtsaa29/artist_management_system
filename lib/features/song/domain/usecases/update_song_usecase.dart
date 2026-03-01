import 'package:artist_management_system/core/error/failures.dart';
import 'package:artist_management_system/core/usecases/usecase.dart';
import 'package:artist_management_system/features/song/domain/entities/song.dart';
import 'package:artist_management_system/features/song/domain/repository/song_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class UpdateSong implements UseCase<void, UpdateSongParams> {
  final SongRepository repository;
  const UpdateSong(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateSongParams params) {
    return repository.updateSong(params.song);
  }
}

class UpdateSongParams extends Equatable {
  final SongEntity song;
  const UpdateSongParams({required this.song});

  @override
  List<Object?> get props => [song];
}
