import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:passflow_app/core/dio/dio_client.dart';

class PdfRepository {
  Future<Uint8List?> generatePdf({
    required String templateName,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await DioClient.dio.post(
        '/pdf/api/pdf/generate',
        data: {
          'templateName': templateName,
          'data': data,
        },
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        final rawBytes = response.data;
        if (rawBytes is Uint8List) {
          return rawBytes;
        }
        final bytes = List<int>.from(rawBytes as List);
        return Uint8List.fromList(bytes);
      }
      debugPrint('Unexpected PDF status code: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('PDF generation error: $e');
      return null;
    }
  }
}
