class RouteCardSheetModel {
  final int id;
  final String? name;
  final int? type;
  final DateTime? comeTime;
  final DateTime? leaveTime;

  RouteCardSheetModel({
    required this.id,
    this.name,
    this.type,
    this.comeTime,
    this.leaveTime,
  });

  factory RouteCardSheetModel.fromJson(Map<String, dynamic> json) {
    return RouteCardSheetModel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      comeTime:
          json['comeTime'] != null ? DateTime.parse(json['comeTime']) : null,
      leaveTime:
          json['leaveTime'] != null ? DateTime.parse(json['leaveTime']) : null,
    );
  }
}

class RouteCardModel {
  final int id;
  final String? name;
  final bool isArchive;
  final String? sapId;
  final int type;
  final String? state;
  final DateTime? comeTime;
  final DateTime? leaveTime;

  final RouteCardSheetModel? routeCardSheet;

  RouteCardModel({
    required this.id,
    this.name,
    required this.isArchive,
    this.sapId,
    required this.type,
    this.state,
    this.comeTime,
    this.leaveTime,
    this.routeCardSheet,
  });

  factory RouteCardModel.fromJson(Map<String, dynamic> json) {
    return RouteCardModel(
      id: json['id'],
      name: json['name'],
      isArchive: json['isArchive'],
      sapId: json['sapId'],
      type: json['type'],
      state: json['state'],
      comeTime:
          json['comeTime'] != null ? DateTime.parse(json['comeTime']) : null,
      leaveTime:
          json['leaveTime'] != null ? DateTime.parse(json['leaveTime']) : null,
      routeCardSheet: json['routeSheet'] != null
          ? RouteCardSheetModel.fromJson(json['routeSheet'])
          : null,
    );
  }
}
