import 'package:artist_management_system/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class LogoutUser implements UseCase<void, NoParams> {
  final AuthRepository repository;
  const LogoutUser(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.logout();
  }
}
