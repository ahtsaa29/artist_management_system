import 'package:artist_management_system/core/error/failures.dart';
import 'package:artist_management_system/core/usecases/usecase.dart';
import 'package:artist_management_system/features/auth/domain/entities/user_entity.dart';
import 'package:artist_management_system/features/user/domain/repositories/user_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class UpdateUser implements UseCase<void, UpdateUserParams> {
  final UserRepository repository;
  const UpdateUser(this.repository);
  @override
  Future<Either<Failure, void>> call(UpdateUserParams params) =>
      repository.updateUser(params.user);
}

class UpdateUserParams extends Equatable {
  final UserEntity user;
  const UpdateUserParams(this.user);
  @override
  List<Object> get props => [user];
}
