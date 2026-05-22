// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_form_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskItemAdapter extends TypeAdapter<TaskItem> {
  @override
  final int typeId = 5;

  @override
  TaskItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskItem(
      title: fields[0] as String,
      typeId: fields[1] as String,
      tasktype: fields[2] as String,
      statusnames: (fields[3] as Map?)?.cast<int, String>(),
      currentStatus: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, TaskItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.typeId)
      ..writeByte(2)
      ..write(obj.tasktype)
      ..writeByte(3)
      ..write(obj.statusnames)
      ..writeByte(4)
      ..write(obj.currentStatus);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
