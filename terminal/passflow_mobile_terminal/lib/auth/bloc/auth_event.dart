part of 'auth_bloc.dart';

abstract class AuthEvent {}

class AppStarted extends AuthEvent {}

class LoginSubmitted extends AuthEvent {
  final String username;
  final String password;
  LoginSubmitted(this.username, this.password);
}

class RegisterSubmitted extends AuthEvent {
  final String userName;
  final String password;
  final String identityNumber; 
  final String tableNumber;
  RegisterSubmitted({
    required this.userName,
    required this.password,
    required this.identityNumber,
    required this.tableNumber,
  });
}

class LogoutRequested extends AuthEvent {}