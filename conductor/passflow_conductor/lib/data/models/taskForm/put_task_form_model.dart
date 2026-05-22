import 'package:hive/hive.dart';
import 'package:passflow_app/data/models/task/task_model.dart';

part 'put_task_form_model.g.dart';

@HiveType(typeId: 13)
class PutTaskFormModel extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String type;
  @HiveField(2)
  int state;
  @HiveField(3)
  int routeSheetId;
  @HiveField(4)
  int coordinatorEmployeeId;
  @HiveField(5)
  int type2Id;

  @HiveField(6)
  List<TaskModel>? tasks;

  PutTaskFormModel(
      {required this.id,
      required this.type,
      required this.state,
      required this.routeSheetId,
      required this.coordinatorEmployeeId,
      required this.type2Id,
      this.tasks});

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'state': state,
        'routeSheetId': routeSheetId,
        'coordinatorEmployeeId': coordinatorEmployeeId,
        'type2Id': type2Id,
        'tasks': tasks?.map((a) => a.toJson()).toList(),
      };
}
