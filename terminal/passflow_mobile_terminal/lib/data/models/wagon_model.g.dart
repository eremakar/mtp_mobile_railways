// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wagon_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WagonModelAdapter extends TypeAdapter<WagonModel> {
  @override
  final int typeId = 14;

  @override
  WagonModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WagonModel(
      id: fields[0] as int,
      number: fields[1] as String,
      type: fields[2] as String?,
      order: fields[3] as String?,
      itemId: fields[4] as int?,
      typeName: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WagonModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.number)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.order)
      ..writeByte(4)
      ..write(obj.itemId)
      ..writeByte(5)
      ..write(obj.typeName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WagonModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
