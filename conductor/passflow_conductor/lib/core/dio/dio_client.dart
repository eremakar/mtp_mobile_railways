import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:passflow_app/auth/screens/login_page.dart';
import 'package:passflow_app/core/services/logger.dart';
import 'package:passflow_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://185.47.167.26', 
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {'Content-Type': 'application/json'},
    ),
  )..interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');

        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        return handler.next(options);
      },
      onError: (e, handler) async {
  if (e.response?.statusCode == 401) {
     logger.i("Unauthorized. Redirect to login.");
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
     navigatorKey.currentState?.pushAndRemoveUntil(
       MaterialPageRoute(builder: (_) => const LoginPage()),
       (route) => false,
     );
  }
  return handler.next(e);
},
    ));

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
