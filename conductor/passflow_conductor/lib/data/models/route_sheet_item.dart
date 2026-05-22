class RouteSheetItemModel {
  RouteSheetItemModel({
    required this.id,
    this.number,
    this.groupNumber,
    this.routeSheetId,
    this.lu72AttendantsCount,
    this.lu72StaffiCount,
    this.lu72TotalCount,
    this.lu72State,
    this.wagonId,
    this.wagon,
    this.wagonType,
  });

  final int id;
  final String? number;
  final int? groupNumber;
  final int? routeSheetId;
  final int? lu72AttendantsCount;
  final int? lu72StaffiCount;
  final int? lu72TotalCount;
  final int? lu72State;
  final int? wagonId;
  final WagonModel? wagon;
  final WagonTypeModel? wagonType;

  String get uiLabel {
    final left = (number ?? '-').trim();
    final typeName = (wagonType?.name ?? '').trim();
    final baseLabel = typeName.isNotEmpty ? '$left • $typeName' : left;

    if (wagonId != null) {
      return '$baseLabel (#$wagonId)';
    }

    final wagonNumber = (wagon?.number ?? '').trim();
    if (wagonNumber.isNotEmpty) {
      return '$baseLabel ($wagonNumber)';
    }

    return baseLabel;
  }

  factory RouteSheetItemModel.fromJson(Map<String, dynamic> json) {
    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    return RouteSheetItemModel(
      id: toInt(json['id']) ?? 0,
      number: json['number']?.toString(),
      groupNumber: toInt(json['groupNumber']),
      routeSheetId: toInt(json['routeSheetId']),
      lu72AttendantsCount: toInt(json['lu72AttendantsCount']),
      lu72StaffiCount:
          toInt(json['lu72StaffiCount']) ?? toInt(json['lu72StaffCount']),
      lu72TotalCount: toInt(json['lu72TotalCount']),
      lu72State: toInt(json['lu72State']) ?? toInt(json['Lu72State']),
      wagonId: toInt(json['wagonId']),
      wagon: (json['wagon'] is Map<String, dynamic>)
          ? WagonModel.fromJson(json['wagon'] as Map<String, dynamic>)
          : null,
      wagonType: (json['wagonType'] is Map<String, dynamic>)
          ? WagonTypeModel.fromJson(json['wagonType'] as Map<String, dynamic>)
          : null,
    );
  }
}

class WagonModel {
  WagonModel({
    required this.id,
    this.number,
    this.routeClassId,
    this.serviceClassId,
    this.wagonType,
  });

  final int id;
  final String? number;
  final int? routeClassId;
  final int? serviceClassId;
  final WagonTypeModel? wagonType;

  factory WagonModel.fromJson(Map<String, dynamic> json) {
    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    return WagonModel(
      id: toInt(json['id']) ?? 0,
      number: json['number']?.toString(),
      routeClassId: toInt(json['routeClassId']),
      serviceClassId: toInt(json['serviceClassId']),
      wagonType: (json['wagonType'] is Map<String, dynamic>)
          ? WagonTypeModel.fromJson(json['wagonType'] as Map<String, dynamic>)
          : null,
    );
  }
}

class WagonTypeModel {
  WagonTypeModel({
    required this.id,
    this.name,
    this.description,
    this.placeCount,
  });

  final int id;
  final String? name;
  final String? description;
  final int? placeCount;

  factory WagonTypeModel.fromJson(Map<String, dynamic> json) {
    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    return WagonTypeModel(
      id: toInt(json['id']) ?? 0,
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      placeCount: toInt(json['placeCount']),
    );
  }
}
