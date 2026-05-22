import 'package:hive/hive.dart';
import 'answer_model.dart';

part 'task_model.g.dart';

@HiveType(typeId: 7)
class TaskModel extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String type;

  @HiveField(2)
  int state;

  @HiveField(3)
  int index;

  @HiveField(4)
  int formId;

  @HiveField(5)
  int employeeId;

  @HiveField(6)
  List<AnswerModel> answers;

  TaskModel({
    required this.id,
    required this.type,
    required this.state,
    required this.index,
    required this.formId,
    required this.employeeId,
    required this.answers,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'] ?? 0,
        type: json['type'] ?? '',
        state: json['state'] ?? 0,
        index: json['index'] ?? 0,
        formId: json['formId'] ?? 0,
        employeeId: json['employeeId'] ?? 0,
        answers: (json['answers'] as List<dynamic>?)
                ?.map((e) => AnswerModel.fromJson(e))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'state': state,
        'index': index,
        'formId': formId,
        'employeeId': employeeId,
        'answers': answers.map((a) => a.toJson()).toList(),
      };
}
