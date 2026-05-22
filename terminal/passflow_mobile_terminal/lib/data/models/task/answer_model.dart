import 'package:hive/hive.dart';

part 'answer_model.g.dart';

@HiveType(typeId: 6)
class AnswerModel extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String optionName;

  @HiveField(2)
  String value;

  @HiveField(3)
  String? status;

  @HiveField(4)
  int? taskId;

  @HiveField(5)
  int formId;

  @HiveField(6)
  String? task;

  AnswerModel({
    required this.id,
    required this.optionName,
    required this.value,
    this.status,
    required this.taskId,
    required this.formId,
    this.task,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) => AnswerModel(
        id: json['id'] ?? 0,
        optionName: json['optionName'] ?? '',
        value: json['value'] ?? '',
        status: json['status'] ?? '',
        taskId: json['taskId'] ?? 0,
        formId: json['formId'] ?? 0,
        task: json['task'] ?? '',
      );

  Map<String, dynamic> toJson() {
    final map = {
      'id': id,
      'optionName': optionName,
      'value': value,
      'status': status,
      'taskId': taskId,
      'formId': formId,
      'task': task,
    };
    map.removeWhere((k, v) => v == null);
    return map;
  }
}
