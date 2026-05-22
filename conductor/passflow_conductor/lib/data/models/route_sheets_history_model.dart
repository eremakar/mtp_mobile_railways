class RouteSheetHistoryDto {
  final int id;
  final String? name;

  final DateTime? routeStartTime;
  final DateTime? routeEndTime;
  final DateTime? comeTime;
  final DateTime? leaveTime;

  final int? state2Id;
  final String? state2Name;

  final List<RouteSheetHistoryItemDto> items;

  const RouteSheetHistoryDto({
    required this.id,
    this.name,
    this.routeStartTime,
    this.routeEndTime,
    this.comeTime,
    this.leaveTime,
    this.state2Id,
    this.state2Name,
    this.items = const [],
  });

  factory RouteSheetHistoryDto.fromJson(Map<String, dynamic> json) {
    return RouteSheetHistoryDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      routeStartTime: _dt(json['routeStartTime']),
      routeEndTime: _dt(json['routeEndTime']),
      comeTime: _dt(json['comeTime']),
      leaveTime: _dt(json['leaveTime']),
      state2Id: (json['state2Id'] as num?)?.toInt(),
      state2Name:
          (json['state2'] is Map) ? (json['state2']['name'] as String?) : null,
      items: (json['items'] is List)
          ? (json['items'] as List)
              .whereType<Map>()
              .map((e) => RouteSheetHistoryItemDto.fromJson(
                    Map<String, dynamic>.from(e),
                  ))
              .toList()
          : const [],
    );
  }

  String get wagonsLine {
    final parts = items
        .map((i) => i.wagonNumberAndType?.trim())
        .where((s) => s != null && s.isNotEmpty)
        .cast<String>()
        .toList();
    return parts.join(', ');
  }

  static DateTime? _dt(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }
}

class RouteSheetHistoryItemDto {
  final int id;
  final int? wagonId;
  final String? wagonNumber;
  final String? wagonTypeShort;
  final int? wagonTypeId;
  final String? wagonTypeName;

  const RouteSheetHistoryItemDto({
    required this.id,
    this.wagonId,
    this.wagonNumber,
    this.wagonTypeShort,
    this.wagonTypeId,
    this.wagonTypeName,
  });

  factory RouteSheetHistoryItemDto.fromJson(Map<String, dynamic> json) {
    final wagon = json['wagon'] is Map ? json['wagon'] as Map : null;
    final wagonType =
        json['wagonType'] is Map ? json['wagonType'] as Map : null;

    return RouteSheetHistoryItemDto(
      id: (json['id'] as num).toInt(),
      wagonId: (json['wagonId'] as num?)?.toInt(),
      wagonNumber: wagon?['number'] as String?,
      wagonTypeShort: wagon?['type'] as String?,
      wagonTypeId: (json['wagonTypeId'] as num?)?.toInt(),
      wagonTypeName: wagonType?['name'] as String?,
    );
  }

  String? get wagonNumberAndType {
    if ((wagonNumber ?? '').isEmpty && (wagonTypeShort ?? '').isEmpty) {
      return null;
    }
    final n = wagonNumber ?? '';
    final t = wagonTypeShort ?? '';
    return ('$n $t').trim();
  }
}
