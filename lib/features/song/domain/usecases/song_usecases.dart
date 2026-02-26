import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/song.dart';
import '../repository/song_repository.dart';

// ─── WatchSongsForArtist ──────────────────────────────────────────────────────

class WatchSongsForArtist {
  final SongRepository repository;
  const WatchSongsForArtist(this.repository);

  Stream<Either<Failure, List<SongEntity>>> call(String artistId) {
    return repository.watchSongsForArtist(artistId);
  }
}

// ─── CreateSong ───────────────────────────────────────────────────────────────

class CreateSong implements UseCase<void, CreateSongParams> {
  final SongRepository repository;
  const CreateSong(this.repository);

  @override
  Future<Either<Failure, void>> call(CreateSongParams params) {
    return repository.createSong(params.song, videoFile: params.videoFile);
  }
}

class CreateSongParams extends Equatable {
  final SongEntity song;
  final File? videoFile;
  const CreateSongParams({required this.song, this.videoFile});

  @override
  List<Object?> get props => [song, videoFile];
}

// ─── UpdateSong ───────────────────────────────────────────────────────────────

class UpdateSong implements UseCase<void, UpdateSongParams> {
  final SongRepository repository;
  const UpdateSong(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateSongParams params) {
    return repository.updateSong(params.song, videoFile: params.videoFile);
  }
}

class UpdateSongParams extends Equatable {
  final SongEntity song;
  final File? videoFile;
  const UpdateSongParams({required this.song, this.videoFile});

  @override
  List<Object?> get props => [song, videoFile];
}

// ─── DeleteSong ───────────────────────────────────────────────────────────────

class DeleteSong implements UseCase<void, DeleteSongParams> {
  final SongRepository repository;
  const DeleteSong(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteSongParams params) {
    return repository.deleteSong(params.songId, mp4Url: params.mp4Url);
  }
}

class DeleteSongParams extends Equatable {
  final String songId;
  final String? mp4Url;
  const DeleteSongParams({required this.songId, this.mp4Url});

  @override
  List<Object?> get props => [songId, mp4Url];
}
