import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passflow_app/auth/bloc/auth_bloc.dart';
import 'package:passflow_app/auth/screens/login_page.dart';
import 'package:passflow_app/utils/network_utils.dart';
import 'package:passflow_app/widgets/page/main_scaffold/main_scaffold.dart';
import 'package:passflow_app/widgets/page/offlineOff.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:passflow_app/widgets/custom_loader.dart';

class SplashScreen extends StatefulWidget {
  final String languageCode;

  const SplashScreen({
    Key? key,
    required this.languageCode,
  }) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _checkConnectionAndInit();
  }

  Future<void> _initLogic() async {
    debugPrint("SplashScreen запущен с языком: ${widget.languageCode}");

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_lang', widget.languageCode);

    final token = prefs.getString('auth_token');

    if (!mounted) return;

    if (token == null) {
      _navigateTo(
        BlocProvider(
          create: (_) => AuthBloc()..add(AppStarted()),
          child: const LoginPage(),
        ),
      );
    } else {
      if (!mounted) return;
      _navigateTo(const MainScaffold());
    }
  }

  Future<void> _checkConnectionAndInit() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    try {
      final result = await NetworkUtils.hasConnection();
      if (result) {
        setState(() => _isOffline = false);
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) _initLogic();
        });
      } else {
        // Нет сети, проверяем токен
        if (token == null) {
          // Нет токена — сразу в логин
          if (mounted) {
            _navigateTo(
              BlocProvider(
                create: (_) => AuthBloc()..add(AppStarted()),
                child: const LoginPage(),
              ),
            );
          }
        } else {
          // Есть токен — показываем оффлайн экран
          setState(() => _isOffline = true);
        }
      }
    } on SocketException catch (_) {
      // Аналогично — если нет сети
      if (token == null) {
        if (mounted) {
          _navigateTo(
            BlocProvider(
              create: (_) => AuthBloc()..add(AppStarted()),
              child: const LoginPage(),
            ),
          );
        }
      } else {
        setState(() => _isOffline = true);
      }
    }
  }

  void _navigateTo(Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isOffline) {
      return OfflineScreen(
        onContinue: () async {
          final result = await InternetAddress.lookup('google.ru');
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            setState(() => _isOffline = false);
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) _initLogic();
            });
          }
        },
        onRetry: () async {
          await _checkConnectionAndInit();
        },
      );
    }

    return const Scaffold(
      body: Center(
        child: ExactDotsLoader(),
      ),
    );
  }
}
