import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:passflow_app/core/dio/dio_client.dart';
import 'package:passflow_app/core/services/logger.dart';
import 'package:passflow_app/data/models/route_model/employ_modal.dart';

class EmployeeStatisticsRepository {
  Future<List<EmployeeStatisticsModel>?> getStatistics({
    required int employeeId,
    required int month,
    required int year,
  }) async {
    try {
      var lastDayMonth = DateTime(year, month + 1, 0);
      final formatted = DateFormat('yyyy-MM-dd').format(lastDayMonth);
      final response = await DioClient.dio.post(
        '/employees/api/v1/EmployeeStatistics/search',
        data: json.encode({
          "filter": {
            "employeeId": {"operand1": employeeId, "operator": 1},
            "month": {
              "operand1": "$year-$month-01",
              "operand2": formatted,
              "operator": 7
            }
          },
        }),
      );
      if (response.statusCode == 200) {
        final List list = response.data['result'] as List;
        return list.map((e) => EmployeeStatisticsModel.fromJson(e)).toList();
      } else {
        logger.i('⚠️ Unexpected status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      logger.i('Employee statistics fetch error: $e');
      return null;
    }
  }

  Future<List<dynamic>?> getRouteSheetEmployees(
      {required int employeeId}) async {
    try {
      final response = await DioClient.dio.post(
        '/routesheets/api/v1/routeSheetEmployees/search',
        data: json.encode({
          "filter": {
            "employeeId": {"operand1": employeeId, "operator": 1}
          }
        }),
      );

      if (response.statusCode == 200) {
        final List list = response.data['result'] as List;
        return list;
      } else {
        logger.i('⚠️ Unexpected status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      logger.i('RouteSheetEmployees fetch error: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getTripStatistics({
    required int employeeId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await DioClient.dio.post(
        '/routesheets/api/v1/routeSheetEmployees/search',
        data: json.encode({
          "filter": {
            "employeeId": {"operand1": employeeId, "operator": 1},
            "arriveTime": {
              "operand1": DateFormat('yyyy-MM-dd').format(startDate),
              "operand2": DateFormat('yyyy-MM-dd').format(endDate),
              "operator": 7
            }
          }
        }),
      );

      if (response.statusCode == 200) {
        final List list = response.data['result'] as List;
        return list.map<Map<String, dynamic>>((e) {
          final route = e['routeSheet'];
          logger.i('RouteSheet object: $route');
          logger.i('RouteSheet name: ${route?['name']}');
          return {
            'routeSheet': route,
            'arriveTime': e['arriveTime'],
            'leaveTime': e['leaveTime'],
            'workedHours': e['workedHours'] ?? 0.0,
          };
        }).toList();
      } else {
        logger.i('⚠️ Unexpected status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      logger.i('Trip statistics fetch error: $e');
      return null;
    }
  }
}
