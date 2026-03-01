import 'package:artist_management_system/core/error/failures.dart';
import 'package:artist_management_system/core/usecases/usecase.dart';
import 'package:artist_management_system/features/song/domain/entities/song.dart';
import 'package:artist_management_system/features/song/domain/repository/song_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class CreateSong implements UseCase<void, CreateSongParams> {
  final SongRepository repository;
  const CreateSong(this.repository);

  @override
  Future<Either<Failure, void>> call(CreateSongParams params) {
    return repository.createSong(params.song);
  }
}

class CreateSongParams extends Equatable {
  final SongEntity song;
  const CreateSongParams({required this.song});

  @override
  List<Object?> get props => [song];
}
