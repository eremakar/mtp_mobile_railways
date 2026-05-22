import 'dart:convert';
import 'package:passflow_app/core/dio/dio_client.dart';
import 'package:passflow_app/services/logger.dart';

class BoardingsRepo {
  /// Получить данные для выпадающих списков: поезда, даты, вагоны и карта поезд->classId, поезд->даты
  Future<Map<String, dynamic>> getBoardingDropdownValues(
      num routeSheetId) async {
    try {
      final response = await DioClient.dio.post(
        '/api/v1/routesheets/search',
        data: jsonEncode({
          "filter": {
            "id": {"operand1": routeSheetId, "operator": 1}
          }
        }),
      );

      if (response.statusCode == 200) {
        final result = response.data['result'];
        if (result is List && result.isNotEmpty) {
          final trains = <String>{};
          final dates = <String>{};
          final carOrders = <String>{};
          final Map<String, int> trainToClassId = {};
          final Map<String, Set<String>> trainToDates = {};

          for (final item in result) {
            final classObj = item['class'] ?? {};
            final trainName1 = classObj['trainName1'];
            final trainName2 = classObj['trainName2'];
            final classId = item['classId'] as int?;

            if (trainName1 != null) {
              trains.add(trainName1);
              if (classId != null) trainToClassId[trainName1] = classId;
            }
            if (trainName2 != null) {
              trains.add(trainName2);
              if (classId != null) trainToClassId[trainName2] = classId;
            }

            final startTime = item['routeStartTime'] ?? item['comeTime'];
            if (startTime != null) {
              final dateStr = startTime.toString().substring(0, 10);
              dates.add(dateStr);

              if (trainName1 != null) {
                trainToDates
                    .putIfAbsent(trainName1, () => <String>{})
                    .add(dateStr);
              }
              if (trainName2 != null) {
                trainToDates
                    .putIfAbsent(trainName2, () => <String>{})
                    .add(dateStr);
              }
            }

            final items = item['items'] as List?;
            if (items != null) {
              for (final car in items) {
                final order = car['order'];
                if (order != null)
                  carOrders.add(order.toString().padLeft(2, '0'));
              }
            }
          }

          return {
            'trains': trains.toList(), //--
            'dates': dates.toList(), //--
            'carOrders': carOrders,
            'trainToClassId': trainToClassId, //--
            'trainToDates':
                trainToDates.map((k, v) => MapEntry(k, v.toList())), //--
          };
        }
      }
      return {};
    } catch (e, s) {
      logger.e('❌ Ошибка поиска маршрутов: $e\n$s');
      return {};
    }
  }
}
