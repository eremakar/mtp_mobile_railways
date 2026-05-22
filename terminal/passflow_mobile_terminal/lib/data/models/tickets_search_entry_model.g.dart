// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tickets_search_entry_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TicketSearchEntryModelAdapter
    extends TypeAdapter<TicketSearchEntryModel> {
  @override
  final int typeId = 18;

  @override
  TicketSearchEntryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TicketSearchEntryModel(
      train: fields[0] as String,
      station: fields[1] as String,
      departure: fields[2] as String,
      startStationCode: fields[3] as String,
      createdAt: fields[4] as DateTime,
      key: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TicketSearchEntryModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.train)
      ..writeByte(1)
      ..write(obj.station)
      ..writeByte(2)
      ..write(obj.departure)
      ..writeByte(3)
      ..write(obj.startStationCode)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.key);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TicketSearchEntryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
