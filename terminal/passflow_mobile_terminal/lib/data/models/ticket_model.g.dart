// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StationModelAdapter extends TypeAdapter<StationModel> {
  @override
  final int typeId = 15;

  @override
  StationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StationModel(
      id: fields[0] as int?,
      name: fields[1] as String?,
      code: fields[2] as String?,
      shortName: fields[3] as String?,
      nameEn: fields[4] as String?,
      shortNameEn: fields[5] as String?,
      railwayName: fields[6] as String?,
      railwayShortName: fields[7] as String?,
      countryCode: fields[8] as String?,
      countryTlf: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, StationModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.code)
      ..writeByte(3)
      ..write(obj.shortName)
      ..writeByte(4)
      ..write(obj.nameEn)
      ..writeByte(5)
      ..write(obj.shortNameEn)
      ..writeByte(6)
      ..write(obj.railwayName)
      ..writeByte(7)
      ..write(obj.railwayShortName)
      ..writeByte(8)
      ..write(obj.countryCode)
      ..writeByte(9)
      ..write(obj.countryTlf);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PassengerModelAdapter extends TypeAdapter<PassengerModel> {
  @override
  final int typeId = 16;

  @override
  PassengerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PassengerModel(
      id: fields[0] as int,
      identityNumber: fields[1] as String,
      fullName: fields[2] as String,
      birthDate: fields[3] as String,
      citizenship: fields[4] as String,
      gender: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PassengerModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.identityNumber)
      ..writeByte(2)
      ..write(obj.fullName)
      ..writeByte(3)
      ..write(obj.birthDate)
      ..writeByte(4)
      ..write(obj.citizenship)
      ..writeByte(5)
      ..write(obj.gender);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PassengerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TicketModelAdapter extends TypeAdapter<TicketModel> {
  @override
  final int typeId = 17;

  @override
  TicketModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TicketModel(
      id: fields[0] as int,
      trainNumber: fields[1] as String,
      departure: fields[2] as String,
      wagonNumber: fields[3] as String,
      placeNumber: fields[4] as String,
      orderNumber: fields[5] as String,
      boardingPassed: fields[6] as bool,
      passengers: (fields[7] as List).cast<PassengerModel>(),
      documentKind: fields[10] as String,
      wagonCategory: fields[12] as String,
      serviceClass: fields[13] as String,
      deparute: fields[8] as StationModel?,
      arrival: fields[9] as StationModel?,
      isSendToServer: fields[11] as bool?,
      orderDate: fields[14] as String?,
      operatorEmployeeId: fields[15] as num?,
      operatorEmployeeName: fields[16] as String?,
      operatorUpdatedTime: fields[17] as String?,
      operatorEmployeeTableNumber: fields[18] as String?,
      arrivalTime: fields[19] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TicketModel obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.trainNumber)
      ..writeByte(2)
      ..write(obj.departure)
      ..writeByte(3)
      ..write(obj.wagonNumber)
      ..writeByte(4)
      ..write(obj.placeNumber)
      ..writeByte(5)
      ..write(obj.orderNumber)
      ..writeByte(6)
      ..write(obj.boardingPassed)
      ..writeByte(7)
      ..write(obj.passengers)
      ..writeByte(8)
      ..write(obj.deparute)
      ..writeByte(9)
      ..write(obj.arrival)
      ..writeByte(10)
      ..write(obj.documentKind)
      ..writeByte(11)
      ..write(obj.isSendToServer)
      ..writeByte(12)
      ..write(obj.wagonCategory)
      ..writeByte(13)
      ..write(obj.serviceClass)
      ..writeByte(14)
      ..write(obj.orderDate)
      ..writeByte(15)
      ..write(obj.operatorEmployeeId)
      ..writeByte(16)
      ..write(obj.operatorEmployeeName)
      ..writeByte(17)
      ..write(obj.operatorUpdatedTime)
      ..writeByte(18)
      ..write(obj.operatorEmployeeTableNumber)
      ..writeByte(19)
      ..write(obj.arrivalTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TicketModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
