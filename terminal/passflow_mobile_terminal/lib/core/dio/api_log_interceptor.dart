import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Логирует URL, тело запроса и ответ (только в debug, с усечением).
class ApiLogInterceptor extends Interceptor {
  static const _encoder = JsonEncoder.withIndent('  ');
  static const _maxBodyLogLength = 1000;

  static String _truncate(String text) {
    if (text.length <= _maxBodyLogLength) return text;
    return '${text.substring(0, _maxBodyLogLength)}… '
        '[truncated, ${text.length} chars total]';
  }

  static String _formatBody(dynamic value) {
    return _truncate(_format(value));
  }

  static String _format(dynamic value) {
    if (value == null) return 'null';
    try {
      if (value is String) {
        final decoded = jsonDecode(value);
        return _encoder.convert(decoded);
      }
      return _encoder.convert(value);
    } catch (_) {
      return value.toString();
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('── HTTP REQUEST ──────────────────────────────');
    debugPrint('${options.method} ${options.uri}');
    if (options.data != null) {
      debugPrint('body:\n${_formatBody(options.data)}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('── HTTP RESPONSE ─────────────────────────────');
    debugPrint(
      '${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}',
    );
    debugPrint('body:\n${_formatBody(response.data)}');
    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    debugPrint('── HTTP ERROR ────────────────────────────────');
    debugPrint(
      '${err.response?.statusCode ?? "?"} ${err.requestOptions.method} ${err.requestOptions.uri}',
    );
    if (err.requestOptions.data != null) {
      debugPrint('request body:\n${_formatBody(err.requestOptions.data)}');
    }
    if (err.response?.data != null) {
      debugPrint('response body:\n${_formatBody(err.response?.data)}');
    } else {
      debugPrint('message: ${err.message}');
    }
    handler.next(err);
  }
}
