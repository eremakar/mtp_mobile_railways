import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class LiveActivityController {
  static Future<void> start() async {
    if (kDebugMode) {
      print('LiveActivityController.start() вызван');
    }

    FlutterForegroundTask.startService(
  notificationTitle: 'Следующий маршрут',
  notificationText: 'Астана → Алматы через 5 ч 35 мин',
  callback: startCallback,
);
  }

  static Future<void> stop() async {
    if (kDebugMode) {
      print('LiveActivityController.stop() вызван');
    }
    await FlutterForegroundTask.stopService();
  }
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

@pragma('vm:entry-point')
class MyTaskHandler extends TaskHandler {
  @override
  void onStart(DateTime timestamp) {
    if (kDebugMode) print('Foreground service started');
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    FlutterForegroundTask.updateService(
  notificationTitle: 'Актуальное обновление',
  notificationText: 'Новое время прибытия: 4 ч 50 мин',
);
  }

  @override
  void onDestroy(DateTime timestamp) {
    if (kDebugMode) print('Foreground service stopped');
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp('/');
  }
}
