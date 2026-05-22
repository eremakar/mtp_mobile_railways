// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_task_form_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PutTaskFormModelAdapter extends TypeAdapter<PutTaskFormModel> {
  @override
  final int typeId = 13;

  @override
  PutTaskFormModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PutTaskFormModel(
      id: fields[0] as int,
      type: fields[1] as String,
      state: fields[2] as int,
      routeSheetId: fields[3] as int,
      coordinatorEmployeeId: fields[4] as int,
      type2Id: fields[5] as int,
      tasks: (fields[6] as List?)?.cast<TaskModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, PutTaskFormModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.state)
      ..writeByte(3)
      ..write(obj.routeSheetId)
      ..writeByte(4)
      ..write(obj.coordinatorEmployeeId)
      ..writeByte(5)
      ..write(obj.type2Id)
      ..writeByte(6)
      ..write(obj.tasks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PutTaskFormModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
