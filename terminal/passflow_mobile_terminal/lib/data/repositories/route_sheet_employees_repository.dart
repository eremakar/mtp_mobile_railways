import 'dart:convert';

import 'package:passflow_app/core/dio/dio_client.dart';
import 'package:passflow_app/data/models/route_sheet_model.dart';

class RouteSheetEmployeesRepository {
  Future<List<RouteSheetModel>?> searchByEmployeeId(int employeeId) async {
    try {
      final response = await DioClient.dio.post(
        '/api/v1/routeSheetEmployees/search',
        data: json.encode({
          "filter": {
            "employeeId": {"operand1": employeeId, "operator": 1}
          },
          "includes": ["routeSheet.items"]
        }),
      );
      return routeSheetModelsFromJson(response.data['result']);
    } catch (e) {
      print('❌ Ошибка загрузки маршрутов: $e');
      return null;
    }
  }

  Future<List<RouteSheetModel>?> searchByFilialId(int? filialId) async {
    try {
      final response = await DioClient.dio.post(
        '/api/v1/routeSheetEmployees/search',
        data: json.encode({
          "filter": {
            "filialId": {"operand1": filialId, "operator": 1}
          },
          "includes": ["routeSheet.items"]
        }),
      );
      return routeSheetModelsFromJson(response.data['result']);
    } catch (e) {
      print('❌ Ошибка загрузки маршрутов: $e');
      return null;
    }
  }
}
