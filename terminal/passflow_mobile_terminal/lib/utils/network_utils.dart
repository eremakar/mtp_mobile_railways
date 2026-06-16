import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NetworkUtils {
  static const _forceOfflineKey = 'force_offline_mode';
  static bool forceOffline = false;

  static Future<void> loadOfflineMode() async {
    final prefs = await SharedPreferences.getInstance();
    forceOffline = prefs.getBool(_forceOfflineKey) ?? false;
  }

  static Future<void> setForceOffline(bool value) async {
    forceOffline = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_forceOfflineKey, value);
  }

  /// Учитывает принудительный офлайн-режим приложения.
  static Future<bool> isNetworkAvailable() async {
    if (forceOffline) return false;
    return hasConnection();
  }

  static Future<bool> hasConnection({
    Duration timeout = const Duration(seconds: 3),
    int maxAttempts = 2,
  }) async {
    final results = await Connectivity().checkConnectivity();

    final connected = results.any((r) =>
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet ||
        r == ConnectivityResult.vpn ||
        r == ConnectivityResult.other);
    if (kDebugMode) return connected;
    // if (!connected) return false;
    return connected;

    // final dnsHosts = <String>[
    //   'google.com',
    //   'one.one.one.one', // Cloudflare
    //   'cloudflare.com',
    // ];

    // for (var attempt = 0; attempt < maxAttempts; attempt++) {
    //   // 1) DNS lookup
    //   for (final host in dnsHosts) {
    //     try {
    //       final res = await InternetAddress.lookup(host)
    //           .timeout(timeout, onTimeout: () => const <InternetAddress>[]);
    //       if (res.isNotEmpty && res.first.rawAddress.isNotEmpty) {
    //         return true;
    //       }
    //     } catch (_) {
    //       // игнорируем и пробуем следующий хост
    //     }
    //   }
    // }

    // return false;
  }

  /// Утилита: ждём появления онлайна с интервалом опроса.
  static Future<bool> waitForOnline({
    Duration checkInterval = const Duration(seconds: 2),
    Duration overallTimeout = const Duration(seconds: 20),
  }) async {
    final start = DateTime.now();
    while (DateTime.now().difference(start) < overallTimeout) {
      if (await hasConnection()) return true;
      await Future.delayed(checkInterval);
    }
    return false;
  }
}
