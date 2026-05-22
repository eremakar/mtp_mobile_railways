// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'train_directions_response.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrainDirectionsResponseAdapter
    extends TypeAdapter<TrainDirectionsResponse> {
  @override
  final int typeId = 21;

  @override
  TrainDirectionsResponse read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrainDirectionsResponse(
      result: (fields[0] as List).cast<TrainDirectionModel>(),
      total: fields[1] as int?,
      pageCount: fields[2] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, TrainDirectionsResponse obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.result)
      ..writeByte(1)
      ..write(obj.total)
      ..writeByte(2)
      ..write(obj.pageCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainDirectionsResponseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
