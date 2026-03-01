import 'package:artist_management_system/core/error/failures.dart';
import 'package:artist_management_system/core/usecases/usecase.dart';
import 'package:artist_management_system/features/user/domain/repositories/user_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

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
