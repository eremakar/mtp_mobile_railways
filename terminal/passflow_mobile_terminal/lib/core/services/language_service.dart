import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  Locale _currentLocale = const Locale('ru');
  Locale get currentLocale => _currentLocale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('lang') ?? 'ru';
    _currentLocale = Locale(langCode);
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLocale = _currentLocale.languageCode == 'ru'
        ? const Locale('kk')
        : const Locale('ru');
    await prefs.setString('lang', _currentLocale.languageCode);
    notifyListeners();
  }

  Future<void> setLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    _currentLocale = Locale(langCode);
    await prefs.setString('lang', langCode);
    notifyListeners();
  }
}
