import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:passflow_app/core/dio/dio_client.dart';
import 'package:passflow_app/data/models/services_model/vu8_remark_models.dart';
import 'package:passflow_app/data/models/user_model.dart';

class Vu8Repository {
  static const String _searchPath = '/wagons/api/v1/wagonVU8s/search';
  static const String _createPath = '/wagons/api/v1/wagonVU8s';
  static const String _typesSearchPath = '/wagons/api/v1/vU8Types/search';
  static const String _routeSheetEmployeesSearchPath =
      '/routeSheets/api/v1/routeSheetEmployees/search';
  static const String _routeSheetsPath = '/routeSheets/api/v1/routeSheets';

  static const List<String> defaultIncludes = <String>[
    'type',
    'employee',
  ];

  static const String _userBoxName = 'userBox';
  static const String _currentUserKey = 'currentUser';

  final Dio _dio;

  Vu8Repository({Dio? dio}) : _dio = dio ?? DioClient.dio;

  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim());
    return null;
  }

  Future<int?> _getDepartmentIdFromHive() async {
    try {
      if (!Hive.isBoxOpen(_userBoxName)) {
        await Hive.openBox<UserModel>(_userBoxName);
      }

      final box = Hive.box<UserModel>(_userBoxName);
      final user = box.get(_currentUserKey);

      final id = _asInt(user?.departmentId);
      if (id != null && id > 0) return id;

      return null;
    } catch (_) {
      return null;
    }
  }

  Future<dynamic> searchRaw(Map<String, dynamic> body) async {
    try {
      final res = await _dio.post(_searchPath, data: body);
      return res.data;
    } catch (_) {
      return null;
    }
  }

  Future<Vu8RemarkSearchResponse?> search(Map<String, dynamic> body) async {
    final data = await searchRaw(body);
    if (data is Map<String, dynamic>) {
      return Vu8RemarkSearchResponse.fromJson(data);
    }
    return null;
  }

  Future<dynamic> searchTypesRaw(Map<String, dynamic> body) async {
    try {
      final res = await _dio.post(_typesSearchPath, data: body);
      return res.data;
    } catch (_) {
      return null;
    }
  }

  Future<dynamic> searchRouteSheetEmployeesRaw(Map<String, dynamic> body) async {
    try {
      final res = await _dio.post(_routeSheetEmployeesSearchPath, data: body);
      return res.data;
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getRouteSheetsForEmployee({
    required int employeeId,
    int take = 50,
    int skip = 0,
    bool returnCount = true,
    int? state2IdMin,
    int? state2IdMax,
  }) async {
    final filter = <String, dynamic>{
      'employeeId': {'operand1': employeeId, 'operator': 'Equals'},
    };

    if (state2IdMin != null || state2IdMax != null) {
      final stateFilter = <String, dynamic>{};
      if (state2IdMin != null) {
        stateFilter['operand1'] = state2IdMin;
        stateFilter['operator'] = 'GreaterThan';
      }
      if (state2IdMax != null) {
        stateFilter['operand2'] = state2IdMax;
        stateFilter['operator2'] = 'LessThan';
      }
      filter['routeSheet.state2Id'] = stateFilter;
    }

    final body = <String, dynamic>{
      'paging': {
        'skip': skip,
        'take': take,
        'returnCount': returnCount,
      },
      'filter': filter,
      'filterOperator': 'And',
    };

    final data = await searchRouteSheetEmployeesRaw(body);
    if (data is Map<String, dynamic>) {
      final result = data['result'];
      if (result is List) {
        return result
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }
    return <Map<String, dynamic>>[];
  }

  Future<dynamic> getRouteSheetRaw(int routeSheetId) async {
    try {
      final res = await _dio.get('$_routeSheetsPath/$routeSheetId');
      final data = res.data;

      if (data is Map<String, dynamic> && data.containsKey('result')) {
        return data['result'];
      }

      return data;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getRouteSheet(int routeSheetId) async {
    final data = await getRouteSheetRaw(routeSheetId);
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  Future<Vu8TypeSearchResponse?> searchTypes({
    int take = 50,
    int skip = 0,
    String sortField = 'id',
    String sortDirection = 'Asc',
  }) async {
    final body = <String, dynamic>{
      'paging': {
        'skip': skip,
        'take': take,
        'returnCount': true,
      },
      'filter': <String, dynamic>{},
      'filterOperator': 'And',
      'sort': {
        sortField: {
          'operator': sortDirection,
          'ordinal': 0,
        }
      },
    };

    final data = await searchTypesRaw(body);
    if (data is Map<String, dynamic>) {
      return Vu8TypeSearchResponse.fromJson(data);
    }
    return null;
  }

  Future<List<Vu8Type>> getTypes({
    int take = 50,
    int skip = 0,
    String sortField = 'id',
    String sortDirection = 'Asc',
  }) async {
    final res = await searchTypes(
      take: take,
      skip: skip,
      sortField: sortField,
      sortDirection: sortDirection,
    );
    return res?.result ?? <Vu8Type>[];
  }

  Future<Vu8RemarkSearchResponse?> searchByWagon({
    required int wagonId,
    int? routeId,
    int? routeSheetId,
    int take = 20,
    int skip = 0,
    List<String> includes = defaultIncludes,
  }) async {
    final body = <String, dynamic>{
      'paging': {
        'skip': skip,
        'take': take,
        'returnCount': true,
      },
      'filter': {
        'wagonId': {'operand1': wagonId, 'operator': 'Equals'},
        if (routeId != null)
          'routeId': {'operand1': routeId, 'operator': 'Equals'},
        if (routeSheetId != null)
          'routeSheetId': {'operand1': routeSheetId, 'operator': 'Equals'},
      },
      'filterOperator': 'And',
      'sort': {
        'createdTime': {'operator': 'Desc', 'ordinal': 0},
      },
      'includes': includes,
    };

    return await search(body);
  }

  Future<bool> createRemark({
    required String text,
    required int wagonId,
    required int typeId,
    required int employeeId,
    int? departmentId,
    int state = 1,
    int? routeId,
    int? routeSheetId,
    String? createdTime,
    String? imageUrl,
    String? completedText,
  }) async {
    final resolvedDepartmentId =
        departmentId ?? await _getDepartmentIdFromHive();
    if (resolvedDepartmentId == null) return false;

    final body = <String, dynamic>{
      'text': text,
      if (imageUrl != null && imageUrl.trim().isNotEmpty) 'imageUrl': imageUrl,
      if (completedText != null && completedText.trim().isNotEmpty)
        'completedText': completedText,
      'wagonId': wagonId,
      'routeSheetId': routeSheetId,
      'typeId': typeId,
      'employeeId': employeeId,
      'departmentId': resolvedDepartmentId,
      'state': state,
      if (routeId != null) 'routeId': routeId,
      if (createdTime != null && createdTime.trim().isNotEmpty)
        'createdTime': createdTime,
    };

    try {
      await _dio.post(_createPath, data: body);
      return true;
    } catch (_) {
      return false;
    }
  }
}