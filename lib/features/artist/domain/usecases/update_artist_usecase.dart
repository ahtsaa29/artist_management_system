import 'package:artist_management_system/core/error/failures.dart';
import 'package:artist_management_system/core/usecases/usecase.dart';
import 'package:artist_management_system/features/artist/domain/entities/artist.dart';
import 'package:artist_management_system/features/artist/domain/repository/artist_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

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
