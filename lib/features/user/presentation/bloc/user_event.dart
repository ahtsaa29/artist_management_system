part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();
  @override
  List<Object?> get props => [];
}

class UserWatchStarted extends UserEvent {}

class UserUpdateRequested extends UserEvent {
  final UserEntity user;
  const UserUpdateRequested(this.user);
  @override
  List<Object> get props => [user];
}

class UserDeleteRequested extends UserEvent {
  final String userId;
  const UserDeleteRequested(this.userId);
  @override
  List<Object> get props => [userId];
}
