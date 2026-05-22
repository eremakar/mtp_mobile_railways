import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class NetworkUtils {
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
