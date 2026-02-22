import 'package:artist_management_system/features/auth/domain/repository/auth_repository.dart';
import 'package:artist_management_system/features/auth/domain/usecases/google_signin_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

// Auth
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/logout_user.dart';
import 'features/auth/domain/usecases/register_user.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

// // Artist
// import 'features/artist/data/datasources/artist_remote_datasource.dart';
// import 'features/artist/data/repositories/artist_repository_impl.dart';
// import 'features/artist/domain/usecases/artist_usecases.dart';
// import 'features/artist/presentation/bloc/artist_bloc.dart';

// // Song
// import 'features/song/data/datasources/song_remote_datasource.dart';
// import 'features/song/data/repositories/song_repository_impl.dart';
// import 'features/song/domain/usecases/song_usecases.dart';
// import 'features/song/presentation/bloc/song_bloc.dart';

// // User
// import 'features/user/data/user_data.dart';
// import 'features/user/domain/repositories/user_repository.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl(), firestore: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  sl.registerLazySingleton<GoogleSignInUser>(() => GoogleSignInUser(sl()));
  sl.registerFactory(
    () => AuthBloc(
      getCurrentUser: sl(),
      loginUser: sl(),
      registerUser: sl(),
      logoutUser: sl(),
      googleSignInUser: sl(),
    ),
  );
}
