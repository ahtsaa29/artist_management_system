import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/user_repository.dart';

class WatchUsers {
  final UserRepository repository;
  const WatchUsers(this.repository);
  Stream<Either<Failure, List<UserEntity>>> call() => repository.watchUsers();
}

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

class DeleteUser implements UseCase<void, DeleteUserParams> {
  final UserRepository repository;
  const DeleteUser(this.repository);
  @override
  Future<Either<Failure, void>> call(DeleteUserParams params) =>
      repository.deleteUser(params.userId);
}

class DeleteUserParams extends Equatable {
  final String userId;
  const DeleteUserParams(this.userId);
  @override
  List<Object> get props => [userId];
}
