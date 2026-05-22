import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:passflow_app/data/models/route_sheet_direction.dart';
import 'package:passflow_app/data/models/wagon_model.dart';
import 'package:passflow_app/helpers/parse_helper.dart';

part 'route_sheet_model.g.dart';

/// Ожидается массив объектов вида:
/// [ {"routeSheet": {...}}, {"routeSheet": {...}}, ... ]
List<RouteSheetModel> routeSheetModelsFromJson(dynamic list) {
  if (list is! Iterable) return const [];
  return List<RouteSheetModel>.from(
    list.map((x) => RouteSheetModel.fromJson(
          (x is Map && x['routeSheet'] is Map)
              ? (x['routeSheet'] as Map).cast<String, dynamic>()
              : <String, dynamic>{},
        )),
  );
}

@HiveType(typeId: 1)
class RouteSheetModel extends HiveObject {
  @HiveField(0)
  String routeSheetName;

  @HiveField(1)
  DateTime? routeSheetDate;

  @HiveField(2)
  String routeSheetState;

  @HiveField(3)
  int taskListTypeId;

  @HiveField(4)
  int id;

  @HiveField(5)
  String? sapId;

  @HiveField(6)
  int? classId;

  @HiveField(7)
  List<String>? trainNumbers;

  @HiveField(8)
  DateTime? routeStartTime;

  @HiveField(9)
  DateTime? comeTime;

  @HiveField(10)
  DateTime? leaveTime;

  @HiveField(11)
  List<WagonModel>? wagons;

  @HiveField(12)
  int? startStationId;

  @HiveField(13)
  String? startStationCode;

  @HiveField(14)
  String? startStationName;

  @HiveField(15)
  List<RouteSheetDirectionModel>? directions;

  RouteSheetModel(
      {required this.routeSheetName,
      this.routeSheetDate,
      required this.routeSheetState,
      required this.taskListTypeId,
      required this.id,
      this.sapId,
      this.classId,
      this.trainNumbers,
      this.routeStartTime,
      this.comeTime,
      this.leaveTime,
      this.wagons,
      this.startStationId,
      this.startStationName,
      this.startStationCode,
      this.directions});

  factory RouteSheetModel.fromJson(Map<String, dynamic> json) {
    final cls = (json['class'] is Map)
        ? (json['class'] as Map).cast<String, dynamic>()
        : <String, dynamic>{};

    final startStn = (cls['startStation'] is Map)
        ? (cls['startStation'] as Map).cast<String, dynamic>()
        : <String, dynamic>{};

    return RouteSheetModel(
      routeSheetName: (json['name'] ?? '').toString(),
      // Если отдельного поля routeSheetDate нет — оставим как comeTime (как у тебя было)
      routeSheetDate: ParseHelper.parseDate(json['routeStartTime']) ??
          ParseHelper.parseDate(json['comeTime']),
      routeSheetState: (json['state'] ?? '').toString(),
      taskListTypeId: ParseHelper.asInt(json['taskListTypeId']),
      id: ParseHelper.asInt(json['id']),
      sapId: ParseHelper.asStringOrNull(json['sapId']),
      classId: ParseHelper.asNulableInt(json['classId']),
      comeTime: ParseHelper.parseDate(json['comeTime']),
      routeStartTime: ParseHelper.parseDate(json['routeStartTime']),
      leaveTime: ParseHelper.parseDate(json['leaveTime']),
      // Соберём имена поездов, если есть (trainName1/2/3)
      // trainNumbers: _parseTrainNamesFromClass(cls),
      wagons: json['items'] != null
          ? (json['items'] as List).map((e) => WagonModel.fromJson(e)).toList()
          : null,
      startStationId: ParseHelper.asNulableInt(cls['startStationId']),
      startStationName: (startStn['name'] ?? '').toString(),
      directions: json['directions'] != null
          ? (json['directions'] as List)
              .map((e) => RouteSheetDirectionModel.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': routeSheetName,
        'routeSheetDate': routeSheetDate?.toIso8601String(),
        'state': routeSheetState,
        'taskListTypeId': taskListTypeId,
        'id': id,
        'sapId': sapId,
        'classId': classId,
        'trainNumbers': trainNumbers,
        'routeStartTime': routeStartTime?.toIso8601String(),
        'comeTime': comeTime?.toIso8601String(),
        'leaveTime': leaveTime?.toIso8601String(),
        'startStationName': startStationName,
      };

  static List<String>? _parseTrainNamesFromClass(Map<String, dynamic> cls) {
    if (cls.isEmpty) return null;
    final candidates = <String?>[
      cls['trainName1']?.toString(),
      cls['trainName2']?.toString(),
    ];
    final result = candidates
        .where((e) => e != null && e.trim().isNotEmpty)
        .cast<String>()
        .toList();
    return result.isEmpty ? null : result;
  }
}
