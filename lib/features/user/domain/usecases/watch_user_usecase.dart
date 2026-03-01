import 'package:artist_management_system/core/error/failures.dart';
import 'package:artist_management_system/features/auth/domain/entities/user_entity.dart';
import 'package:artist_management_system/features/user/domain/repositories/user_repository.dart';
import 'package:dartz/dartz.dart';

class WatchUsers {
  final UserRepository repository;
  const WatchUsers(this.repository);
  Stream<Either<Failure, List<UserEntity>>> call() => repository.watchUsers();
}
