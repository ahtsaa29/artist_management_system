import 'package:artist_management_system/core/error/failures.dart';
import 'package:artist_management_system/features/artist/domain/entities/artist.dart';
import 'package:artist_management_system/features/artist/domain/repository/artist_repository.dart';
import 'package:artist_management_system/features/auth/domain/entities/user_entity.dart';
import 'package:artist_management_system/features/auth/domain/repository/auth_repository.dart';
import 'package:artist_management_system/features/song/data/datasources/song_remote_datasource.dart';
import 'package:artist_management_system/features/song/data/models/song_model.dart';
import 'package:artist_management_system/features/song/domain/entities/song.dart';
import 'package:artist_management_system/features/song/domain/repository/song_repository.dart';
import 'package:artist_management_system/features/user/domain/repositories/user_repository.dart';
import 'package:dartz/dartz.dart';

// ─── MockAuthRepository ───────────────────────────────────────────────────────

class MockAuthRepository implements AuthRepository {
  Either<Failure, UserEntity?> _getCurrentUserResult = const Right(null);
  Either<Failure, UserEntity>? _loginResult;
  Either<Failure, UserEntity>? _registerResult;
  Either<Failure, UserEntity>? _googleResult;
  Either<Failure, void> _logoutResult = const Right(null);

  void stubGetCurrentUser(Either<Failure, UserEntity?> r) =>
      _getCurrentUserResult = r;
  void stubLogin(Either<Failure, UserEntity> r) => _loginResult = r;
  void stubRegister(Either<Failure, UserEntity> r) => _registerResult = r;
  void stubGoogleSignIn(Either<Failure, UserEntity> r) => _googleResult = r;
  void stubLogout(Either<Failure, void> r) => _logoutResult = r;

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async =>
      _getCurrentUserResult;

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async => _loginResult!;

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
  }) async => _registerResult!;

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async =>
      _googleResult!;

  @override
  Future<Either<Failure, void>> logout() async => _logoutResult;
}

// ─── MockArtistRepository ─────────────────────────────────────────────────────

class MockArtistRepository implements ArtistRepository {
  Stream<Either<Failure, List<ArtistEntity>>>? _watchStream;
  Either<Failure, void> _createResult = const Right(null);
  Either<Failure, void> _updateResult = const Right(null);
  Either<Failure, void> _deleteResult = const Right(null);

  void stubWatch(Stream<Either<Failure, List<ArtistEntity>>> s) =>
      _watchStream = s;
  void stubCreate(Either<Failure, void> r) => _createResult = r;
  void stubUpdate(Either<Failure, void> r) => _updateResult = r;
  void stubDelete(Either<Failure, void> r) => _deleteResult = r;

  @override
  Stream<Either<Failure, List<ArtistEntity>>> watchArtists() =>
      _watchStream ?? const Stream.empty();

  @override
  Future<Either<Failure, void>> createArtist(ArtistEntity artist) async =>
      _createResult;

  @override
  Future<Either<Failure, void>> updateArtist(ArtistEntity artist) async =>
      _updateResult;

  @override
  Future<Either<Failure, void>> deleteArtist(String artistId) async =>
      _deleteResult;
}

// ─── MockUserRepository ───────────────────────────────────────────────────────

class MockUserRepository implements UserRepository {
  Stream<Either<Failure, List<UserEntity>>>? _watchStream;
  Either<Failure, void> _updateResult = const Right(null);
  Either<Failure, void> _deleteResult = const Right(null);

  void stubWatch(Stream<Either<Failure, List<UserEntity>>> s) =>
      _watchStream = s;
  void stubUpdate(Either<Failure, void> r) => _updateResult = r;
  void stubDelete(Either<Failure, void> r) => _deleteResult = r;

  @override
  Stream<Either<Failure, List<UserEntity>>> watchUsers() =>
      _watchStream ?? const Stream.empty();

  @override
  Future<Either<Failure, void>> updateUser(UserEntity u) async => _updateResult;

  @override
  Future<Either<Failure, void>> deleteUser(String userId) async =>
      _deleteResult;
}

// ─── MockSongRepository ───────────────────────────────────────────────────────

class MockSongRepository implements SongRepository {
  Stream<Either<Failure, List<SongEntity>>>? _watchStream;
  Either<Failure, void> _createResult = const Right(null);
  Either<Failure, void> _updateResult = const Right(null);
  Either<Failure, void> _deleteResult = const Right(null);

  void stubWatch(Stream<Either<Failure, List<SongEntity>>> s) =>
      _watchStream = s;
  void stubCreate(Either<Failure, void> r) => _createResult = r;
  void stubUpdate(Either<Failure, void> r) => _updateResult = r;
  void stubDelete(Either<Failure, void> r) => _deleteResult = r;

  @override
  Stream<Either<Failure, List<SongEntity>>> watchSongsForArtist(
    String artistId,
  ) => _watchStream ?? const Stream.empty();

  @override
  Future<Either<Failure, void>> createSong(SongEntity song) async =>
      _createResult;

  @override
  Future<Either<Failure, void>> updateSong(SongEntity song) async =>
      _updateResult;

  @override
  Future<Either<Failure, void>> deleteSong(String songId) async =>
      _deleteResult;
}

// ─── MockSongRemoteDataSource ─────────────────────────────────────────────────

class MockSongRemoteDataSource implements SongRemoteDataSource {
  Stream<List<SongModel>>? _watchStream;
  Exception? _createError;
  Exception? _updateError;
  Exception? _deleteError;

  void stubWatch(Stream<List<SongModel>> s) => _watchStream = s;
  void stubCreateError(Exception e) => _createError = e;
  void stubUpdateError(Exception e) => _updateError = e;
  void stubDeleteError(Exception e) => _deleteError = e;

  @override
  Stream<List<SongModel>> watchSongsForArtist(String artistId) =>
      _watchStream ?? const Stream.empty();

  @override
  Future<void> createSong(SongModel song) async {
    if (_createError != null) throw _createError!;
  }

  @override
  Future<void> updateSong(SongModel song) async {
    if (_updateError != null) throw _updateError!;
  }

  @override
  Future<void> deleteSong(String songId) async {
    if (_deleteError != null) throw _deleteError!;
  }
}
