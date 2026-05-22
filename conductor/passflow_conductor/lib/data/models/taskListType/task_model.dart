import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:passflow_app/data/models/taskListType/task_configuration.dart';

part 'task_model.g.dart';

@HiveType(typeId: 2)
class TaskListTypeModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final TaskConfiguration configuration;

  TaskListTypeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.configuration,
  });

  factory TaskListTypeModel.fromJson(Map<String, dynamic> json) {
    final configMap = jsonDecode(json['configuration']);
    return TaskListTypeModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      configuration: TaskConfiguration.fromJson(configMap),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'configuration': jsonEncode(configuration.toJson()),
      };
}
