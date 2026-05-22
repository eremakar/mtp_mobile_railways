// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_form_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AddFormModelAdapter extends TypeAdapter<AddFormModel> {
  @override
  final int typeId = 8;

  @override
  AddFormModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AddFormModel(
      id: fields[0] as int,
      state: fields[1] as int,
      routeSheetId: fields[2] as int,
      coordinatorEmployeeId: fields[3] as int,
      type2Id: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AddFormModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.state)
      ..writeByte(2)
      ..write(obj.routeSheetId)
      ..writeByte(3)
      ..write(obj.coordinatorEmployeeId)
      ..writeByte(4)
      ..write(obj.type2Id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddFormModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
