import 'package:hive/hive.dart';
part 'route_sheet_model.g.dart';

List<RouteSheetModel> routeSheetModelsFromJson(str) =>
    List<RouteSheetModel>.from(
        str.map((x) => RouteSheetModel.fromJson(x['routeSheet'])));

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

  RouteSheetModel(
      {required this.routeSheetName,
      this.routeSheetDate,
      required this.routeSheetState,
      required this.taskListTypeId,
      required this.id,
      this.sapId});

  factory RouteSheetModel.fromJson(Map<String, dynamic> json) =>
      RouteSheetModel(
          routeSheetName: json['name'],
          routeSheetDate: json['comeTime'] != null
              ? DateTime.parse(json['comeTime'])
              : null,
          routeSheetState: json['state'],
          taskListTypeId: json['taskListTypeId'] ?? 0,
          id: json['id'] ?? 0,
          sapId: json['sapId'],
          );

  Map<String, dynamic> toJson() => {
        'routeSheetName': routeSheetName,
        'routeSheetDate': routeSheetDate,
        'routeSheetState': routeSheetState,
        'taskListTypeId': taskListTypeId,
        'id': id,
        'sapId': sapId,
      };
}
