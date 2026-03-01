import 'package:artist_management_system/core/error/failures.dart';
import 'package:artist_management_system/core/usecases/usecase.dart';
import 'package:artist_management_system/features/artist/domain/repository/artist_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

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
