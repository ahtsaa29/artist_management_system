import 'package:artist_management_system/features/artist/data/datasources/artist_remote_datasource.dart';
import 'package:artist_management_system/features/artist/data/models/artist_model.dart';
import 'package:artist_management_system/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:artist_management_system/features/auth/data/models/user_model.dart';
import 'package:artist_management_system/features/user/data/datasources/user_remote_datasource.dart';

class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  UserModel? _currentUser;
  UserModel? _loginResult;
  UserModel? _registerResult;
  UserModel? _googleResult;
  Exception? _loginError;
  Exception? _registerError;
  Exception? _googleError;
  Exception? _currentUserError;
  Exception? _logoutError;

  void stubCurrentUser(UserModel? user) => _currentUser = user;
  void stubCurrentUserError(Exception e) => _currentUserError = e;
  void stubLogin(UserModel user) => _loginResult = user;
  void stubLoginError(Exception e) => _loginError = e;
  void stubRegister(UserModel user) => _registerResult = user;
  void stubRegisterError(Exception e) => _registerError = e;
  void stubGoogle(UserModel user) => _googleResult = user;
  void stubGoogleError(Exception e) => _googleError = e;
  void stubLogoutError(Exception e) => _logoutError = e;

  @override
  Future<UserModel?> getCurrentUser() async {
    if (_currentUserError != null) throw _currentUserError!;
    return _currentUser;
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    if (_loginError != null) throw _loginError!;
    return _loginResult!;
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String gender,
    required String address,
    DateTime? dob,
  }) async {
    if (_registerError != null) throw _registerError!;
    return _registerResult!;
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    if (_googleError != null) throw _googleError!;
    return _googleResult!;
  }

  @override
  Future<void> logout() async {
    if (_logoutError != null) throw _logoutError!;
  }
}

class MockArtistRemoteDataSource implements ArtistRemoteDataSource {
  Stream<List<ArtistModel>>? _watchStream;
  Exception? _createError;
  Exception? _updateError;
  Exception? _deleteError;

  void stubWatch(Stream<List<ArtistModel>> stream) => _watchStream = stream;
  void stubCreateError(Exception e) => _createError = e;
  void stubUpdateError(Exception e) => _updateError = e;
  void stubDeleteError(Exception e) => _deleteError = e;

  @override
  Stream<List<ArtistModel>> watchArtists() =>
      _watchStream ?? const Stream.empty();

  @override
  Future<void> createArtist(ArtistModel artist) async {
    if (_createError != null) throw _createError!;
  }

  @override
  Future<void> updateArtist(ArtistModel artist) async {
    if (_updateError != null) throw _updateError!;
  }

  @override
  Future<void> deleteArtist(String artistId) async {
    if (_deleteError != null) throw _deleteError!;
  }
}

class MockUserRemoteDataSource implements UserRemoteDataSource {
  Stream<List<UserModel>>? _watchStream;
  Exception? _updateError;
  Exception? _deleteError;

  void stubWatch(Stream<List<UserModel>> stream) => _watchStream = stream;
  void stubUpdateError(Exception e) => _updateError = e;
  void stubDeleteError(Exception e) => _deleteError = e;

  @override
  Stream<List<UserModel>> watchUsers() => _watchStream ?? const Stream.empty();

  @override
  Future<void> updateUser(UserModel user) async {
    if (_updateError != null) throw _updateError!;
  }

  @override
  Future<void> deleteUser(String userId) async {
    if (_deleteError != null) throw _deleteError!;
  }
}
