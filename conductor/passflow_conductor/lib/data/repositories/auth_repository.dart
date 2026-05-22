import 'package:passflow_app/core/dio/dio_client.dart';
import 'package:passflow_app/core/services/logger.dart';
import 'package:passflow_app/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  Future<bool> login(String username, String password) async {
    try {
      final response = await DioClient.dio.post('/auth/login', data: {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['accessToken'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', token);
        return true;
      }
    } catch (e) {
       logger.i('Login error: $e');
    }
    return false;
  }

  Future<UserModel?> getProfile() async {
    try {
      final response = await DioClient.dio.get('/profile');
      return UserModel.fromJson(response.data);
    } catch (e) {
       logger.i('Profile fetch error: $e');
      return null;
    }
  }
}
