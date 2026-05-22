import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:passflow_app/core/dio/dio_client.dart';
import 'package:passflow_app/data/models/route_sheet_employee_day_statistics.dart';

class RouteSheetEmployeeDayStatisticsRepository {
  Future<PagedResult<RouteSheetEmployeeDayStatisticDto>?> search({
    int? routeSheetEmployeeId,
    int? employeeId,
    DateTime? from,
    DateTime? to,
    int skip = 0,
    int take = 1000,
  }) async {
    try {
      final filter = <String, dynamic>{};

      if (routeSheetEmployeeId != null) {
        filter['routeSheetEmployeeId'] = {
          'operand1': routeSheetEmployeeId,
          'operator': 1, 
        };
      } else {
        if (employeeId == null) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ RouteSheetEmployeeDayStatistics.search: employeeId is required when routeSheetEmployeeId is null',
            );
          }
          return null;
        }

        filter['routeSheetEmployee.employeeId'] = {
          'operand1': employeeId,
          'operator': 1,
        };
      }

      if (from != null && to != null) {
        filter['routeDay'] = {
          'operand1': from.toUtc().toIso8601String(),
          'operand2': to.toUtc().toIso8601String(),
          'operator': 7, 
        };
      } else if (from != null) {
        filter['routeDay'] = {
          'operand1': from.toUtc().toIso8601String(),
          'operator': 5, 
        };
      } else if (to != null) {
        filter['routeDay'] = {
          'operand1': to.toUtc().toIso8601String(),
          'operator': 6, 
        };
      }

      final body = <String, dynamic>{
        'query': '',
        'paging': {'skip': skip, 'take': take, 'returnCount': true},
        'filter': filter,
        'filterOperator': 'And',
        'sort': {
          'routeDay': {'operator': 'Asc', 'ordinal': 0}
        },
        'includes': ['wagonType', 'routeSheetEmployee'],
      };

      if (kDebugMode) {
        debugPrint(
          '➡️ RouteSheetEmployeeDayStatistics.search path=/routeSheets/api/v1/routeSheetEmployeeDayStatistics/search',
        );
        debugPrint('➡️ RouteSheetEmployeeDayStatistics.search body=${jsonEncode(body)}');
      }

      final response = await DioClient.dio.post(
        '/routeSheets/api/v1/routeSheetEmployeeDayStatistics/search',
        data: body,
      );

      if (kDebugMode) {
        debugPrint('⬅️ RouteSheetEmployeeDayStatistics.search status=${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final dynamic data = response.data;
        final Map<String, dynamic> json = data is Map<String, dynamic>
            ? data
            : (data is String
                ? (jsonDecode(data) as Map<String, dynamic>)
                : <String, dynamic>{});

        final list = (json['result'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(RouteSheetEmployeeDayStatisticDto.fromJson)
            .toList();

        final totalDynamic = json['total'];
        final total = totalDynamic is int
            ? totalDynamic
            : (totalDynamic is num ? totalDynamic.toInt() : list.length);

        if (kDebugMode) {
          debugPrint(
            '✅ RouteSheetEmployeeDayStatistics.search parsed items=${list.length}, total=$total',
          );
        }

        return PagedResult(items: list, total: total);
      } else {
        if (kDebugMode) {
          debugPrint('⚠️ Unexpected status code: ${response.statusCode}');
          debugPrint(
            '⚠️ Response preview: ${response.data is String ? (response.data as String) : jsonEncode(response.data)}',
          );
        }
        return null;
      }
    } catch (e) {
      debugPrint('RouteSheetEmployeeDayStatistics search error: $e');
      return null;
    }
  }
}