part of 'auth_bloc.dart';

abstract class AuthEvent {}

class AppStarted extends AuthEvent {}

class LoginSubmitted extends AuthEvent {
  final String username;
  final String password;
  LoginSubmitted(this.username, this.password);
}

class RegisterSubmitted extends AuthEvent {
  final String tableNumber;
  final String iin;

  RegisterSubmitted({
    required this.tableNumber,
    required this.iin,
  });
}

class RegisterPinCodeSubmitted extends AuthEvent {
  final int userId;
  final String pinCode;

  RegisterPinCodeSubmitted({
    required this.userId,
    required this.pinCode,
  });
}

class RegisterSetPasswordSubmitted extends AuthEvent {
  final int userId;
  final String registrationToken;
  final String password;

  RegisterSetPasswordSubmitted({
    required this.userId,
    required this.registrationToken,
    required this.password,
  });
}

class LogoutRequested extends AuthEvent {}