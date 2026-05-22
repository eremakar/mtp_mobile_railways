import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:passflow_app/core/dio/dio_client.dart';
import 'package:passflow_app/core/services/logger.dart';
import 'package:passflow_app/data/models/route_sheets_history_model.dart';
import 'package:passflow_app/widgets/page/history_route.dart';

class _Row {
  final RouteSheetHistoryDto sheet;
  final double workedHours;
  final DateTime? arriveTime;
  final DateTime? leaveTime;

  const _Row({
    required this.sheet,
    required this.workedHours,
    required this.arriveTime,
    required this.leaveTime,
  });
}

class RouteSheetsHistoryRepository {
  // static const _allowedStates = {1, 3};
  static const _allowedStates = {6, 8};
  Future<List<RouteHistoryItem>> searchHistory({
    required int employeeId,
    DateTime? routeStartTime,
    int take = 10,
    int skip = 0,
  }) async {
    final rows = await _searchRouteSheets(
      employeeId: employeeId,
      routeStartTime: routeStartTime,
      take: take,
      skip: skip,
    );

    final filtered =
        rows.where((x) => _allowedStates.contains(x.sheet.state2Id)).toList();

    final byId = <int, _Row>{};
    for (final x in filtered) {
      byId[x.sheet.id] = x;
    }
    final merged = byId.values.toList();

    merged.sort((a, b) {
      final da = a.sheet.routeStartTime ?? a.sheet.comeTime;
      final db = b.sheet.routeStartTime ?? b.sheet.comeTime;
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da);
    });

    return merged.map((x) {
      final s = x.sheet;

      final start =
          s.routeStartTime ?? s.comeTime ?? x.arriveTime ?? DateTime.now();
      var end = s.routeEndTime ?? s.leaveTime ?? x.leaveTime ?? start;

      if (end.isBefore(start)) end = start;

      final hours = x.workedHours > 0
          ? x.workedHours
          : end.difference(start).inMinutes / 60.0;

      return RouteHistoryItem(
        id: s.id,
        routeName: s.name ?? '',
        hours: hours,
        start: start,
        end: end,
      );
    }).toList();
  }

  Future<List<_Row>> _searchRouteSheets({
    required int employeeId,
    DateTime? routeStartTime,
    required int take,
    required int skip,
  }) async {
    const path = '/routeSheets/api/v1/routeSheets/search';

    final body = {
      'paging': {'skip': skip, 'take': take, 'returnCount': true},
      'employeeId': employeeId,
      if (routeStartTime != null)
        'routeStartTime': routeStartTime.toUtc().toIso8601String(),
      'query': '',
      'includes': [
        'class',
        'items',
        'items.wagon',
        'items.wagonType',
        'routeSheetEmployees',
        'routeSheetEmployees.employee',
      ],
    };

    try {
      if (kDebugMode) {
        logger.i(
            'RouteSheetsHistory.searchRouteSheets path=$path employeeId=$employeeId routeStartTime=${routeStartTime?.toUtc().toIso8601String()} body=$body');
      }

      final resp = await DioClient.dio.post(path, data: body);

      final data = resp.data;
      final result = (data is Map && data['result'] is List)
          ? (data['result'] as List)
          : const [];

      DateTime? parseDt(dynamic v) {
        if (v is! String || v.isEmpty) return null;
        if (v.startsWith('0001-01-01')) return null;
        return DateTime.tryParse(v);
      }

      final items = <_Row>[];
      for (final raw in result) {
        if (raw is! Map) continue;

        final sheet =
            RouteSheetHistoryDto.fromJson(Map<String, dynamic>.from(raw));

        double workedHours = 0.0;
        DateTime? arriveTime;
        DateTime? leaveTime;

        final rse = raw['routeSheetEmployees'];
        if (rse is List) {
          for (final e in rse) {
            if (e is! Map) continue;
            final eid = e['employeeId'];
            if (eid is num && eid.toInt() == employeeId) {
              final wh = e['workedHours'];
              workedHours = (wh is num) ? wh.toDouble() : 0.0;
              arriveTime = parseDt(e['arriveTime']);
              leaveTime = parseDt(e['leaveTime']);
              break;
            }
          }
        }

        items.add(_Row(
          sheet: sheet,
          workedHours: workedHours,
          arriveTime: arriveTime,
          leaveTime: leaveTime,
        ));
      }

      if (kDebugMode) {
        logger.i(
            'RouteSheetsHistory.searchRouteSheets status=${resp.statusCode}, items=${items.length}');
      }

      return items;
    } on DioException catch (e) {
      logger.i(
          'RouteSheetsHistory.searchRouteSheets HTTP ${e.response?.statusCode}: ${e.message}');
      return [];
    } catch (e) {
      logger.i('RouteSheetsHistory.searchRouteSheets error: $e');
      return [];
    }
  }
}
