import 'package:artist_management_system/core/error/failures.dart';
import 'package:artist_management_system/core/usecases/usecase.dart';
import 'package:artist_management_system/features/artist/domain/entities/artist.dart';
import 'package:artist_management_system/features/artist/domain/repository/artist_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

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
