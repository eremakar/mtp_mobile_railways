// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_form_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskFormModelAdapter extends TypeAdapter<TaskFormModel> {
  @override
  final int typeId = 10;

  @override
  TaskFormModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskFormModel(
      id: fields[0] as int,
      name: fields[1] as String,
      description: fields[2] as String,
      configurationRaw: fields[3] as String,
      configuration: fields[4] as FormConfiguration?,
    );
  }

  @override
  void write(BinaryWriter writer, TaskFormModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.configurationRaw)
      ..writeByte(4)
      ..write(obj.configuration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskFormModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
