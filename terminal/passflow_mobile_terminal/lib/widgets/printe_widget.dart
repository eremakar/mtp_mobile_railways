import 'package:flutter/services.dart';

class PrinterHelper {
  static const MethodChannel _channel = MethodChannel('printer_channel');

  static Future<void> printTextAndBarcode(String text, String barcode) async {
    try {
      await _channel.invokeMethod('printTextAndBarcode', {
        'text': text,
        'barcode': barcode,
      });
    } on PlatformException catch (e) {
      print('Ошибка печати: ${e.message}');
    }
  }
}