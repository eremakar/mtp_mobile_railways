import 'dart:convert';

import 'package:passflow_app/core/dio/dio_client.dart';

class TaskRepository {

  Future<dynamic> bulk(List<Map<String, dynamic>> data) async {
    try {
      final response =
          await DioClient.dio.post('/api/v1/tasks/bulk', data: data);
      return response.data;
    } catch (e) {
      print(jsonEncode(data));
      print(
          '📤 Sending to bulk endpoint: ${data.map((e) => e.toString()).toList()}');
      print('Ошибка отправки: $e');
      return null;
    }
  }

}
