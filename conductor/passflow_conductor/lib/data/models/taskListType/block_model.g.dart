// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskBlockAdapter extends TypeAdapter<TaskBlock> {
  @override
  final int typeId = 4;

  @override
  TaskBlock read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskBlock(
      blockname: fields[0] as String,
      tasks: (fields[1] as List).cast<TaskItem>(),
    );
  }

  @override
  void write(BinaryWriter writer, TaskBlock obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.blockname)
      ..writeByte(1)
      ..write(obj.tasks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskBlockAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
