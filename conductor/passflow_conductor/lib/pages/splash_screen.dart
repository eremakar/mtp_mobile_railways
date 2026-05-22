import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:passflow_app/auth/screens/login_page.dart';
import 'package:passflow_app/widgets/custom_loader.dart';
import 'package:passflow_app/widgets/main_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  final String languageCode;
  const SplashScreen({super.key, required this.languageCode});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isTokenValid(String? token) {
    if (token == null) return false;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final payloadMap = json.decode(payload);
      final exp = payloadMap['exp'];
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return exp != null && now < exp;
    } catch (e) {
      debugPrint('Ошибка проверки токена: $e');
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _checkPin();
  }

  Future<void> _checkPin() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (!mounted) return;

    if (token == null || !_isTokenValid(token)) {
      await prefs.remove('auth_token');
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => (MainScaffold())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image(
              image: AssetImage('assets/images/Splashscreen.png'),
              fit: BoxFit.cover,
            ),
          ),
          Center(child: DotCircleLoader()),
        ],
      ),
    );
  }
}