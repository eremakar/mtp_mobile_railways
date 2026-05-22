import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:passflow_app/core/dio/dio_client.dart';
import 'package:passflow_app/data/models/class_station_model.dart';
import 'package:passflow_app/data/models/name_id.pair_model.dart';
import 'package:passflow_app/data/models/ticket_model.dart';
import 'package:passflow_app/services/logger.dart';

class StationsRepo {
  /// Получить список названий станций посадки по classId
  Future<List<ClassStationModel>> getStationNamesByClassId(int classId) async {
    final stationsBox = Hive.box<List<ClassStationModel>>('loaded_stations');
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

      // маппим как раньше
      var stations =
          sorted.map((m) => ClassStationModel.fromJson(m['station'])).toList();

      await stationsBox.put(classId, stations);
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
        return (response.data['result'] as List)
            .firstWhere((item) => item['code'] != null)?['code'];
      }
      return null;
    } catch (e) {
      print('❌ Ошибка загрузки билетов: $e');
      return null;
    }
  }
}
