import 'package:shared_preferences/shared_preferences.dart';

class PinCodeModel {
  static const _kPinKey = 'pin_code';
  static const _kEnabledKey = 'is_pin_enabled';

  final int length;
  final bool enabled;

  const PinCodeModel({this.length = 4, this.enabled = false});

  static Future<PinCodeModel> load() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_kEnabledKey) ?? false;
    return PinCodeModel(enabled: enabled);
  }

  static Future<void> savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPinKey, pin);
    await prefs.setBool(_kEnabledKey, true);
  }

  static Future<bool> verify(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kPinKey);
    return saved != null && saved == pin;
  }

  static Future<void> disable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPinKey);
    await prefs.setBool(_kEnabledKey, false);
  }
}