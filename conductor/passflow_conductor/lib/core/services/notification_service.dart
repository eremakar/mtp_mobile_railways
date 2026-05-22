import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:passflow_app/widgets/notifications/notification_screen.dart';
import 'package:passflow_app/widgets/notifications/notifications_bloc.dart';
import 'package:passflow_app/widgets/notifications/notifications_event.dart';
import 'package:provider/provider.dart';

class NotificationService {
  static final _ln = FlutterLocalNotificationsPlugin();
  static late GlobalKey<NavigatorState> _navigatorKey;
  static bool _isInitialized = false;

  static Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
    _navigatorKey = navigatorKey;

    if (!_isInitialized) {
      await _ln.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
        onDidReceiveNotificationResponse: (response) {
          debugPrint('Нажато уведомление с payload: ${response.payload}');
          if (response.payload == 'open_notifications') {
            _navigateToNotificationsScreen();
          }
        },
      );
      _isInitialized = true;
    }

    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(alert: true, badge: true, sound: true);

    final token = await messaging.getToken();
    debugPrint('📱 FCM token: $token');

    FirebaseMessaging.onBackgroundMessage(_bgHandler);

    final initialMsg = await messaging.getInitialMessage();
    if (initialMsg != null) {
      debugPrint('🚀 Запуск из уведомления');
      _navigateToNotificationsScreen();
    }

    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      debugPrint('👉 TAP на системное уведомление');
      _navigateToNotificationsScreen();
    });

    FirebaseMessaging.onMessage.listen((msg) async {
      debugPrint('🔥 Foreground push получен: ${msg.notification?.title}');
      await _showLocalNotification(msg);
        _navigatorKey.currentContext?.read<NotificationsBloc>().add(PushArrived(msg));
    });
  }

  static Future<void> _showLocalNotification(RemoteMessage msg) async {
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000; 
    await _ln.show(
      id,
      msg.notification?.title ?? 'Новое уведомление',
      msg.notification?.body ?? '',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'push_channel',
          'Push уведомления',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: 'open_notifications',
    );
  }

  static Future<void> _bgHandler(RemoteMessage message) async {
    debugPrint('🌙 Фоновое сообщение: ${message.messageId}');
  }

static void _navigateToNotificationsScreen() {
  final state = _navigatorKey.currentState;
  if (state != null) {
    debugPrint('✅ Переход на NotificationsScreen');
    state.push(
      MaterialPageRoute(
        builder: (_) => const NotificationsScreen(),
      ),
    ).then((_) {
      debugPrint('⬅ NotificationsScreen закрыт');
    });
  }
}
}