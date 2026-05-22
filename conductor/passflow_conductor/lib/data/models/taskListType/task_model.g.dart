// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskListTypeModelAdapter extends TypeAdapter<TaskListTypeModel> {
  @override
  final int typeId = 2;

  @override
  TaskListTypeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskListTypeModel(
      id: fields[0] as int,
      name: fields[1] as String,
      description: fields[2] as String,
      configuration: fields[3] as TaskConfiguration,
    );
  }

  @override
  void write(BinaryWriter writer, TaskListTypeModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.configuration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskListTypeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
