import 'package:hive/hive.dart';
import 'form_task_field.dart';

part 'form_configuration.g.dart';

@HiveType(typeId: 11)
class FormConfiguration extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String instruction;

  @HiveField(2)
  List<FormTaskField> tasks;

  FormConfiguration({
    required this.title,
    required this.instruction,
    required this.tasks,
  });

  factory FormConfiguration.fromJson(Map<String, dynamic> json) {
    return FormConfiguration(
      title: json['title'],
      instruction: json['instruction'],
      tasks: (json['tasks'] as List)
          .map((e) => FormTaskField.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'instruction': instruction,
        'tasks': tasks.map((e) => e.toJson()).toList(),
      };
}
