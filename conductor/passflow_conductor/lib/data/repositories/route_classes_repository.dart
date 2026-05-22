import 'package:dio/dio.dart';
import 'package:passflow_app/core/dio/dio_client.dart';

class PagedResponse<T> {
  final List<T> result;
  final int? total;
  final int? pageCount;

  PagedResponse({required this.result, this.total, this.pageCount});

  factory PagedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final list = (json['result'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .map(fromJsonT)
        .toList();

    return PagedResponse<T>(
      result: list,
      total: (json['total'] as num?)?.toInt(),
      pageCount: (json['pageCount'] as num?)?.toInt(),
    );
  }
}


class StationMiniModel {
  final int id;
  final String name;
  final String? code;

  StationMiniModel({
    required this.id,
    required this.name,
    this.code,
  });

  factory StationMiniModel.fromJson(Map<String, dynamic> json) {
    return StationMiniModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      code: json['code'] as String?,
    );
  }
}

class RouteClassStationModel {
  final int id;
  final int order;
  final DateTime? arriveTime;
  final DateTime? leaveTime;
  final String? trainName;
  final int routeClassId;
  final int stationId;
  final StationMiniModel? station;

  RouteClassStationModel({
    required this.id,
    required this.order,
    required this.arriveTime,
    required this.leaveTime,
    required this.trainName,
    required this.routeClassId,
    required this.stationId,
    required this.station,
  });

  factory RouteClassStationModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDt(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());

    return RouteClassStationModel(
      id: (json['id'] as num).toInt(),
      order: (json['order'] as num?)?.toInt() ?? 0,
      arriveTime: parseDt(json['arriveTime']),
      leaveTime: parseDt(json['leaveTime']),
      trainName: json['trainName'] as String?,
      routeClassId: (json['routeClassId'] as num?)?.toInt() ?? 0,
      stationId: (json['stationId'] as num?)?.toInt() ?? 0,
      station: json['station'] is Map
          ? StationMiniModel.fromJson(Map<String, dynamic>.from(json['station'] as Map))
          : null,
    );
  }
}

class RouteClassDirectionModel {
  final int id;
  final String? asuName;
  final String? fullName;
  final String? code;
  final int routeClassId;
  final int? trainId;

  RouteClassDirectionModel({
    required this.id,
    required this.asuName,
    required this.fullName,
    required this.code,
    required this.routeClassId,
    required this.trainId,
  });

  factory RouteClassDirectionModel.fromJson(Map<String, dynamic> json) {
    return RouteClassDirectionModel(
      id: (json['id'] as num).toInt(),
      asuName: json['asuName'] as String?,
      fullName: json['fullName'] as String?,
      code: json['code'] as String?,
      routeClassId: (json['routeClassId'] as num?)?.toInt() ?? 0,
      trainId: (json['trainId'] as num?)?.toInt(),
    );
  }
}

class RouteClassModel {
  final int id;
  final String name;
  final int? startStationId;
  final StationMiniModel? startStation;
  final List<RouteClassStationModel> stations;
  final List<int> stationIds;
  final List<StationMiniModel> stationList;
  final List<RouteClassDirectionModel> directions;

  RouteClassModel({
    required this.id,
    required this.name,
    this.startStationId,
    this.startStation,
    this.stations = const [],
    this.stationIds = const [],
    this.stationList = const [],
    this.directions = const [],
  });

  factory RouteClassModel.fromJson(Map<String, dynamic> json) {
    final stations = (json['stations'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => RouteClassStationModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final directions = (json['directions'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => RouteClassDirectionModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final startStationFromJson = json['startStation'] is Map
        ? StationMiniModel.fromJson(
            Map<String, dynamic>.from(json['startStation'] as Map),
          )
        : null;

    final startStationIdFromJson = (json['startStationId'] as num?)?.toInt();

    final sortedStations = [...stations]..sort((a, b) => a.order.compareTo(b.order));
    final firstStation = sortedStations.isNotEmpty ? sortedStations.first : null;

    final stationIds = stations.map((e) => e.stationId).where((id) => id != 0).toList();

    final stationList = stations
        .map((e) => e.station ?? StationMiniModel(id: e.stationId, name: '', code: null))
        .where((s) => s.id != 0)
        .toList();

    return RouteClassModel(
      id: (json['id'] as num).toInt(),
      name: (json['name'] as String?) ?? '',
      startStationId: startStationIdFromJson ?? firstStation?.stationId,
      startStation: startStationFromJson ?? firstStation?.station,
      stations: stations,
      stationIds: stationIds,
      stationList: stationList,
      directions: directions,
    );
  }
}

class RouteClassesRepository {
  final Dio _dio;
  
  RouteClassesRepository({Dio? dio}) : _dio = dio ?? DioClient.dio;

  Future<PagedResponse<RouteClassModel>> searchById({
    required int id,
    int take = 10,
    int skip = 0,
    bool returnCount = true,
  }) async {
    final body = <String, dynamic>{
      "paging": {"take": take, "skip": skip, "returnCount": returnCount},
      "filter": {
        "id": {"operand1": id, "operator": "1"} 
      }
    };

    final res = await _dio.post(
      '/routes/api/v1/routeClasses/search',
      data: body,
    );

    final data = Map<String, dynamic>.from(res.data as Map);
    return PagedResponse<RouteClassModel>.fromJson(
      data,
      (m) => RouteClassModel.fromJson(m),
    );
  }
}