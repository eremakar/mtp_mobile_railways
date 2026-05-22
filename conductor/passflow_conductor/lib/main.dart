import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localization/localization.dart';
import 'package:passflow_app/auth/auth_provider.dart';
import 'package:passflow_app/core/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme_provider.dart';

import 'firebase_options.dart';
import 'auth/bloc/auth_bloc.dart';
import 'data/repositories/auth_repository.dart';
import 'pages/loading_screen.dart';
import 'widgets/notifications/notifications_bloc.dart';
import 'widgets/notifications_badge/notifications_badge_bloc.dart';
import 'core/di/service_locator.dart';
import 'core/services/notification_service.dart';
import 'core/services/task_hive_service.dart';
import 'data/models/notifications_model.dart';
import 'data/models/user_model.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  await _initAfterRun();
  runApp(ChangeNotifierProvider(
      create: (_) => ThemeProvider(), child: const PassflowApp()));
}

Future<void> _initAfterRun() async {
  try {
    await initDependencies();
    await Hive.openBox<NotificationItem>('notificationsBox');
    await Hive.openBox<UserModel>('userBox');
    final userBox = Hive.box<UserModel>('userBox');
    final currentUser = userBox.get('currentUser');
    //Для Дебага
    if (currentUser != null) {
      debugPrint('👤 employeeId: ${currentUser.employeeId}');
    }
    await Hive.openBox('chatHistory');
    await HiveService.initAllHive();
    await NotificationService.init(navigatorKey);
  } catch (e, s) {
    debugPrint('❌ initAfterRun error: $e\n$s');
  }
}

class PassflowApp extends StatefulWidget {
  const PassflowApp({super.key});

  @override
  State<PassflowApp> createState() => PassflowAppState();
}

class PassflowAppState extends State<PassflowApp> {
  static PassflowAppState? _instance;
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _instance = this;
    _loadSavedLocale();
  }

  @override
  void dispose() {
    _instance = null;
    super.dispose();
  }

  /// Смена языка из любого места приложения
  static void setGlobalLocale(Locale locale) {
    _instance?._setLocale(locale);
  }

  /// Устанавливает и сохраняет локаль
  Future<void> _setLocale(Locale locale) async {
    setState(() => _locale = locale);

    final prefs = await SharedPreferences.getInstance();
    final code = "${locale.languageCode}_${locale.countryCode}";
    await prefs.setString('app_language', code);
  }

  /// Загружаем сохранённый язык или ставим дефолтный
  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();

    String raw = prefs.getString('app_language') ?? '';
    Locale chosen;

    if (RegExp(r'^[a-z]{2}_[A-Z]{2}$').hasMatch(raw)) {
      // правильный код сохранён
      final parts = raw.split('_');
      chosen = Locale(parts[0], parts[1]);
    } else {
      // если ничего нет — берём язык системы или fallback
      final device = WidgetsBinding.instance.platformDispatcher.locale;
      if (['ru', 'kk', 'en'].contains(device.languageCode)) {
        chosen = _normalizeDeviceLocale(device);
      } else {
        chosen = const Locale('ru', 'RU');
      }
      await prefs.setString(
          'app_language', "${chosen.languageCode}_${chosen.countryCode}");
    }

    if (!mounted) return;
    setState(() => _locale = chosen);
  }

  Locale _normalizeDeviceLocale(Locale device) {
    switch (device.languageCode) {
      case 'kk':
        return const Locale('kk', 'KZ');
      case 'en':
        return const Locale('en', 'US');
      case 'ru':
      default:
        return const Locale('ru', 'RU');
    }
  }
 @override
//   Widget build(BuildContext context) {
//     LocalJsonLocalization.delegate.directories = ['lib/i18n'];

//     final themeProvider = Provider.of<ThemeProvider>(context);
  Widget build(BuildContext context) {
    LocalJsonLocalization.delegate.directories = ['lib/i18n'];
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: Builder(
        builder: (context) {
          final themeProvider = Provider.of<ThemeProvider>(context);

          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => NotificationBadgeBloc()),
              BlocProvider(create: (_) => NotificationsBloc()),
              BlocProvider<AuthBloc>(
                create: (_) => AuthBloc(authRepository: AuthRepository())
                  ..add(AppStarted()),
              ),
            ],
            child: MaterialApp(
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              title: 'main'.i18n(),
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: themeProvider.themeMode,
              locale: _locale,
              supportedLocales: const [
                Locale('ru', 'RU'),
                Locale('en', 'US'),
                Locale('kk', 'KZ'),
              ],
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                LocalJsonLocalization.delegate,
              ],
              localeResolutionCallback: (locale, supportedLocales) {
                if (_locale != null) return _locale;
                if (locale != null) {
                  for (final l in supportedLocales) {
                    if (l.languageCode == locale.languageCode) {
                      return l;
                    }
                  }
                }
                return const Locale('ru', 'RU');
              },
              home: const LoadingScreen(),
            ),
          );
        },
      ),
    );
  }
}
