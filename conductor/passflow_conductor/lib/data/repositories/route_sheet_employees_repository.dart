import 'dart:convert';

import 'package:passflow_app/core/cache/route_sheet_search_cache.dart';
import 'package:passflow_app/core/dio/dio_client.dart';
import 'package:passflow_app/core/services/logger.dart';
import 'package:passflow_app/data/models/routeSheetEmployees/route_sheet_employee_model.dart';
import 'package:passflow_app/data/models/route_model/route_card_model.dart';
import 'package:passflow_app/data/models/route_sheet_model.dart';

class RouteSheetEmployeesRepository {
  Future<List<RouteSheetModel>?> searchByEmployeeId(int employeeId) async {
    try {
      final response = await DioClient.dio.post(
        '/routesheets/api/v1/routeSheetEmployees/search',
        data: json.encode({
          "filter": {
            "employeeId": {"operand1": employeeId, "operator": 1}
          }
        }),
      );
      return routeSheetModelsFromJson(response.data['result']);
    } catch (e) {
      logger.i('❌ Ошибка загрузки маршрутов: $e');
      return null;
    }
  }

  Future<List<RouteCardModel>?> searchRouteSheets({
    int? employeeId,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final response = await DioClient.dio
          .post('/routeSheets/api/v1/routeSheetEmployees/search',
              data: json.encode({
                "filter": {
                  "employeeId": {"operand1": employeeId, "operator": 1},
                },
              }));
      if (response.statusCode == 200) {
        final List list = response.data['result'] as List;
        return list
            .map((e) => RouteCardModel.fromJson(e["routeSheet"]))
            .toList();
      } else {
        logger.i('⚠️ Unexpected status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      logger.i('RouteSheets fetch error: $e');
      return null;
    }
  }

  Future<List<RouteSheetEmployeeModel>?> searchEmployeeRouteSheets({
    int? employeeId,
    String? fromDate,
    String? toDate,
  }) async {
    final cacheKey =
        'searchEmployeeRouteSheets:$employeeId:$fromDate:$toDate';
    final cached =
        RouteSheetSearchCache.get<List<RouteSheetEmployeeModel>>(cacheKey);
    if (cached != null) return cached;

    try {
      final response = await DioClient.dio
          .post('/routeSheets/api/v1/routeSheetEmployees/search',
              data: json.encode({
                "filter": {
                  "employeeId": {"operand1": employeeId, "operator": 1},
                },
              }));
      if (response.statusCode == 200) {
        final List list = response.data['result'] as List;
        final parsed =
            list.map((e) => RouteSheetEmployeeModel.fromJson(e)).toList();
        RouteSheetSearchCache.set(cacheKey, parsed);
        return parsed;
      } else {
        logger.i('⚠️ Unexpected status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      logger.i('RouteSheets fetch error: $e');
      return null;
    }
  }

  Future<List<RouteSheetEmployeeModel>> searchRouteSheetEmployees({
    int? employeeId,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final Map<String, dynamic> filter = {};
      if (employeeId != null) {
        filter['employeeId'] = {"operand1": employeeId, "operator": 1};
      }
      if (fromDate != null && toDate != null) {
        filter['leaveTime'] = {
          "operand1": fromDate,
          "operand2": toDate,
          "operator": 7
        };
      }

      final response = await DioClient.dio.post(
        '/routesheets/api/v1/routeSheetEmployees/search',
        data: json.encode({
          "filter": filter,
        }),
      );
      if (response.statusCode == 200) {
        final List list = response.data['result'] as List;
        return list.map((e) => RouteSheetEmployeeModel.fromJson(e)).toList();
      } else {
        logger.i('⚠️ Unexpected status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      logger.i('RouteSheetEmployees fetch error: $e');
      return [];
    }
  }
  // LU72:
  Future<List<RouteSheetEmployeeModel>> lu72SearchRouteSheetEmployeesByRouteSheetId({
    required int routeSheetId,
  }) async {
    try {
      final Map<String, dynamic> filter = {
        'routeSheetId': {"operand1": routeSheetId, "operator": 1},
      };

      final response = await DioClient.dio.post(
        '/routesheets/api/v1/routeSheetEmployees/search',
        data: json.encode({"filter": filter}),
      );

      if (response.statusCode == 200) {
        final List list = response.data['result'] as List;
        return list.map((e) => RouteSheetEmployeeModel.fromJson(e)).toList();
      }

      logger.i('⚠️ Unexpected status code: ${response.statusCode}');
      return [];
    } catch (e) {
      logger.i('LU72 RouteSheetEmployees by routeSheetId fetch error: $e');
      return [];
    }
  }

  Future<int?> lu72GetRouteClassIdByRouteSheetId({
    required int routeSheetId,
  }) async {
    final list = await lu72SearchRouteSheetEmployeesByRouteSheetId(
      routeSheetId: routeSheetId,
    );
    if (list.isEmpty) return null;
    for (final x in list) {
      final rcId = x.routeSheetItem.wagon?.routeClassId;
      if (rcId != null) return rcId;
    }
    return null;
  }

  Future<List<RouteSheetEmployeeModel>> lu72SearchActiveRouteSheetEmployees({
    required int employeeId,
    int state2Id = 3,
  }) async {
    try {
      final Map<String, dynamic> filter = {
        'employeeId': {"operand1": employeeId, "operator": 1},
      };

      final response = await DioClient.dio.post(
        '/routesheets/api/v1/routeSheetEmployees/search',
        data: json.encode({"filter": filter}),
      );

      if (response.statusCode == 200) {
        final List list = response.data['result'] as List;
        final items = list.map((e) => RouteSheetEmployeeModel.fromJson(e)).toList();
        return items
            .where((x) => x.routeSheet.state2Id == state2Id)
            .toList();
      }

      logger.i('⚠️ Unexpected status code: ${response.statusCode}');
      return [];
    } catch (e) {
      logger.i('LU72 RouteSheetEmployees fetch error: $e');
      return [];
    }
  }

  Future<int?> lu72GetRouteClassIdForActiveEmployee({
    required int employeeId,
    int state2Id = 3,
  }) async {
    final list = await lu72SearchActiveRouteSheetEmployees(
      employeeId: employeeId,
      state2Id: state2Id,
    );
    if (list.isEmpty) return null;

    list.sort((a, b) {
      final ad = a.routeSheet.routeStartTime;
      final bd = b.routeSheet.routeStartTime;
      if (ad == null && bd == null) return 0;
      if (ad == null) return 1;
      if (bd == null) return -1;
      return bd.compareTo(ad);
    });

    final active = list.first;
    return active.routeSheetItem.wagon?.routeClassId;
  }
}
