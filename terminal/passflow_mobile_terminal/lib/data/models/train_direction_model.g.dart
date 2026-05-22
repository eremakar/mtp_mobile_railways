// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'train_direction_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrainDirectionModelAdapter extends TypeAdapter<TrainDirectionModel> {
  @override
  final int typeId = 19;

  @override
  TrainDirectionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrainDirectionModel(
      id: fields[0] as int,
      asuName: fields[1] as String,
      fullName: fields[2] as String,
      code: fields[3] as String,
      routeClassId: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TrainDirectionModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.asuName)
      ..writeByte(2)
      ..write(obj.fullName)
      ..writeByte(3)
      ..write(obj.code)
      ..writeByte(4)
      ..write(obj.routeClassId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainDirectionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
