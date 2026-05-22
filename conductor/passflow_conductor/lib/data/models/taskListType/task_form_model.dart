// ✅ Отдельная задача
import 'package:hive/hive.dart';
part 'task_form_model.g.dart';

@HiveType(typeId: 5)
class TaskItem extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String typeId;

  @HiveField(2)
  final String tasktype;

  @HiveField(3)
  final Map<int, String>? statusnames;

  @HiveField(4)
  late int? currentStatus;

  TaskItem({
    required this.title,
    required this.typeId,
    required this.tasktype,
    this.statusnames,
    this.currentStatus,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['statusnames'] as Map?;
    return TaskItem(
      title: json['title'],
      typeId: json['type_id'],
      tasktype: json['tasktype'],
      statusnames:
          rawStatus?.map((k, v) => MapEntry(int.parse(k), v.toString())),
      currentStatus: json['currentStatus'],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'type_id': typeId,
        'tasktype': tasktype,
        'statusnames': statusnames,
        'currentStatus': currentStatus,
      };
}
