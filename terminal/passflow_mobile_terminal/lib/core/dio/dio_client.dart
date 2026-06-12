import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:passflow_app/core/dio/api_log_interceptor.dart';
import 'package:passflow_app/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Future<List<String>> getSavedImeis() async {
  final box = await Hive.openBox('deviceBox');
  final imeis = box.get('imeis', defaultValue: <String>[]);
  return List<String>.from(imeis);
}

class DioClient {
  static final Dio dio = () {
    final client = Dio(
      BaseOptions(
        baseUrl: 'https://passflow.railways.kz:8443',
        connectTimeout: 10000,
        receiveTimeout: 10000,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    client.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          final imeis = await getSavedImeis();

          options.headers['Device'] = jsonEncode({
            "Id": "001",
            "Type": "WEB",
            "Version": "1.0.0",
            "Serial": imeis.isNotEmpty ? imeis.first : "unknown",
          });

          return handler.next(options);
        },
        onError: (e, handler) async {
          // If unauthorized, try to re-auth using stored UserModel creds, then retry once
          if (e.response?.statusCode == 401) {
            final req = e.requestOptions;

            // Avoid retrying auth endpoint or multiple retries
            final alreadyRetried = req.extra['retried'] == true;
            if (alreadyRetried || req.path.contains('/api/v1/authenticate')) {
              return handler.next(e);
            }

            try {
              final box = Hive.box<UserModel>('userBox');
              final user = box.get('currentUser');

              if (user == null || user.login.isEmpty || user.password.isEmpty) {
                return handler.next(e);
              }

              // Perform login with a clean Dio (no interceptors to avoid loops)
              final authDio = Dio(
                BaseOptions(
                  baseUrl: dio.options.baseUrl,
                  connectTimeout: dio.options.connectTimeout,
                  receiveTimeout: dio.options.receiveTimeout,
                  headers: {'Content-Type': 'application/json'},
                ),
              );

              final authResp = await authDio.post(
                '/api/v1/authenticate',
                data: {
                  'username': user.login,
                  'password': user.password,
                },
              );

              if (authResp.statusCode == 200) {
                final data = authResp.data;
                final newToken = data['token']?.toString();
                if (newToken != null && newToken.isNotEmpty) {
                  // Save token to prefs and Hive user
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('auth_token', newToken);
                  user.token = newToken;
                  await user.save();

                  // Update original request with new token and retry once
                  final RequestOptions newOptions = req
                    ..headers = Map<String, dynamic>.from(req.headers);
                  newOptions.headers['Authorization'] = 'Bearer $newToken';
                  newOptions.extra = Map<String, dynamic>.from(req.extra)
                    ..['retried'] = true;

                  try {
                    final response = await dio.fetch(newOptions);
                    return handler.resolve(response);
                  } catch (retryErr) {
                    return handler.next(e);
                  }
                }
              }
            } catch (_) {
              // Fall through to original error
            }
          }

          return handler.next(e);
        },
      ),
    );

    if (kDebugMode) {
      client.interceptors.add(ApiLogInterceptor());
    }

    return client;
  }();

  /// Проверка наличия интернета простым GET-запросом
  static Future<bool> hasConnection() async {
    try {
      final response = await dio.get('https://www.google.com/generate_204');
      return response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }
}
