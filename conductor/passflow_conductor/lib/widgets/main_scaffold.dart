import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:passflow_app/data/models/user_model.dart';
import 'package:passflow_app/feature/pin/pin_create_flow_page.dart';
import 'package:passflow_app/feature/pin/pin_unlock_page.dart';
import 'package:passflow_app/pages/ai_chatbot/ai_chat_webview.dart';
import 'package:passflow_app/pages/bottom_nagivation.dart';
import 'package:passflow_app/pages/detail_page.dart';
import 'package:passflow_app/pages/insigned_home/insigned_home_page.dart';
import 'package:passflow_app/pages/menu.dart';
import 'package:passflow_app/pages/schedule_page.dart';
import 'package:passflow_app/pages/services_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:passflow_app/pages/splash_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  int _currentIndex = 0;

  final List<String> _tabs = [
    '/home',
    '/schedule',
    '/requests',
    '/menu',
    '/chat',
  ];

  @override
  void initState() {
    super.initState();
    _checkPin();
  }

  Future<void> _checkPin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final savedPin =
        prefs.getString('pin_code') ?? prefs.getString('pin') ?? '';
    final pinEnabled = prefs.getBool('is_pin_enabled') ?? false;

    final nav = Navigator.of(context, rootNavigator: true);

    if (savedPin.isEmpty || !pinEnabled) {
      await nav.push(
        MaterialPageRoute(builder: (_) => const PinCreateFlowPage()),
      );
      await prefs.setBool('is_pin_enabled', true);
      return;
    }

    final ok = await nav.push<bool>(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, __, ___) => const PinUnlockPage(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );

    if (!mounted) return;

    if (ok != true) {
      nav.pushReplacement(
        MaterialPageRoute(
          builder: (_) => const SplashScreen(languageCode: 'ru'),
        ),
      );
    }
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) {
      _navigatorKey.currentState!.popUntil((route) => route.isFirst);
    } else {
      setState(() => _currentIndex = index);
      _navigatorKey.currentState!.pushReplacementNamed(_tabs[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    var userId =
        Hive.box<UserModel>('userBox').get('currentUser')?.employeeId ?? 0;
    return Scaffold(
      body: Navigator(
        key: _navigatorKey,
        initialRoute: _tabs[_currentIndex],
        onGenerateRoute: (settings) {
          Widget page;
          switch (settings.name) {
            case '/home':
              page = const TrainHomePage();
              break;
            case '/schedule':
              page = SchedulePage(employeeId: userId);
              break;
            case '/requests':
              page = const ServicesPage();
              break;
            case '/menu':
              page = const MenuPage();
              break;
            // case '/chat':
            //   page = BlocProvider(
            //     create: (_) => AiBloc(AiRepository()),
            //     child: const AiAssistantsPage(),
            //   );
            //   break;
            case '/chat':
              page = const ChatWebViewPage();
              break;
            case '/detail':
              page = const TrainRouteDetailPage(
                routeTitle: '3/4 Астана - Алматы',
                noteLabel: 'Началась подготовка к рейсу',
              );
              break;
            default:
              page = const TrainHomePage();
          }
          return PageRouteBuilder(
            settings: settings,
            pageBuilder: (context, animation, secondaryAnimation) => page,
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
