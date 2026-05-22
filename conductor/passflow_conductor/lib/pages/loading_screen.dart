import 'package:flutter/material.dart';
import 'package:passflow_app/auth/bloc/auth_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:passflow_app/pages/set_language.dart';
import 'package:passflow_app/pages/splash_screen.dart';
import 'package:passflow_app/pages/user_agreement.dart';
import 'package:passflow_app/pages/interface_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool _routed = false; // guard to prevent double navigation

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _decideWhereToGo());
  }

  bool _isValidRegional(String? code) {
    if (code == null || code.isEmpty) return false;
    return code == 'ru_RU' || code == 'kk_KZ' || code == 'en_US';
  }

  bool _isValidShort(String? code) {
    if (code == null || code.isEmpty) return false;
    return code == 'ru' || code == 'kk' || code == 'en';
  }

  Future<void> _decideWhereToGo() async {
    if (_routed) return; // already navigating, ignore
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;

      // --- Проверка языка ---
      final languageChosen = prefs.getBool('language_chosen') ?? false;
      final appLang = prefs.getString('app_language'); // ru_RU / kk_KZ / en_US
      final shortLang = prefs.getString('selected_lang'); // ru / kk / en
      final looksLikeLabel =
          ['Русский', 'Қазақша', 'English'].contains(appLang);
      final needChooseLanguage = !languageChosen ||
          (!_isValidRegional(appLang) && !_isValidShort(shortLang)) ||
          looksLikeLabel;

      if (needChooseLanguage) {
        await prefs.remove('app_language');
        await prefs.remove('selected_lang');
        _routed = true;
        return _go(const SetLanguage());
      }

      final lang = _isValidShort(shortLang)
          ? shortLang!
          : (_isValidRegional(appLang) ? appLang!.split('_').first : 'ru');

      final accepted = prefs.getBool('accepted_terms') ?? false;
      if (!accepted) {
        _routed = true;
        return _go(const UserAgreementPage());
      }

      final themeKey = prefs.getString('app_theme');
      if (themeKey == null) {
        _routed = true;
        return _go(const InterfaceThemePage());
      }

      context.read<AuthBloc>().add(AppStarted());
      _routed = true;
      _go(SplashScreen(languageCode: lang));
    } catch (_) {
      if (!mounted) return;
      _routed = true;
      _go(const SetLanguage());
    }
  }

  void _go(Widget page) {
    if (!mounted) return;
    if (_routed) {
      Navigator.of(context, rootNavigator: true).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 220),
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
      return;
    }
    // In practice _routed is already set by callers; keep method idempotent.
    Navigator.of(context, rootNavigator: true).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
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
        ],
      ),
    );
  }
}
