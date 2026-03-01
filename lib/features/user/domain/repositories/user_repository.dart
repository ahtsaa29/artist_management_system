import 'package:artist_management_system/core/error/failures.dart';
import 'package:artist_management_system/features/auth/domain/entities/user_entity.dart';
import 'package:dartz/dartz.dart';

abstract class UserRepository {
  Stream<Either<Failure, List<UserEntity>>> watchUsers();
  Future<Either<Failure, void>> updateUser(UserEntity user);
  Future<Either<Failure, void>> deleteUser(String userId);
}
