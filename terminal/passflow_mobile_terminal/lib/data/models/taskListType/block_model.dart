// ✅ Блок заданий (например, "Предрейсовая подготовка")
import 'package:hive/hive.dart';
import 'package:passflow_app/data/models/taskListType/task_form_model.dart';

part 'block_model.g.dart';

@HiveType(typeId: 4)
class TaskBlock extends HiveObject {
  @HiveField(0)
  final String blockname;

  @HiveField(1)
  final List<TaskItem> tasks;

  TaskBlock({required this.blockname, required this.tasks});

  factory TaskBlock.fromJson(Map<String, dynamic> json) {
    return TaskBlock(
      blockname: json['blockname'],
      tasks: (json['tasks'] as List).map((e) => TaskItem.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'blockname': blockname,
        'tasks': tasks.map((e) => e.toJson()).toList(),
      };
}
