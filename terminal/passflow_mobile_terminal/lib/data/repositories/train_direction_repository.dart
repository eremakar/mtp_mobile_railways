import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:passflow_app/core/dio/dio_client.dart';
import 'package:passflow_app/data/models/train_directions_response.dart';

class TrainDirectionsRepository {
  Future<TrainDirectionsResponse?> searchByFilial({
    required int filialId,
  }) async {
    // if (kDebugMode) filialId = 9;
    final body = {
      "filter": {
        "routeClass": {
          "filialId": {"operand1": filialId, "operator": 1}
        }
      }
    };

    final trainDirectionBox =
        Hive.box<TrainDirectionsResponse>('train_directions');
    try {
      final response = await DioClient.dio
          .post('/api/v1/trainDirections/search', data: body);
      if (response.statusCode == 200) {
        if (response.data is Map<String, dynamic>) {
          final result = TrainDirectionsResponse.fromJson(
            response.data as Map<String, dynamic>,
          );
          // Сохраняем в кеш по ключу filialId
          await trainDirectionBox.put(filialId, result);
          return result;
        } else {
          print('Unexpected response format: ${response.data.runtimeType}');
        }
      }
      // Если статус не 200, попытаться вернуть кешированное значение
      final cached = trainDirectionBox.get(filialId);
      return cached;
    } catch (e) {
      final cached = trainDirectionBox.get(filialId);
      return cached;
    }
  }
}
