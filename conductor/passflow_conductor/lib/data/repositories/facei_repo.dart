import 'package:dio/dio.dart';
import 'package:passflow_app/core/dio/dio_client.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:passflow_app/data/models/user_model.dart';

class FilialDto {
  final int id;
  final String name;

  FilialDto({
    required this.id,
    required this.name,
  });

  factory FilialDto.fromJson(Map<String, dynamic> json) {
    return FilialDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
    );
  }
}

class ComeTimeRouteInfo {
  final DateTime? comeTime;
  final DateTime? arriveTime;
  final bool isArrived;
  final String? routeName;
  final int? filialId;

  ComeTimeRouteInfo({
    required this.comeTime,
    required this.arriveTime,
    required this.isArrived,
    required this.routeName,
    required this.filialId,
  });
}

class TransactionsRepository {
  static const String _userBoxName = 'userBox';
  static const String _currentUserKey = 'currentUser';

  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim());
    return null;
  }

  Future<int?> _getFilialIdFromHive() async {
    try {
      if (!Hive.isBoxOpen(_userBoxName)) {
        await Hive.openBox<UserModel>(_userBoxName);
      }

      final box = Hive.box<UserModel>(_userBoxName);
      final user = box.get(_currentUserKey);

      final direct = _asInt(user?.filialId);
      if (direct != null && direct > 0) return direct;

      final dynamic anyUser = user;
      if (anyUser is Map) {
        final fromMap = _asInt(anyUser['filialId'] ?? anyUser['filial_id'] ?? anyUser['branchId']);
        if (fromMap != null && fromMap > 0) return fromMap;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<DateTime?> getLatestComeTimeByEmployeeId(int employeeId) async {
    try {
      final info = await getLatestComeTimeRouteByEmployeeId(employeeId);
      return info.comeTime;
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String?> getLatestRouteFilialNameByEmployeeId(int employeeId) async {
    try {
      final info = await getLatestComeTimeRouteByEmployeeId(employeeId);
      final filialId = info.filialId;
      if (filialId == null || filialId <= 0) return null;
      return await getFilialNameByFilialId(filialId);
    } catch (_) {
      return null;
    }
  }

  Future<DateTime?> getLatestArriveTimeByEmployeeId(int employeeId) async {
    try {
      final info = await getLatestComeTimeRouteByEmployeeId(employeeId);
      return info.arriveTime;
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<ComeTimeRouteInfo> getLatestComeTimeRouteByEmployeeId(int employeeId) async {
    try {
      final body = {
        'query': '',
        'paging': {'skip': 0, 'take': 200, 'returnCount': false},
        'filter': {
          'employeeId': {
            'operand1': employeeId,
            'operand2': 0,
            'operator': 'Equals',
          },
        },
        'filterOperator': 'And',
        'sort': {
          'id': {'operator': 'Unsorted', 'ordinal': 0},
        },
        'options': {},
        'includes': ['routeSheet'],
      };

      final response = await DioClient.dio.post(
        '/routeSheets/api/v1/routeSheetEmployees/search',
        data: body,
        options: Options(
          validateStatus: (_) => true,
          headers: const {'Content-Type': 'application/json'},
        ),
      );

      final filialIdFromHive = await _getFilialIdFromHive();

      if (response.statusCode != 200) {
        return ComeTimeRouteInfo(
          comeTime: null,
          arriveTime: null,
          isArrived: false,
          routeName: null,
          filialId: filialIdFromHive,
        );
      }

      final data = response.data;
      final list = (data is Map<String, dynamic>) ? (data['result'] as List?) : null;

      if (list == null || list.isEmpty) {
        return ComeTimeRouteInfo(
          comeTime: null,
          arriveTime: null,
          isArrived: false,
          routeName: null,
          filialId: filialIdFromHive,
        );
      }

      DateTime? bestTime;
      DateTime? bestArriveTime;
      bool bestIsArrived = false;
      String? bestName;

      for (final item in list) {
        if (item is! Map<String, dynamic>) continue;
        final sheet = item['routeSheet'];
        if (sheet is! Map<String, dynamic>) continue;

        final rawTime = sheet['comeTime'];
        if (rawTime == null) continue;

        final dt = DateTime.tryParse(rawTime.toString());
        if (dt == null) continue;

        if (bestTime == null || dt.isAfter(bestTime)) {
          bestTime = dt;

          final rawArrive = item['arriveTime'];
          bestArriveTime = rawArrive == null ? null : DateTime.tryParse(rawArrive.toString());

          bestIsArrived = item['isArrived'] == true;

          final rawName = sheet['name'] ?? sheet['routeName'] ?? sheet['title'] ?? sheet['number'];
          final name = rawName == null ? '' : rawName.toString().trim();
          bestName = name.isEmpty ? null : name;
        }
      }

      return ComeTimeRouteInfo(
        comeTime: bestTime,
        arriveTime: bestArriveTime,
        isArrived: bestIsArrived,
        routeName: bestName,
        filialId: filialIdFromHive,
      );
    } on DioException {
      return ComeTimeRouteInfo(
        comeTime: null,
        arriveTime: null,
        isArrived: false,
        routeName: null,
        filialId: await _getFilialIdFromHive(),
      );
    } catch (e) {
      return ComeTimeRouteInfo(
        comeTime: null,
        arriveTime: null,
        isArrived: false,
        routeName: null,
        filialId: await _getFilialIdFromHive(),
      );
    }
  }

  Future<String?> getFilialNameByFilialId(int filialId) async {
    try {
      final body = {
        'query': '',
        'paging': {'skip': 0, 'take': 1, 'returnCount': false},
        'filter': {
          'id': {
            'operand1': filialId,
            'operand2': 0,
            'operator': 'Equals',
          },
        },
        'filterOperator': 'And',
        'sort': {
          'id': {'operator': 'Unsorted', 'ordinal': 0},
        },
        'options': {},
        'includes': const <String>[],
      };

      final response = await DioClient.dio.post(
        '/employees/api/v1/filials/search',
        data: body,
        options: Options(
          validateStatus: (_) => true,
          headers: const {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final list = (data is Map<String, dynamic>) ? (data['result'] as List?) : null;
        if (list == null || list.isEmpty) return null;

        final first = list.first;
        if (first is Map<String, dynamic>) {
          final dto = FilialDto.fromJson(first);
          final name = dto.name.trim();
          return name.isEmpty ? null : name;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}