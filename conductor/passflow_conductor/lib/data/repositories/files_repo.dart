import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:passflow_app/core/dio/dio_client.dart';

class FilesRepository {
  Future<File> downloadToTemp({
    required String key,
    required String fileName,
  }) async {
    final encodedKey = Uri.encodeComponent(key);

    final resp = await DioClient.dio.get<List<int>>(
      '/documents/api/v1/files/$encodedKey', 
      options: Options(
        responseType: ResponseType.bytes,
        validateStatus: (status) => status != null && status < 600,
        headers: const {
          'Accept': 'application/octet-stream',
        },
      ),
    );

    final status = resp.statusCode ?? 0;
    if (status != 200) {
      String? bodyPreview;
      try {
        final data = resp.data;
        if (data != null && data.isNotEmpty) {
          final text = String.fromCharCodes(data);
          bodyPreview = text.length > 300 ? text.substring(0, 300) : text;
        }
      } catch (_) {}

      throw Exception(
        'Не удалось скачать файл. HTTP $status${bodyPreview != null ? "\n$bodyPreview" : ""}',
      );
    }

    final bytes = Uint8List.fromList(resp.data ?? const <int>[]);
    final dir = await getTemporaryDirectory();
    final safeName = fileName.isEmpty ? 'file' : fileName;
    final file = File('${dir.path}/$safeName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}