part of 'auth_bloc.dart';

abstract class AuthState {}

class AuthUnknown extends AuthState {}
class AuthLoading extends AuthState {}
class AuthUnauthenticated extends AuthState {}

class AuthLoginSucceeded extends AuthState {}

class AuthRegisterSucceeded extends AuthState {
  final String userName;
  AuthRegisterSucceeded(this.userName);
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}