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
      classId: fields[6] as int?,
      trainNumbers: (fields[7] as List?)?.cast<String>(),
      routeStartTime: fields[8] as DateTime?,
      comeTime: fields[9] as DateTime?,
      leaveTime: fields[10] as DateTime?,
      wagons: (fields[11] as List?)?.cast<WagonModel>(),
      startStationId: fields[12] as int?,
      startStationName: fields[14] as String?,
      startStationCode: fields[13] as String?,
      directions: (fields[15] as List?)?.cast<RouteSheetDirectionModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, RouteSheetModel obj) {
    writer
      ..writeByte(16)
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
      ..write(obj.sapId)
      ..writeByte(6)
      ..write(obj.classId)
      ..writeByte(7)
      ..write(obj.trainNumbers)
      ..writeByte(8)
      ..write(obj.routeStartTime)
      ..writeByte(9)
      ..write(obj.comeTime)
      ..writeByte(10)
      ..write(obj.leaveTime)
      ..writeByte(11)
      ..write(obj.wagons)
      ..writeByte(12)
      ..write(obj.startStationId)
      ..writeByte(13)
      ..write(obj.startStationCode)
      ..writeByte(14)
      ..write(obj.startStationName)
      ..writeByte(15)
      ..write(obj.directions);
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
