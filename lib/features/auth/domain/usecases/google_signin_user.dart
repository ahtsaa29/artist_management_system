import 'package:artist_management_system/core/error/failures.dart';
import 'package:artist_management_system/core/usecases/usecase.dart';
import 'package:artist_management_system/features/auth/domain/entities/user_entity.dart';
import 'package:artist_management_system/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';

class GoogleSignInUser implements UseCase<UserEntity, NoParams> {
  final AuthRepository repository;
  const GoogleSignInUser(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) {
    return repository.signInWithGoogle();
  }
}
