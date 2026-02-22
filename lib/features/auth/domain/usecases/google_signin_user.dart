import 'package:artist_management_system/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';

class GoogleSignInUser implements UseCase<UserEntity, NoParams> {
  final AuthRepository repository;
  const GoogleSignInUser(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) {
    return repository.signInWithGoogle();
  }
}
