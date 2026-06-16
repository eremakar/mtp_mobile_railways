import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:passflow_app/core/dio/dio_client.dart';
import 'package:passflow_app/data/models/train_directions_response.dart';
import 'package:passflow_app/utils/network_utils.dart';

class TrainDirectionsRepository {
  TrainDirectionsResponse? _anyCached(
      Box<TrainDirectionsResponse> box) {
    for (final key in box.keys) {
      final value = box.get(key);
      if (value != null && value.result.isNotEmpty) return value;
    }
    return null;
  }

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
    var cached = trainDirectionBox.get(filialId);
    cached ??= _anyCached(trainDirectionBox);

    final hasNet = await NetworkUtils.isNetworkAvailable();
    if (!hasNet) {
      return cached ?? _anyCached(trainDirectionBox);
    }

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
      return cached ?? _anyCached(trainDirectionBox);
    } catch (e) {
      return cached ?? _anyCached(trainDirectionBox);
    }
  }
}
