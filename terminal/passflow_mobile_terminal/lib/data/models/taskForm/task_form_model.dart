import 'dart:convert';
import 'package:hive/hive.dart';
import 'form_configuration.dart';

part 'task_form_model.g.dart';

@HiveType(typeId: 10)
class TaskFormModel extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  String configurationRaw;

  @HiveField(4)
  FormConfiguration? configuration;

  TaskFormModel({
    required this.id,
    required this.name,
    required this.description,
    required this.configurationRaw,
    this.configuration,
  });

  factory TaskFormModel.fromJson(Map<String, dynamic> json) {
    final raw = json['configuration'];
    return TaskFormModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      configurationRaw: raw,
      configuration: FormConfiguration.fromJson(jsonDecode(raw)['form']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'configuration': configurationRaw,
      };
}
