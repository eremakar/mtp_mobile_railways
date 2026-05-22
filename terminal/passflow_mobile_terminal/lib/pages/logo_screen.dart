import 'package:flutter/material.dart';
import 'package:passflow_app/core/services/auto_submit_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:passflow_app/pages/splash_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {

  @override
  void initState() {
    super.initState();
    // Запускаем логику только после отрисовки первого кадра (логотип сразу виден)
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _initLogic();
      AutoSubmitService.trySubmitCachedAnswers();
    });
  }

  Future<void> _initLogic() async {
    await Future.delayed(const Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();
    final selectedLang = prefs.getString('selected_lang') ?? 'ru';
    await prefs.setString('selected_lang', selectedLang);

    if (!mounted) return;
    _navigateToSplash(selectedLang);
  }

  void _navigateToSplash(String languageCode) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => SplashScreen(languageCode: languageCode),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: SizedBox.expand(
          child: Image.asset(
            'assets/images/Splashscreen.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
