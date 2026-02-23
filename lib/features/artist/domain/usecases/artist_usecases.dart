import 'package:artist_management_system/features/artist/domain/entities/artist.dart';
import 'package:artist_management_system/features/artist/domain/repository/artist_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

// ─── WatchArtists ────────────────────────────────────────────────────────────

class WatchArtists {
  final ArtistRepository repository;
  const WatchArtists(this.repository);

  Stream<Either<Failure, List<ArtistEntity>>> call() {
    return repository.watchArtists();
  }
}

// ─── CreateArtist ─────────────────────────────────────────────────────────────

class CreateArtist implements UseCase<void, CreateArtistParams> {
  final ArtistRepository repository;
  const CreateArtist(this.repository);

  @override
  Future<Either<Failure, void>> call(CreateArtistParams params) {
    return repository.createArtist(params.artist);
  }
}

class CreateArtistParams extends Equatable {
  final ArtistEntity artist;
  const CreateArtistParams(this.artist);
  @override
  List<Object> get props => [artist];
}

// ─── UpdateArtist ─────────────────────────────────────────────────────────────

class UpdateArtist implements UseCase<void, UpdateArtistParams> {
  final ArtistRepository repository;
  const UpdateArtist(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateArtistParams params) {
    return repository.updateArtist(params.artist);
  }
}

class UpdateArtistParams extends Equatable {
  final ArtistEntity artist;
  const UpdateArtistParams(this.artist);
  @override
  List<Object> get props => [artist];
}

// ─── DeleteArtist ─────────────────────────────────────────────────────────────

class DeleteArtist implements UseCase<void, DeleteArtistParams> {
  final ArtistRepository repository;
  const DeleteArtist(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteArtistParams params) {
    return repository.deleteArtist(params.artistId);
  }
}

class DeleteArtistParams extends Equatable {
  final String artistId;
  const DeleteArtistParams(this.artistId);
  @override
  List<Object> get props => [artistId];
}
