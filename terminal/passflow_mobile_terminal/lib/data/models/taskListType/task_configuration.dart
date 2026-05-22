// ✅ Конфигурация формы (обёртка над блоками)
import 'package:hive/hive.dart';
import 'package:passflow_app/data/models/taskListType/block_model.dart';

part 'task_configuration.g.dart';

@HiveType(typeId: 3)
class TaskConfiguration extends HiveObject {
  @HiveField(0)
  final List<TaskBlock> data;

  TaskConfiguration({required this.data});

  factory TaskConfiguration.fromJson(Map<String, dynamic> json) {
    return TaskConfiguration(
      data: (json['data'] as List).map((e) => TaskBlock.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'data': data.map((e) => e.toJson()).toList(),
      };
}
