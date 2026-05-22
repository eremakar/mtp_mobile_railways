// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_configuration.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskConfigurationAdapter extends TypeAdapter<TaskConfiguration> {
  @override
  final int typeId = 3;

  @override
  TaskConfiguration read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskConfiguration(
      data: (fields[0] as List).cast<TaskBlock>(),
    );
  }

  @override
  void write(BinaryWriter writer, TaskConfiguration obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskConfigurationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
