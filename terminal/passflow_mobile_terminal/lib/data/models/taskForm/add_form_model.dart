import 'package:hive/hive.dart';

part 'add_form_model.g.dart';

@HiveType(typeId: 8)
class AddFormModel extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  int state;

  @HiveField(2)
  int routeSheetId;

  @HiveField(3)
  int coordinatorEmployeeId;

  @HiveField(4)
  int type2Id;

  AddFormModel({
    required this.id,
    required this.state,
    required this.routeSheetId,
    required this.coordinatorEmployeeId,
    required this.type2Id,
  });

  factory AddFormModel.fromJson(Map<String, dynamic> json) => AddFormModel(
        id: json['id'] ?? 0,
        state: json['state'] ?? 0,
        routeSheetId: json['routeSheetId'] ?? 0,
        coordinatorEmployeeId: json['coordinatorEmployeeId'] ?? 0,
        type2Id: json['type2Id'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'state': state,
        'routeSheetId': routeSheetId,
        'coordinatorEmployeeId': coordinatorEmployeeId,
        'type2Id': type2Id,
      };
}
