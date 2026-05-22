// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as int,
      name: fields[1] as String,
      employeeId: fields[8] as int,
      login: fields[9] as String,
      password: fields[10] as String,
      routeSheetId: fields[2] as int?,
      trainNumber: fields[3] as String?,
      wagonNumber: fields[4] as String?,
      filialId: fields[5] as int?,
      departmentId: fields[6] as int?,
      token: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.routeSheetId)
      ..writeByte(3)
      ..write(obj.trainNumber)
      ..writeByte(4)
      ..write(obj.wagonNumber)
      ..writeByte(5)
      ..write(obj.filialId)
      ..writeByte(6)
      ..write(obj.departmentId)
      ..writeByte(7)
      ..write(obj.token)
      ..writeByte(8)
      ..write(obj.employeeId)
      ..writeByte(9)
      ..write(obj.login)
      ..writeByte(10)
      ..write(obj.password);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
