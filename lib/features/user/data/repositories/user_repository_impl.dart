import 'package:artist_management_system/core/error/exceptions.dart';
import 'package:artist_management_system/core/error/failures.dart';
import 'package:artist_management_system/features/auth/data/models/user_model.dart';
import 'package:artist_management_system/features/auth/domain/entities/user_entity.dart';
import 'package:artist_management_system/features/user/data/datasources/user_remote_datasource.dart';
import 'package:artist_management_system/features/user/domain/repositories/user_repository.dart';
import 'package:dartz/dartz.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  const UserRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<Either<Failure, List<UserEntity>>> watchUsers() {
    return remoteDataSource
        .watchUsers()
        .map<Either<Failure, List<UserEntity>>>((users) => Right(users))
        .handleError((_) => Left(const ServerFailure()));
  }

  @override
  Future<Either<Failure, void>> updateUser(UserEntity user) async {
    try {
      await remoteDataSource.updateUser(UserModel.fromEntity(user));
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(String userId) async {
    try {
      await remoteDataSource.deleteUser(userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
