part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginRequested({required this.email, required this.password});
  @override
  List<Object> get props => [email, password];
}

class AuthGoogleSignInRequested extends AuthEvent {}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String phone;
  final String gender;
  final String address;
  final DateTime? dob;
  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.gender,
    required this.address,
    this.dob,
  });
  @override
  List<Object?> get props => [
    email,
    password,
    firstName,
    lastName,
    phone,
    gender,
    address,
    dob,
  ];
}

class AuthLogoutRequested extends AuthEvent {}
