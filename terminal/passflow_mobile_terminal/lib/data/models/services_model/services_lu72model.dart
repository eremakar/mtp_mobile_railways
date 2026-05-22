import 'dart:convert';

class Lu72SearchResponse {
  final List<WagonLu72Dto> result;
  final int? total;
  final int? pageCount;

  const Lu72SearchResponse({
    required this.result,
    this.total,
    this.pageCount,
  });

  factory Lu72SearchResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['result'];
    final list = (rawList is List)
        ? rawList.whereType<Map>().map((e) => WagonLu72Dto.fromJson(Map<String, dynamic>.from(e))).toList()
        : <WagonLu72Dto>[];

    return Lu72SearchResponse(
      result: list,
      total: (json['total'] is num) ? (json['total'] as num).toInt() : null,
      pageCount: (json['pageCount'] is num) ? (json['pageCount'] as num).toInt() : null,
    );
  }
}

class WagonLu72Dto {
  final int id;
  final DateTime createdTime;
  final int issued;
  final int totalPassengers;
  final int totalConsumed;
  final int conductorId;
  final int wagonId;
  final int? departmentId;
  final int? routeTrainId;
  final int? routeSheetId;
  final List<Lu72CostDto> costs;

  const WagonLu72Dto({
    required this.id,
    required this.createdTime,
    required this.issued,
    required this.totalPassengers,
    required this.totalConsumed,
    required this.conductorId,
    required this.wagonId,
    required this.departmentId,
    required this.routeTrainId,
    required this.routeSheetId,
    required this.costs,
  });

  factory WagonLu72Dto.fromJson(Map<String, dynamic> json) {
    final costsRaw = json['costs'];
    final costs = (costsRaw is List)
        ? costsRaw
            .whereType<Map>()
            .map((e) => Lu72CostDto.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <Lu72CostDto>[];

    return WagonLu72Dto(
      id: _asInt(json['id']),
      createdTime: _asDateTime(json['createdTime']),
      issued: _asInt(json['issued']),
      totalPassengers: _asInt(json['totalPassengers']),
      totalConsumed: _asInt(json['totalConsumed']),
      conductorId: _asInt(json['conductorId']),
      wagonId: _asInt(json['wagonId']),
      departmentId: json['departmentId'] is num ? (json['departmentId'] as num).toInt() : null,
      routeTrainId: json['routeTrainId'] is num ? (json['routeTrainId'] as num).toInt() : null,
      routeSheetId: json['routeSheetId'] is num ? (json['routeSheetId'] as num).toInt() : null,
      costs: costs,
    );
  }

  int get remainingToIssue {
    final v = totalPassengers - totalConsumed;
    return v < 0 ? 0 : v;
  }
}

class Lu72CostDto {
  final int id;
  final String seatsRaw;
  final int placeCount;
  final int? stationId;
  final int? lu72Id;
  final Lu72StationDto? station;

  const Lu72CostDto({
    required this.id,
    required this.seatsRaw,
    required this.placeCount,
    required this.stationId,
    required this.lu72Id,
    required this.station,
  });

  factory Lu72CostDto.fromJson(Map<String, dynamic> json) {
    return Lu72CostDto(
      id: _asInt(json['id']),
      seatsRaw: (json['seats'] ?? '').toString(),
      placeCount: _asInt(json['placeCount']),
      stationId: json['stationId'] is num ? (json['stationId'] as num).toInt() : null,
      lu72Id: json['lU72Id'] is num ? (json['lU72Id'] as num).toInt() : null,
      station: (json['station'] is Map)
          ? Lu72StationDto.fromJson(Map<String, dynamic>.from(json['station'] as Map))
          : null,
    );
  }

  String get stationName => station?.name ?? '—';
  List<int> get occupiedSeats => Lu72SeatParser.parseOccupiedSeats(seatsRaw);
}

class Lu72StationDto {
  final int id;
  final String name;

  const Lu72StationDto({
    required this.id,
    required this.name,
  });

  factory Lu72StationDto.fromJson(Map<String, dynamic> json) {
    return Lu72StationDto(
      id: _asInt(json['id']),
      name: (json['name'] ?? '—').toString(),
    );
  }
}
class Lu72SeatParser {
  static List<int> parseOccupiedSeats(String? seatsJsonString) {
    if (seatsJsonString == null) return const [];
    final s = seatsJsonString.trim();
    if (s.isEmpty) return const [];

    try {
      final decoded = jsonDecode(s);
      if (decoded is! List || decoded.isEmpty) return const [];
      final first = decoded.first;
      if (first is! Map) return const [];
      dynamic raw = first['занятые_места'];
      raw ??= first['occupiedSeats'];
      raw ??= first['occupied_seats'];
      raw ??= first['seats'];

      if (raw is! List) return const [];

      return raw.whereType<num>().map((e) => e.toInt()).toList();
    } catch (_) {
      return const [];
    }
  }
}

int _asInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? 0;
}

DateTime _asDateTime(dynamic v) {
  final s = v?.toString();
  final parsed = (s == null) ? null : DateTime.tryParse(s);
  return parsed ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
}
