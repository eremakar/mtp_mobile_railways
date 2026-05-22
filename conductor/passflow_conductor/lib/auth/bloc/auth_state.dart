part of 'auth_bloc.dart';

abstract class AuthState {
  const AuthState();
}

class AuthUnknown extends AuthState {
  const AuthUnknown();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthLoginSucceeded extends AuthState {
  const AuthLoginSucceeded();
}

class AuthRegisterCodeSent extends AuthState {
  final int userId;
  final String? message;
  const AuthRegisterCodeSent({required this.userId, this.message});
}

class AuthRegisterTokenReceived extends AuthState {
  final int userId;
  final String registrationToken;
  final String? message;
  const AuthRegisterTokenReceived({
    required this.userId,
    required this.registrationToken,
    this.message,
  });
}

class AuthRegisterSucceededFinal extends AuthState {
  final String? message;
  const AuthRegisterSucceededFinal({this.message});
}

class AuthRegisterSucceeded extends AuthRegisterSucceededFinal {
  const AuthRegisterSucceeded({super.message});
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}