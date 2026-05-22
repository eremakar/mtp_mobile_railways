import 'package:flutter/material.dart';
import 'package:passflow_app/core/services/task_hive_service.dart';

class UserProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _userName = '';

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;

  void login(String name) {
    _userName = name;
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    _userName = '';
    _isLoggedIn = false;

    notifyListeners();
  }

  // ✅ Добавьте этот метод, если вы его используете
  Future<void> setLoggedIn(bool value) async {
    _isLoggedIn = value;
    await HiveService.clear();
    notifyListeners();
  }
}
