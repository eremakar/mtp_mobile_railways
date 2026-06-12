import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:passflow_app/core/cache/route_sheet_search_cache.dart';
import 'package:passflow_app/core/dio/dio_client.dart';
import 'package:passflow_app/data/models/route_sheet_model.dart';

class RouteSheetEmployeesRepository {
  static const _tag = '[routeSheetEmployees]';

  Future<List<RouteSheetModel>?> searchByEmployeeId(int employeeId) async {
    final body = {
      "filter": {
        "employeeId": {"operand1": employeeId, "operator": 1}
      },
      "includes": ["routeSheet.items"]
    };
    return _search(body, label: 'employeeId=$employeeId');
  }

  Future<List<RouteSheetModel>?> searchByFilialId(int? filialId) async {
    final body = {
      "filter": {
        "filialId": {"operand1": filialId, "operator": 1}
      },
      "includes": ["routeSheet.items"]
    };
    return _search(body, label: 'filialId=$filialId');
  }

  Future<List<RouteSheetModel>?> _search(
    Map<String, dynamic> body, {
    required String label,
  }) async {
    final cacheKey = 'routeSheetEmployees.search:$label';
    final cached = RouteSheetSearchCache.get<List<RouteSheetModel>>(cacheKey);
    if (cached != null) return cached;

    const path = '/api/v1/routeSheetEmployees/search';
    try {
      debugPrint('$_tag POST ${DioClient.dio.options.baseUrl}$path ($label)');
      debugPrint('$_tag request: ${jsonEncode(body)}');

      final response = await DioClient.dio.post(path, data: json.encode(body));

      debugPrint('$_tag status: ${response.statusCode}');
      debugPrint('$_tag response: ${jsonEncode(response.data)}');

      final result = response.data['result'];
      final parsed = routeSheetModelsFromJson(result);
      debugPrint('$_tag parsed count: ${parsed.length}');
      RouteSheetSearchCache.set(cacheKey, parsed);
      return parsed;
    } on DioError catch (e) {
      debugPrint('$_tag DioError $label');
      debugPrint(
        '$_tag URL: ${e.requestOptions.method} ${e.requestOptions.uri}',
      );
      debugPrint('$_tag request: ${e.requestOptions.data}');
      debugPrint('$_tag status: ${e.response?.statusCode}');
      debugPrint('$_tag response: ${e.response?.data}');
      return null;
    } catch (e, st) {
      debugPrint('$_tag error $label: $e');
      debugPrint('$_tag $st');
      return null;
    }
  }
}
