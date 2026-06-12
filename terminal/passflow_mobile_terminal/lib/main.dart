import 'dart:async';
import 'dart:ui';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:passflow_app/auth/auth_provider.dart';
import 'package:passflow_app/core/di/service_locator.dart';
import 'package:passflow_app/core/services/language_service.dart';
import 'package:passflow_app/core/services/task_hive_service.dart';
import 'package:passflow_app/data/models/user_model.dart';
import 'package:passflow_app/imei_provider.dart';
import 'package:passflow_app/l10n/app_localizations.dart';
import 'package:passflow_app/pages/boardings_list/bloc/list_bloc.dart';
import 'package:passflow_app/pages/boardings_list/bloc/list_event.dart';
import 'package:passflow_app/pages/logo_screen.dart';
import 'package:passflow_app/utils/network_utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();

  await HiveService.initAllHive();
  await loadAndSaveImeis();
  final user = Hive.box<UserModel>('userBox');
  if (user.get('currentUser')?.id != null) {
    Connectivity().onConnectivityChanged.listen((results) async {
      final hasInterface = results.any((r) =>
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.ethernet ||
          r == ConnectivityResult.vpn ||
          r == ConnectivityResult.other);

      if (hasInterface) {
        if (await NetworkUtils.hasConnection()) {
          await HiveService.syncRouteSheetsFromApi();
        }
      }
    });
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageService()..load()),
        ChangeNotifierProvider(
          create: (_) =>
              UserProvider()..login(user.get('currentUser')?.name ?? ''),
        ),
        BlocProvider<BoardingsListBloc>(
            create: (context) => BoardingsListBloc()..add(InitTicketsEvent()))
      ],
      child: const MyApp(),
    ),
  );
}

Future<List<String>> loadAndSaveImeis() async {
  // 1. Получаем IMEI(и)
  final imei = await ImeiProvider.getImeis();

  if (imei.isEmpty) {
    final deviceInfo = DeviceInfoPlugin();
    final info = await deviceInfo.androidInfo;
    imei.add(info.id); // fallback, если imei нет
  }

  // 2. Открываем box (тип можно оставить dynamic)
  final box = await Hive.openBox('deviceBox');

  // 3. Сохраняем список IMEI
  await box.put('imeis', imei);

  return imei;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          locale: context.watch<LanguageService>().currentLocale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          title: 'Главная страница',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.deepPurple,
            fontFamily: 'Arial',
          ),
          home: child,
        );
      },
      child: const LoadingScreen(),
    );
  }
}
