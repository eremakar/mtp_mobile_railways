class WagonTypeDto {
  final int id;
  final String name;
  final int? placeCount;

  WagonTypeDto({
    required this.id,
    required this.name,
    this.placeCount,
  });

  factory WagonTypeDto.fromJson(Map<String, dynamic> json) => WagonTypeDto(
        id: (json['id'] ?? 0) as int,
        name: (json['name'] ?? '') as String,
        placeCount: (json['placeCount'] as num?)?.toInt(),
      );
}

class RouteSheetEmployeeDto {
  final int id;
  final int employeeId;
  final double plannedHours;
  final double workedHours;

  RouteSheetEmployeeDto({
    required this.id,
    required this.employeeId,
    required this.plannedHours,
    required this.workedHours,
  });

  factory RouteSheetEmployeeDto.fromJson(Map<String, dynamic> json) =>
      RouteSheetEmployeeDto(
        id: (json['id'] ?? 0) as int,
        employeeId: (json['employeeId'] ?? 0) as int,
        plannedHours: ((json['plannedHours'] ?? 0) as num).toDouble(),
        workedHours: ((json['workedHours'] ?? 0) as num).toDouble(),
      );
}

class RouteSheetEmployeeDayStatisticDto {
  final int id;
  final DateTime routeDay;

  final double total;
  final double holidayTime;
  final double securityTotal;

  final int wagonTypeId;
  final int routeSheetEmployeeId;

  final WagonTypeDto? wagonType;
  final RouteSheetEmployeeDto? routeSheetEmployee;

  RouteSheetEmployeeDayStatisticDto({
    required this.id,
    required this.routeDay,
    required this.total,
    required this.holidayTime,
    required this.securityTotal,
    required this.wagonTypeId,
    required this.routeSheetEmployeeId,
    required this.wagonType,
    required this.routeSheetEmployee,
  });

  factory RouteSheetEmployeeDayStatisticDto.fromJson(
      Map<String, dynamic> json) {
    final routeDayRaw = json['routeDay'] as String?;
    return RouteSheetEmployeeDayStatisticDto(
      id: (json['id'] ?? 0) as int,
      routeDay:
          routeDayRaw != null ? DateTime.parse(routeDayRaw) : DateTime(1970),
      total: ((json['total'] ?? 0) as num).toDouble(),
      holidayTime: ((json['holidayTime'] ?? 0) as num).toDouble(),
      securityTotal: ((json['securityTotal'] ?? 0) as num).toDouble(),
      wagonTypeId: (json['wagonTypeId'] ?? 0) as int,
      routeSheetEmployeeId: (json['routeSheetEmployeeId'] ?? 0) as int,
      wagonType: json['wagonType'] is Map<String, dynamic>
          ? WagonTypeDto.fromJson(json['wagonType'] as Map<String, dynamic>)
          : null,
      routeSheetEmployee: json['routeSheetEmployee'] is Map<String, dynamic>
          ? RouteSheetEmployeeDto.fromJson(
              json['routeSheetEmployee'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class PagedResult<T> {
  final List<T> items;
  final int total;

  PagedResult({required this.items, required this.total});
}
