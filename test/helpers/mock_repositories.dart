import 'package:artist_management_system/core/error/failures.dart';
import 'package:artist_management_system/features/artist/domain/entities/artist.dart';
import 'package:artist_management_system/features/artist/domain/repository/artist_repository.dart';
import 'package:artist_management_system/features/auth/domain/entities/user_entity.dart';
import 'package:artist_management_system/features/auth/domain/repository/auth_repository.dart';
import 'package:artist_management_system/features/user/domain/repositories/user_repository.dart';
import 'package:dartz/dartz.dart';

class MockAuthRepository implements AuthRepository {
  Either<Failure, UserEntity?>? _getCurrentUserResult;
  Either<Failure, UserEntity>? _loginResult;
  Either<Failure, UserEntity>? _registerResult;
  Either<Failure, UserEntity>? _googleResult;
  Either<Failure, void>? _logoutResult;

  void stubGetCurrentUser(Either<Failure, UserEntity?> result) =>
      _getCurrentUserResult = result;
  void stubLogin(Either<Failure, UserEntity> result) => _loginResult = result;
  void stubRegister(Either<Failure, UserEntity> result) =>
      _registerResult = result;
  void stubGoogleSignIn(Either<Failure, UserEntity> result) =>
      _googleResult = result;
  void stubLogout(Either<Failure, void> result) => _logoutResult = result;

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async =>
      _getCurrentUserResult ?? const Right(null);

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async => _loginResult ?? Left(const AuthFailure('not stubbed'));

  @override
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String gender,
    required String address,
    DateTime? dob,
  }) async => _registerResult ?? Left(const AuthFailure('not stubbed'));

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async =>
      _googleResult ?? Left(const AuthFailure('not stubbed'));

  @override
  Future<Either<Failure, void>> logout() async =>
      _logoutResult ?? const Right(null);
}

class MockArtistRepository implements ArtistRepository {
  Stream<Either<Failure, List<ArtistEntity>>>? _watchStream;
  Either<Failure, void>? _createResult;
  Either<Failure, void>? _updateResult;
  Either<Failure, void>? _deleteResult;

  void stubWatch(Stream<Either<Failure, List<ArtistEntity>>> stream) =>
      _watchStream = stream;
  void stubCreate(Either<Failure, void> result) => _createResult = result;
  void stubUpdate(Either<Failure, void> result) => _updateResult = result;
  void stubDelete(Either<Failure, void> result) => _deleteResult = result;

  @override
  Stream<Either<Failure, List<ArtistEntity>>> watchArtists() =>
      _watchStream ?? const Stream.empty();

  @override
  Future<Either<Failure, void>> createArtist(ArtistEntity artist) async =>
      _createResult ?? const Right(null);

  @override
  Future<Either<Failure, void>> updateArtist(ArtistEntity artist) async =>
      _updateResult ?? const Right(null);

  @override
  Future<Either<Failure, void>> deleteArtist(String artistId) async =>
      _deleteResult ?? const Right(null);
}

class MockUserRepository implements UserRepository {
  Stream<Either<Failure, List<UserEntity>>>? _watchStream;
  Either<Failure, void>? _updateResult;
  Either<Failure, void>? _deleteResult;

  void stubWatch(Stream<Either<Failure, List<UserEntity>>> stream) =>
      _watchStream = stream;
  void stubUpdate(Either<Failure, void> result) => _updateResult = result;
  void stubDelete(Either<Failure, void> result) => _deleteResult = result;

  @override
  Stream<Either<Failure, List<UserEntity>>> watchUsers() =>
      _watchStream ?? const Stream.empty();

  @override
  Future<Either<Failure, void>> updateUser(UserEntity user) async =>
      _updateResult ?? const Right(null);

  @override
  Future<Either<Failure, void>> deleteUser(String userId) async =>
      _deleteResult ?? const Right(null);
}
