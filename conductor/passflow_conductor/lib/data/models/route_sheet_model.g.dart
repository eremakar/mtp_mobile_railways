// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_sheet_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RouteSheetModelAdapter extends TypeAdapter<RouteSheetModel> {
  @override
  final int typeId = 1;

  @override
  RouteSheetModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RouteSheetModel(
      routeSheetName: fields[0] as String,
      routeSheetDate: fields[1] as DateTime?,
      routeSheetState: fields[2] as String,
      taskListTypeId: fields[3] as int,
      id: fields[4] as int,
      sapId: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RouteSheetModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.routeSheetName)
      ..writeByte(1)
      ..write(obj.routeSheetDate)
      ..writeByte(2)
      ..write(obj.routeSheetState)
      ..writeByte(3)
      ..write(obj.taskListTypeId)
      ..writeByte(4)
      ..write(obj.id)
      ..writeByte(5)
      ..write(obj.sapId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteSheetModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
