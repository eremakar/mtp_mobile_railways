import 'dart:convert';

class HttpException implements Exception {
  const HttpException(this.message);
  final String message;

  @override
  String toString() => message;
}

class PagedResponse<T> {
  const PagedResponse({
    required this.result,
    this.total,
    this.pageCount,
  });

  final List<T> result;
  final int? total;
  final int? pageCount;

  factory PagedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? item) fromItem,
  ) {
    final raw = json['result'];
    final list =
        (raw is List) ? raw.map(fromItem).toList(growable: false) : <T>[];

    int? toIntOrNull(Object? v) => v is num ? v.toInt() : null;

    return PagedResponse<T>(
      result: list,
      total: toIntOrNull(json['total']),
      pageCount: toIntOrNull(json['pageCount']),
    );
  }
}

class WagonLu72CostModel {
  const WagonLu72CostModel({
    required this.id,
    required this.stationId,
    required this.lu72Id,
    this.routeSheetItemId,
    this.totalPassengers,
    this.totalConsumed,
    this.seatsRaw,
    this.placeCount,
    this.station,
    this.lu72,
  });

  final int id;
  final int stationId;
  final int lu72Id;
  final int? routeSheetItemId;
  final int? totalPassengers;
  final int? totalConsumed;
  final String? seatsRaw;
  final int? placeCount;
  final StationModel? station;
  final Lu72Model? lu72;

  Lu72Model? get lU72 => lu72;
  int get lU72Id => lu72Id;
  String? get seats => seatsRaw;

  factory WagonLu72CostModel.fromJson(Map<String, dynamic> json) {
    int asInt(Object? v, {int fallback = 0}) {
      if (v is num) return v.toInt();
      if (v == null) return fallback;
      return int.tryParse(v.toString()) ?? fallback;
    }

    String? normalizeSeats(Object? v) {
      if (v == null) return null;
      if (v is String) return v;
      try {
        return jsonEncode(v);
      } catch (_) {
        return v.toString();
      }
    }

    return WagonLu72CostModel(
      id: asInt(json['id']),
      stationId: asInt(json['stationId']),
      lu72Id: asInt(json['lU72Id']),
      routeSheetItemId: json['routeSheetItemId'] is num
          ? (json['routeSheetItemId'] as num).toInt()
          : null,
      totalPassengers: json['totalPassengers'] is num
          ? (json['totalPassengers'] as num).toInt()
          : null,
      totalConsumed: json['totalConsumed'] is num
          ? (json['totalConsumed'] as num).toInt()
          : null,
      seatsRaw: normalizeSeats(json['seats']),
      placeCount: json['placeCount'] is num
          ? (json['placeCount'] as num).toInt()
          : null,
      station: json['station'] is Map<String, dynamic>
          ? StationModel.fromJson(json['station'] as Map<String, dynamic>)
          : null,
      lu72: json['lU72'] is Map<String, dynamic>
          ? Lu72Model.fromJson(json['lU72'] as Map<String, dynamic>)
          : null,
    );
  }

  Set<int> get occupiedSeats {
    final raw = seatsRaw;
    if (raw == null || raw.isEmpty) return <int>{};

    try {
      dynamic decoded = jsonDecode(raw);
      if (decoded is String) {
        decoded = jsonDecode(decoded);
      }
      if (decoded is! List || decoded.isEmpty) return <int>{};

      final first = decoded.first;
      if (first is! Map) return <int>{};

      final seats = first['занятые_места'] ?? first['consumed_places'];
      if (seats is! List) return <int>{};

      return seats.whereType<num>().map((e) => e.toInt()).toSet();
    } catch (_) {
      return <int>{};
    }
  }

  String get occupiedSeatsLabel {
    final list = occupiedSeats.toList()..sort();
    return list.map((e) => e.toString().padLeft(2, '0')).join(', ');
  }
}

class StationModel {
  const StationModel({
    required this.id,
    required this.name,
    this.code,
  });

  final int id;
  final String name;
  final String? code;

  factory StationModel.fromJson(Map<String, dynamic> json) {
    int asInt(Object? v) => (v is num) ? v.toInt() : int.parse(v.toString());

    return StationModel(
      id: asInt(json['id']),
      name: (json['name'] ?? '').toString(),
      code: json['code']?.toString(),
    );
  }
}

class Lu72Model {
  const Lu72Model({
    required this.id,
    this.routeSheetId,
    this.totalConsumed,
    this.state,
  });

  final int id;
  final int? routeSheetId;
  final int? totalConsumed;
  final int? state;

  factory Lu72Model.fromJson(Map<String, dynamic> json) {
    int asInt(Object? v) => (v is num) ? v.toInt() : int.parse(v.toString());
    int? asIntOrNull(Object? v) =>
        v is num ? v.toInt() : (v == null ? null : int.tryParse(v.toString()));

    return Lu72Model(
      id: asInt(json['id']),
      routeSheetId: asIntOrNull(json['routeSheetId']),
      totalConsumed: asIntOrNull(json['totalConsumed']),
      state: asIntOrNull(json['state']),
    );
  }
}
