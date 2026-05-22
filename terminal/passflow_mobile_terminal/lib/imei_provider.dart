import 'package:flutter/services.dart';

class ImeiProvider {
  static const _ch = MethodChannel('device_ids');

  static Future<List<String>> getImeis() async {
    try {
      final res = await _ch.invokeMethod<List<dynamic>>('getImeis');
      return (res ?? []).map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    } on PlatformException {
      return [];
    }
  }
}