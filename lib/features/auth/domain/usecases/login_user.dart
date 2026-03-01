import 'package:artist_management_system/core/error/failures.dart';
import 'package:artist_management_system/core/usecases/usecase.dart';
import 'package:artist_management_system/features/auth/domain/entities/user_entity.dart';
import 'package:artist_management_system/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class LoginUser implements UseCase<UserEntity, LoginParams> {
  final AuthRepository repository;
  const LoginUser(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) {
    return repository.login(email: params.email, password: params.password);
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}
