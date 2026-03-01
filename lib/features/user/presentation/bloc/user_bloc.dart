import 'package:artist_management_system/features/auth/domain/entities/user_entity.dart';
import 'package:artist_management_system/features/user/domain/usecases/delete_user_usecase.dart';
import 'package:artist_management_system/features/user/domain/usecases/update_user_usecase.dart';
import 'package:artist_management_system/features/user/domain/usecases/watch_user_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final WatchUsers watchUsers;
  final UpdateUser updateUser;
  final DeleteUser deleteUser;

  UserBloc({
    required this.watchUsers,
    required this.updateUser,
    required this.deleteUser,
  }) : super(UserInitial()) {
    on<UserWatchStarted>(_onWatchStarted);
    on<UserUpdateRequested>(_onUpdateRequested);
    on<UserDeleteRequested>(_onDeleteRequested);
  }

  Future<void> _onWatchStarted(
    UserWatchStarted event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    await emit.forEach(
      watchUsers(),
      onData: (result) => result.fold(
        (failure) => UserError(failure.message),
        (users) => UserLoaded(users),
      ),
    );
  }

  Future<void> _onUpdateRequested(
    UserUpdateRequested event,
    Emitter<UserState> emit,
  ) async {
    final result = await updateUser(UpdateUserParams(event.user));
    result.fold((failure) => emit(UserError(failure.message)), (_) {});
  }

  Future<void> _onDeleteRequested(
    UserDeleteRequested event,
    Emitter<UserState> emit,
  ) async {
    final result = await deleteUser(DeleteUserParams(event.userId));
    result.fold((failure) => emit(UserError(failure.message)), (_) {});
  }
}
