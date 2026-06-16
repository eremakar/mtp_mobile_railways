import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:passflow_app/core/dio/dio_client.dart';
import 'package:passflow_app/data/models/class_station_model.dart';
import 'package:passflow_app/data/models/name_id.pair_model.dart';
import 'package:passflow_app/data/models/ticket_model.dart';
import 'package:passflow_app/services/logger.dart';
import 'package:passflow_app/utils/network_utils.dart';

class StationsRepo {
  Box<String> get _stationCodesBox => Hive.box<String>('station_codes');

  String _stationCodeKey(String stationName) =>
      stationName.trim().toLowerCase();

  Future<void> _cacheStationCodes(List<ClassStationModel> stations) async {
    for (final station in stations) {
      final code = station.code?.trim();
      if (code != null && code.isNotEmpty) {
        await _stationCodesBox.put(_stationCodeKey(station.name), code);
      }
    }
  }

  /// Получить список названий станций посадки по classId
  Future<List<ClassStationModel>> getStationNamesByClassId(int classId) async {
    final stationsBox = Hive.box<List<ClassStationModel>>('loaded_stations');
    final cached = stationsBox.get(classId) ?? const <ClassStationModel>[];
    final hasNet = await NetworkUtils.isNetworkAvailable();
    if (!hasNet) {
      return cached;
    }

    try {
      final filter = {
        "filter": {
          "routeClassId": {"operand1": classId, "operator": 1}
        }
      };

      final response = await DioClient.dio.post(
        '/api/v1/routeClassStations/search',
        data: filter, // Dio сам сериализует Map
      );

      if (response.statusCode != 200) {
        return stationsBox.get(classId) ?? const [];
      }

      final List raw = (response.data?['result'] as List?) ?? const [];
      if (raw.isEmpty) {
        return stationsBox.get(classId) ?? const [];
      }
      final sorted =
          raw.whereType<Map>().where((m) => m['station'] != null).toList()
            ..sort((a, b) {
              final ao = (a['order'] as num?) ?? 0;
              final bo = (b['order'] as num?) ?? 0;
              return ao.compareTo(bo);
            });

      // маппим как раньше; код ССПД может быть в station или на уровне записи
      var stations = sorted.map((m) {
        final stationJson = Map<String, dynamic>.from(m['station'] as Map);
        final nestedCode = stationJson['code']?.toString();
        final rowCode = m['code']?.toString();
        final code = (nestedCode != null && nestedCode.isNotEmpty)
            ? nestedCode
            : rowCode;
        if (code != null && code.isNotEmpty) {
          stationJson['code'] = code;
        }
        return ClassStationModel.fromJson(stationJson);
      }).toList();

      await stationsBox.put(classId, stations);
      await _cacheStationCodes(stations);
      return stations;
    } catch (e, s) {
      logger.e('❌ Ошибка загрузки станций посадки: $e\n$s');
      return stationsBox.get(classId) ?? const [];
    }
  }

  Future<List<NameIdPairModel>> getStationNamesById(int id) async {
    try {
      final filter = {
        "filter": {
          "id": {"operand1": id, "operator": 1}
        }
      };

      final response = await DioClient.dio.post(
        '/api/v1/routeClassStations/search',
        data: json.encode(filter),
      );

      if (response.statusCode == 200) {
        return [
          ...(response.data['result'] as List)
              .where((item) => item['station'] != null)
              .map((item) => NameIdPairModel.fromJson(item['station']))
        ];
      }
      return [];
    } catch (e, s) {
      logger.e('❌ Ошибка загрузки станций посадки: $e\n$s');
      return [];
    }
  }

  Future<String?> searchStationCodeByClassId(int id) async {
    try {
      final station = await getStationNamesById(id);
      if (station.length == 0) return null;
      final stationName = station[0].name;
      return await searchSspdStationCode(stationName);
    } catch (e) {
      print('❌ Ошибка загрузки билетов: $e');
      return null;
    }
  }

  Future<String?> searchSspdStationCode(String stationName) async {
    final cached = _stationCodesBox.get(_stationCodeKey(stationName));
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    try {
      final response = await DioClient.dio.post(
        '/api/v1/stations/search',
        data: jsonEncode({
          "filter": {
            "name": {"operand1": stationName, "operator": 1}
          }
        }),
      );
      if (response.statusCode == 200) {
        final code = (response.data['result'] as List)
            .cast<Map>()
            .map((item) => item['code']?.toString())
            .firstWhere((c) => c != null && c.isNotEmpty, orElse: () => null);
        if (code != null && code.isNotEmpty) {
          await _stationCodesBox.put(_stationCodeKey(stationName), code);
        }
        return code;
      }
      return cached;
    } catch (e) {
      print('❌ Ошибка загрузки билетов: $e');
      return cached;
    }
  }
}
