import 'package:hive/hive.dart';

part 'form_task_field.g.dart';

@HiveType(typeId: 12)
class FormTaskField extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String type;

  @HiveField(2)
  String label;

  @HiveField(3)
  String? placeholder;

  @HiveField(4)
  int? widthPercent;

  @HiveField(5)
  int? lines;

  @HiveField(6)
  List<String>? answerOptions;

  @HiveField(7)
  List<String>? fileTypes;

  FormTaskField({
    required this.name,
    required this.type,
    required this.label,
    this.placeholder,
    this.widthPercent,
    this.lines,
    this.answerOptions,
    this.fileTypes,
  });

  factory FormTaskField.fromJson(Map<String, dynamic> json) => FormTaskField(
        name: json['name'],
        type: json['type'],
        label: json['label'],
        placeholder: json['placeholder'],
        widthPercent: json['width_percent'],
        lines: json['lines'],
        answerOptions: (json['answeroptions'] as List?)?.cast<String>(),
        fileTypes: (json['file_types'] as List?)?.cast<String>(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'label': label,
        if (placeholder != null) 'placeholder': placeholder,
        if (widthPercent != null) 'width_percent': widthPercent,
        if (lines != null) 'lines': lines,
        if (answerOptions != null) 'answeroptions': answerOptions,
        if (fileTypes != null) 'file_types': fileTypes,
      };
}
