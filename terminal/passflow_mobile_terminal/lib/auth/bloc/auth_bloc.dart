import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:passflow_app/auth/auth_service.dart';
import 'package:passflow_app/utils/network_utils.dart';
import 'package:passflow_app/core/dio/dio_client.dart';
import 'package:passflow_app/core/services/task_hive_service.dart';
import 'package:passflow_app/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthUnknown()) {
    on<AppStarted>(_onAppStarted);
    on<LoginSubmitted>(_onLogin);
    on<RegisterSubmitted>(_onRegister);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onAppStarted(AppStarted e, Emitter<AuthState> emit) async {
    emit(AuthUnauthenticated());
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
        await prefs.setString('user_name', userName);
        if (filialId != null && filialId > 0) {
          await prefs.setInt('last_filial_id', filialId);
        }
        await NetworkUtils.setForceOffline(false);

        await HiveService.initAllHive(force: true);

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
      final response = await DioClient.dio.post('/register', data: {
        'userName': e.userName,
        'password': e.password,
        'identityNumber': e.identityNumber,
        'tableNumber': e.tableNumber,
      });

      if (response.statusCode == 200) {
        emit(AuthRegisterSucceeded(e.userName));
      } else {
        emit(AuthFailure('Ошибка регистрации'));
      }
    } catch (err) {
      emit(AuthFailure('Ошибка регистрации'));
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
