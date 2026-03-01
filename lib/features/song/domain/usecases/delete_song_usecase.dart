import 'package:artist_management_system/core/error/failures.dart';
import 'package:artist_management_system/core/usecases/usecase.dart';
import 'package:artist_management_system/features/song/domain/repository/song_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class DeleteSong implements UseCase<void, DeleteSongParams> {
  final SongRepository repository;
  const DeleteSong(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteSongParams params) {
    return repository.deleteSong(params.songId);
  }
}

class DeleteSongParams extends Equatable {
  final String songId;
  const DeleteSongParams({required this.songId});

  @override
  List<Object?> get props => [songId];
}
