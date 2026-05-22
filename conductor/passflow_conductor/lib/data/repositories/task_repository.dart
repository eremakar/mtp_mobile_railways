import 'dart:convert';

import 'package:passflow_app/core/dio/dio_client.dart';
import 'package:passflow_app/core/services/logger.dart';

class TaskRepository {

  Future<dynamic> bulk(List<Map<String, dynamic>> data) async {
    try {
      final response =
          await DioClient.dio.post('/tasks/api/v1/tasks/bulk', data: data);
      return response.data;
    } catch (e) {
      logger.i(jsonEncode(data));
      logger.i(
          '📤 Sending to bulk endpoint: ${data.map((e) => e.toString()).toList()}');
      logger.i('Ошибка отправки: $e');
      return null;
    }
  }
}
