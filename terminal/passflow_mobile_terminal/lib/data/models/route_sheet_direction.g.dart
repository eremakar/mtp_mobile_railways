// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_sheet_direction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RouteSheetDirectionModelAdapter
    extends TypeAdapter<RouteSheetDirectionModel> {
  @override
  final int typeId = 20;

  @override
  RouteSheetDirectionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RouteSheetDirectionModel(
      id: fields[0] as int,
      startDate: fields[1] as DateTime,
      routeSheetId: fields[2] as int,
      trainDirectionId: fields[3] as int,
      routeId: fields[4] as int?,
      trainDirection: fields[5] as TrainDirectionModel?,
    );
  }

  @override
  void write(BinaryWriter writer, RouteSheetDirectionModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.startDate)
      ..writeByte(2)
      ..write(obj.routeSheetId)
      ..writeByte(3)
      ..write(obj.trainDirectionId)
      ..writeByte(4)
      ..write(obj.routeId)
      ..writeByte(5)
      ..write(obj.trainDirection);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteSheetDirectionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
