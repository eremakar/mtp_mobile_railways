// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_station_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClassStationModelAdapter extends TypeAdapter<ClassStationModel> {
  @override
  final int typeId = 22;

  @override
  ClassStationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClassStationModel(
      id: fields[0] as int,
      name: fields[1] as String,
      code: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ClassStationModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.code);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassStationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
