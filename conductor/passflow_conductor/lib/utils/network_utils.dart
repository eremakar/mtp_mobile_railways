import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkUtils {
  /// Надёжная проверка наличия подключения к интернету
  static Future<bool> hasConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    final hasNetwork = connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.ethernet;

    if (!hasNetwork) return false;

    // Доп. проверка — доступен ли интернет (через DNS или HTTP)
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
