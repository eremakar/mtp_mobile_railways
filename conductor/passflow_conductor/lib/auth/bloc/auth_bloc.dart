import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:passflow_app/auth/auth_service.dart';
import 'package:passflow_app/core/dio/dio_client.dart';
import 'package:passflow_app/core/services/logger.dart';
import 'package:passflow_app/core/services/task_hive_service.dart';
import 'package:passflow_app/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required authRepository}) : super(AuthUnknown()) {
    on<AppStarted>(_onAppStarted);
    on<LoginSubmitted>(_onLogin);
    on<RegisterSubmitted>(_onRegister);
    on<RegisterPinCodeSubmitted>(_onRegisterPinCode);
    on<RegisterSetPasswordSubmitted>(_onRegisterSetPassword);
    on<LogoutRequested>(_onLogout);
  }

  @override
  void onTransition(Transition<AuthEvent, AuthState> transition) {
    super.onTransition(transition);
    debugPrint(
      '[AuthBloc] ${transition.event.runtimeType}: ${transition.currentState.runtimeType} -> ${transition.nextState.runtimeType}',
    );
  }

  @override
  void onChange(Change<AuthState> change) {
    super.onChange(change);
    debugPrint(
      '[AuthBloc] state: ${change.currentState.runtimeType} -> ${change.nextState.runtimeType}',
    );
  }

  String _abbr(String s, {int head = 6, int tail = 4}) {
    if (s.isEmpty) return '';
    if (s.length <= head + tail) return s;
    return '${s.substring(0, head)}...${s.substring(s.length - tail)}';
  }

  void _logDioError(String tag, Object err) {
    if (err is DioException) {
      debugPrint('[$tag] DioException type=${err.type} message=${err.message}');
      debugPrint('[$tag] url=${err.requestOptions.uri}');
      debugPrint('[$tag] status=${err.response?.statusCode} data=${err.response?.data}');
    } else {
      debugPrint('[$tag] error=$err');
    }
  }

  Future<void> _onAppStarted(AppStarted e, Emitter<AuthState> emit) async {
    final token = await AuthService.getToken();
    if (!Hive.isBoxOpen('userBox')) {
      await Hive.openBox<UserModel>('userBox');
    }
    final user = Hive.box<UserModel>('userBox').get('currentUser');

    if (token != null &&
        token.isNotEmpty &&
        user != null &&
        (user.userId ?? 0) > 0) {
      logger.i('userId=${user.userId}');
      emit(AuthLoginSucceeded());
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(LoginSubmitted e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await DioClient.dio.post('/api/v1/authenticate', data: {
        'username': e.username,
        'password': e.password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['token'];
        if (token == null || token.toString().isEmpty) {
          return emit(AuthFailure('Неверный логин или пароль.'));
        }

        final userName = data['userName'] ?? e.username;
        final userId =
            data['userId'] != null ? int.tryParse('${data['userId']}') ?? 0 : 0;

        Map<String, dynamic> claims = {};
        try {
          claims = Jwt.parseJwt(token.toString());
        } catch (_) {}
        final filialId = int.tryParse('${claims['FilialId']}');
        final departmentId = int.tryParse('${claims['DepartmentId']}');

        final user = UserModel(
          id: userId,
          userId: userId,
          name: userName,
          token: token.toString(),
          filialId: filialId,
          departmentId: departmentId,
          employeeId: int.tryParse('${claims['EmployeeId']}') ?? 0,
          login: e.username,
          password: e.password,
        );

        final box = Hive.box<UserModel>('userBox');
        await box.put('currentUser', user);

        await AuthService.saveToken(token.toString());

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);

        await prefs.setString('user_name', userName);

        await HiveService.initAllHive();

        emit(AuthLoginSucceeded());
      } else if (response.statusCode == 401) {
        emit(AuthFailure('Неверный логин или пароль.'));
      } else {
        emit(AuthFailure('Ошибка авторизации'));
      }
    } catch (e) {
      emit(AuthFailure('Ошибка при авторизации'));
    }
  }

  Future<void> _onRegister(RegisterSubmitted e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      logger.i('[REGISTER:step1] POST /api/v1/register body={tableNumber:${e.tableNumber}, iin:${e.iin}}');

      final response = await DioClient.dio.post(
        '/api/v1/register',
        data: {
          'tableNumber': e.tableNumber,
          'iin': e.iin,
        },
      );

      logger.i('[REGISTER:step1] status=${response.statusCode} data=${response.data}');

      final code = response.statusCode ?? 0;
      final data = response.data;

      bool? success;
      String? message;
      int userId = 0;

      if (data is Map) {
        final s = data['success'];
        if (s is bool) success = s;

        final m = data['message'] ?? data['error'] ?? data['errors'];
        if (m != null) message = m.toString();

        final rawUserId = data['userId'];
        if (rawUserId != null) {
          userId = int.tryParse('$rawUserId') ?? 0;
        }
      }

      if (code == 200 || code == 201) {
        if (success == true) {
          if (userId <= 0) {
            emit(AuthFailure('Не пришел userId с сервера'));
            return;
          }
          emit(AuthRegisterCodeSent(userId: userId, message: message));
          return;
        }
        emit(AuthFailure(message?.isNotEmpty == true ? message! : 'Ошибка регистрации'));
        return;
      }

      emit(AuthFailure(message?.isNotEmpty == true ? message! : 'Ошибка регистрации'));
    } catch (err) {
      logger.i('[REGISTER:step1] error=$err');
      emit(AuthFailure('Ошибка регистрации'));
    }
  }

  Future<void> _onRegisterPinCode(
    RegisterPinCodeSubmitted e,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      logger.i('[REGISTER:step2] POST /api/v1/register/pin-code body={userId:${e.userId}, pinCode:${e.pinCode}}');

      final response = await DioClient.dio.post(
        '/api/v1/register/pin-code',
        data: {
          'userId': e.userId,
          'pinCode': e.pinCode,
        },
        options: Options(contentType: 'application/json-patch+json'),
      );

      logger.i('[REGISTER:step2] status=${response.statusCode} data=${response.data}');

      final code = response.statusCode ?? 0;
      final data = response.data;

      bool? success;
      String? message;
      String? registrationToken;
      int userId = e.userId;

      if (data is Map) {
        final s = data['success'];
        if (s is bool) success = s;

        final m = data['message'] ?? data['error'] ?? data['errors'];
        if (m != null) message = m.toString();

        final rawUserId = data['userId'];
        if (rawUserId != null) {
          userId = int.tryParse('$rawUserId') ?? userId;
        }

        final tok = data['registrationToken'];
        if (tok != null) registrationToken = tok.toString();
      }

      if (code == 200 || code == 201) {
        if (success == true && registrationToken != null && registrationToken.isNotEmpty) {
          emit(AuthRegisterTokenReceived(
            userId: userId,
            registrationToken: registrationToken,
            message: message,
          ));
          return;
        }
        emit(AuthFailure(message?.isNotEmpty == true ? message! : 'Неверный код'));
        return;
      }

      emit(AuthFailure(message?.isNotEmpty == true ? message! : 'Ошибка подтверждения кода'));
    } catch (err) {
      logger.i('[REGISTER:step2] error=$err');
      emit(AuthFailure('Ошибка подтверждения кода'));
    }
  }

  Future<void> _onRegisterSetPassword(
    RegisterSetPasswordSubmitted e,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      debugPrint('[REGISTER:step3] baseUrl=${DioClient.dio.options.baseUrl}');
      debugPrint('[REGISTER:step3] POST /api/v1/register/set-password payload={userId:${e.userId}, token:${_abbr(e.registrationToken)}(len:${e.registrationToken.length}), passLen:${e.password.length}}');

      final response = await DioClient.dio.post(
        '/api/v1/register/set-password',
        data: {
          'userId': e.userId,
          'registrationToken': e.registrationToken,
          'password': e.password,
        },
        options: Options(contentType: 'application/json-patch+json'),
      );

      debugPrint('[REGISTER:step3] status=${response.statusCode} data=${response.data}');

      final code = response.statusCode ?? 0;
      final data = response.data;

      bool? success;
      String? message;
      if (data is Map) {
        final s = data['success'];
        if (s is bool) success = s;
        final m = data['message'] ?? data['error'] ?? data['errors'];
        if (m != null) message = m.toString();
      }

      if (code == 200 || code == 201) {
        if (success == true) {
          emit(AuthRegisterSucceededFinal(message: message));
          emit(AuthUnauthenticated());
          return;
        }
        emit(AuthFailure(message?.isNotEmpty == true ? message! : 'Не удалось установить пароль'));
        return;
      }

      emit(AuthFailure(message?.isNotEmpty == true ? message! : 'Ошибка установки пароля'));
    } catch (err) {
      _logDioError('REGISTER:step3', err);
      emit(AuthFailure('Ошибка установки пароля'));
    }
  }

  Future<void> _onLogout(LogoutRequested e, Emitter<AuthState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_name');
      await AuthService.clearToken();
      final box = Hive.box<UserModel>('userBox');
      await box.delete('currentUser');
      emit(AuthUnauthenticated());
    } catch (err) {
      emit(AuthUnauthenticated());
    }
  }
}
