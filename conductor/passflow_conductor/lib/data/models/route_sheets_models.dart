class RouteSheetSearchDto {
  final int id;
  final DateTime? comeTime;
  final DateTime? leaveTime;
  final String? className;
  final List<RouteSheetItemDto> items;

  RouteSheetSearchDto({
    required this.id,
    required this.comeTime,
    required this.leaveTime,
    required this.className,
    required this.items,
  });

  String get wagonsLine {
    final wagons = items
        .map((e) {
          final n = e.wagonNumber?.trim();
          final t = e.wagonType?.trim();
          if ((n == null || n.isEmpty) && (t == null || t.isEmpty)) return null;
          if (n == null || n.isEmpty) return t;
          if (t == null || t.isEmpty) return n;
          return '$n $t';
        })
        .whereType<String>()
        .toSet()
        .toList();

    if (wagons.isEmpty) return '';
    return 'Номер вагона: ${wagons.join(', ')}';
  }

  factory RouteSheetSearchDto.fromJson(Map<String, dynamic> json) {
    final itemsJson = (json['items'] as List?) ?? const [];
    return RouteSheetSearchDto(
      id: (json['id'] as num).toInt(),
      comeTime: _parseDate(json['comeTime']),
      leaveTime: _parseDate(json['leaveTime']),
      className:
          (json['class'] is Map) ? (json['class']['name'] as String?) : null,
      items: itemsJson
          .whereType<Map>()
          .map((e) => RouteSheetItemDto.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    try {
      return DateTime.parse(v.toString()).toUtc();
    } catch (_) {
      return null;
    }
  }
}

class RouteSheetItemDto {
  final String? wagonNumber;
  final String? wagonType;

  RouteSheetItemDto({required this.wagonNumber, required this.wagonType});

  factory RouteSheetItemDto.fromJson(Map<String, dynamic> json) {
    final wagon = json['wagon'];
    return RouteSheetItemDto(
      wagonNumber: (wagon is Map) ? wagon['number'] as String? : null,
      wagonType: (wagon is Map) ? wagon['type'] as String? : null,
    );
  }
}
