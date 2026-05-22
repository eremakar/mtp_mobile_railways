// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';

// class LiveActivityController {
//   static const MethodChannel _channel = MethodChannel('live_activity');

//   /// Запуск Live Activity
//   Future<void> startActivity(Map<String, dynamic> data) async {
//     try {
//       await _channel.invokeMethod('startLiveActivity', data);
//     } on PlatformException catch (e) {
//       if (kDebugMode) {
//         print("Ошибка при запуске Live Activity: '${e.message}'.");
//       }
//     }
//   }

//   /// Обновление Live Activity
//   Future<void> updateActivity(Map<String, dynamic> data) async {
//     try {
//       await _channel.invokeMethod('updateLiveActivity', data);
//     } on PlatformException catch (e) {
//       if (kDebugMode) {
//         print("Ошибка при обновлении Live Activity: '${e.message}'.");
//       } 
//     }
//   }

//   /// Завершение Live Activity
//   Future<void> endActivity() async {
//     try {
//       await _channel.invokeMethod('endLiveActivity');
//     } on PlatformException catch (e) {
//       if (kDebugMode) {
//         print("Ошибка при завершении Live Activity: '${e.message}'.");
//       }
//     }
//   }
// }
