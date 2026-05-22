import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:passflow_app/core/dio/dio_client.dart';
import 'package:passflow_app/data/models/route_sheets_models.dart';

class RouteSheetBanner {
  final String title;
  final String subtitle;
  final String routeName;
  final DateTime comeTime;
  final DateTime leaveTime;
  final int? routeSheetId;
  final int? groupNumber;
  final String? wagonNumber;

  const RouteSheetBanner({
    required this.title,
    required this.subtitle,
    required this.routeName,
    required this.comeTime,
    required this.leaveTime,
    required this.routeSheetId,
    required this.groupNumber,
    this.wagonNumber,
  });
}

class RouteSheetBannerResult {
  final RouteSheetBanner? banner;
  final int? statusCode;
  final String? errorMessage;

  const RouteSheetBannerResult({
    required this.banner,
    this.statusCode,
    this.errorMessage,
  });

  bool get hasError =>
      statusCode != null || (errorMessage != null && errorMessage!.trim().isNotEmpty);
}

class RouteSheetsRepository {
  final Dio _dio;

  RouteSheetsRepository({Dio? dio}) : _dio = dio ?? DioClient.dio;

  Future<List<RouteSheetSearchDto>> search({
    required int employeeId,
    DateTime? month,
  }) async {
    final items = await _searchRaw(employeeId: employeeId);
    final routeSheets = items
        .map<Map<String, dynamic>>((e) => _extractRouteSheetMap(e) ?? e)
        .toList();

    return routeSheets
        .map((e) => RouteSheetSearchDto.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<RouteSheetBanner?> getNextOrCurrentRouteBanner({
    required int employeeId,
  }) async {
    final result = await getNextOrCurrentRouteBannerResult(employeeId: employeeId);
    return result.banner;
  }

  Future<RouteSheetBannerResult> getNextOrCurrentRouteBannerResult({
    required int employeeId,
  }) async {
    final search = await _searchRawDetailed(employeeId: employeeId);
    final items = search.items;
    if (items.isEmpty) {
      return RouteSheetBannerResult(
        banner: null,
        statusCode: search.statusCode,
        errorMessage: search.errorMessage,
      );
    }

    final now = DateTime.now().toUtc();

    final candidates = <_Candidate>[];
    for (final item in items) {
      final routeSheet = _extractRouteSheetMap(item);
      if (routeSheet == null) continue;

      final come = _parseDt(routeSheet['comeTime']);
      final leave = _parseDt(routeSheet['leaveTime']);
      if (come == null || leave == null) continue;

      if (!leave.isAfter(now)) continue;

      final routeName = _extractRouteName(routeSheet);
      final wagonNumber = _extractEmployeeWagonNumber(item);
      final groupNumber = _extractEmployeeGroupNumber(item);
      candidates.add(_Candidate(
        routeSheetId: _asInt(routeSheet['id']),
        comeTime: come,
        leaveTime: leave,
        routeName: routeName,
        wagonNumber: wagonNumber,
        groupNumber: groupNumber,
      ));
    }

    if (candidates.isEmpty) {
      return RouteSheetBannerResult(
        banner: null,
        statusCode: search.statusCode,
        errorMessage: search.errorMessage,
      );
    }

    candidates.sort((a, b) => a.leaveTime.compareTo(b.leaveTime));
    final picked = candidates.first;

    final isNext = now.isBefore(picked.comeTime);
    final title = isNext ? 'Следующий маршрут' : 'Актуальный маршрут';

    final duration = isNext
        ? picked.comeTime.difference(now)
        : picked.leaveTime.difference(now);

    final subtitle = isNext
        ? 'Явка через: ${_formatDurationRu(duration)}'
        : 'До окончания: ${_formatDurationRu(duration)}';

    final subtitleWithGroup = subtitle;

    return RouteSheetBannerResult(
      banner: RouteSheetBanner(
        title: title,
        subtitle: subtitleWithGroup,
        routeName: picked.routeName,
        comeTime: picked.comeTime,
        leaveTime: picked.leaveTime,
        routeSheetId: picked.routeSheetId,
        groupNumber: picked.groupNumber,
        wagonNumber: picked.wagonNumber,
      ),
      statusCode: search.statusCode,
      errorMessage: search.errorMessage,
    );
  }

  Future<List<Map<String, dynamic>>> _searchRaw({
    required int employeeId,
  }) async {
    final result = await _searchRawDetailed(employeeId: employeeId);
    return result.items;
  }

  Future<_SearchRawResult> _searchRawDetailed({
    required int employeeId,
  }) async {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final body = {
      'query': '',
      'paging': {'skip': 0, 'take': 200, 'returnCount': true},
      'filter': {
        'employeeId': {'operand1': employeeId, 'operator': 'Equals'},
        'routeSheet': {
          'leaveTime': {'operand1': nowIso, 'operator': 'GreaterThan'},
        },
      },
      'filterOperator': 'And',
      'includes': [
        'routeSheet',
        'routeSheet.class',
        'routeSheet.items',
        'routeSheet.items.wagon',
        'routeSheet.items.wagonType',
        'routeSheetItem',
        'routeSheetItem.wagon',
        'routeSheetItem.wagonType',
        'class',
        'items',
        'items.wagon',
        'items.wagonType',
      ],
    };

    final path = '/routeSheets/api/v1/routeSheetEmployees/search';

    try {
      final resp = await DioClient.dio.post(path, data: json.encode(body));

      dynamic parsed = resp.data;
      if (parsed is String) {
        try {
          parsed = json.decode(parsed);
        } catch (_) {
          // ignore
        }
      }

      final data = parsed;
      final list = (data is Map && data['result'] is List)
          ? (data['result'] as List)
          : const <dynamic>[];

      return _SearchRawResult(
        items: list
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      );
    } on DioException catch (e) {
      final code = e.response?.statusCode;

      if (kDebugMode) {
        print(
          '❌ RouteSheetsRepository._searchRaw error on $path: HTTP $code, ${e.message}',
        );
      }
      return _SearchRawResult(
        items: const <Map<String, dynamic>>[],
        statusCode: code,
        errorMessage: e.message ?? e.response?.statusMessage,
      );
    } catch (e) {
      if (kDebugMode) {
        print(
            '❌ RouteSheetsRepository._searchRaw unexpected error on $path: $e');
      }
      return _SearchRawResult(
        items: const <Map<String, dynamic>>[],
        errorMessage: e.toString(),
      );
    }
  }

  Map<String, dynamic>? _extractRouteSheetMap(Map<String, dynamic> item) {
    final rs = item['routeSheet'];
    if (rs is Map) return Map<String, dynamic>.from(rs);
    return item;
  }

  int? _extractEmployeeGroupNumber(Map<String, dynamic> item) {
    final rsi = item['routeSheetItem'];
    if (rsi is Map) {
      final gn = rsi['groupNumber'];
      return _asInt(gn);
    }
    return _asInt(item['groupNumber']);
  }

  String? _extractEmployeeWagonNumber(Map<String, dynamic> item) {
    final rsi = item['routeSheetItem'];
    if (rsi is Map) {
      final wagon = rsi['wagon'];
      if (wagon is Map) {
        final num = wagon['number'];
        if (num is String && num.trim().isNotEmpty) return num;
      }
    }

    final wagon = item['wagon'];
    if (wagon is Map) {
      final num = wagon['number'];
      if (num is String && num.trim().isNotEmpty) return num;
    }

    return null;
  }

  String _extractRouteName(Map<String, dynamic> routeSheet) {
    final cls = routeSheet['class'];
    if (cls is Map) {
      final name = cls['name'];
      if (name is String && name.trim().isNotEmpty) return name;
    }
    return '';
  }

  DateTime? _parseDt(dynamic v) {
    if (v is String && v.trim().isNotEmpty) {
      try {
        return DateTime.parse(v).toUtc();
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  int? _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  String _formatDurationRu(Duration d) {
    if (d.isNegative) d = Duration.zero;

    final totalMinutes = d.inMinutes;
    final days = totalMinutes ~/ (24 * 60);
    final hours = (totalMinutes % (24 * 60)) ~/ 60;
    final minutes = totalMinutes % 60;

    final parts = <String>[];
    if (days > 0) parts.add('$days ${_ruPlural(days, 'день', 'дня', 'дней')}');
    if (hours > 0) {
      parts.add('$hours ${_ruPlural(hours, 'час', 'часа', 'часов')}');
    }
    if (minutes > 0 || parts.isEmpty) {
      parts.add('$minutes ${_ruPlural(minutes, 'минута', 'минуты', 'минут')}');
    }
    return parts.join(' ');
  }

  String _ruPlural(int n, String one, String few, String many) {
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod10 == 1 && mod100 != 11) return one;
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return few;
    return many;
  }

  Future<Lu72RouteSheetSummary?> getLu72Summary({
    required int routeSheetId,
  }) async {
    final response = await _dio.get<dynamic>(
      '/routeSheets/api/v1/routeSheets/$routeSheetId',
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return Lu72RouteSheetSummary.fromJson(data);
    }
    if (data is Map) {
      return Lu72RouteSheetSummary.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  Future<Lu72RouteSheetSummary?> patchLu72Summary({
    required int routeSheetId,
    int? lu72AttendantsCount,
    int? lu72StaffCount,
    int? lu72TotalCount,
  }) async {
    final operations = <Map<String, dynamic>>[
      if (lu72AttendantsCount != null)
        <String, dynamic>{
          'operationType': 'Replace',
          'path': '/lu72AttendantsCount',
          'op': 'replace',
          'from': '',
          'value': '$lu72AttendantsCount',
        },
      if (lu72StaffCount != null)
        <String, dynamic>{
          'operationType': 'Replace',
          'path': '/lu72StaffCount',
          'op': 'replace',
          'from': '',
          'value': '$lu72StaffCount',
        },
      if (lu72TotalCount != null)
        <String, dynamic>{
          'operationType': 'Replace',
          'path': '/lu72TotalCount',
          'op': 'replace',
          'from': '',
          'value': '$lu72TotalCount',
        },
    ];

    if (operations.isEmpty) return getLu72Summary(routeSheetId: routeSheetId);

    await _dio.patch<dynamic>(
      '/routeSheets/api/v1/routeSheets/$routeSheetId',
      data: operations,
      options: Options(contentType: 'application/json-patch+json'),
    );

    return getLu72Summary(routeSheetId: routeSheetId);
  }
}

class _Candidate {
  final int? routeSheetId;
  final int? groupNumber;
  final DateTime comeTime;
  final DateTime leaveTime;
  final String routeName;
  final String? wagonNumber;

  _Candidate({
    required this.routeSheetId,
    required this.groupNumber,
    required this.comeTime,
    required this.leaveTime,
    required this.routeName,
    required this.wagonNumber,
  });
}

class _SearchRawResult {
  final List<Map<String, dynamic>> items;
  final int? statusCode;
  final String? errorMessage;

  const _SearchRawResult({
    required this.items,
    this.statusCode,
    this.errorMessage,
  });
}

class Lu72RouteSheetSummary {
  final int? lu72AttendantsCount;
  final int? lu72StaffCount;
  final int? lu72TotalCount;

  const Lu72RouteSheetSummary({
    required this.lu72AttendantsCount,
    required this.lu72StaffCount,
    required this.lu72TotalCount,
  });

  factory Lu72RouteSheetSummary.fromJson(Map<String, dynamic> json) {
    int? toInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    return Lu72RouteSheetSummary(
      lu72AttendantsCount: toInt(json['lu72AttendantsCount']),
      lu72StaffCount: toInt(json['lu72StaffCount']),
      lu72TotalCount: toInt(json['lu72TotalCount']),
    );
  }
}
