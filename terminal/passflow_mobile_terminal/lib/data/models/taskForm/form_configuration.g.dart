// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'form_configuration.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FormConfigurationAdapter extends TypeAdapter<FormConfiguration> {
  @override
  final int typeId = 11;

  @override
  FormConfiguration read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FormConfiguration(
      title: fields[0] as String,
      instruction: fields[1] as String,
      tasks: (fields[2] as List).cast<FormTaskField>(),
    );
  }

  @override
  void write(BinaryWriter writer, FormConfiguration obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.instruction)
      ..writeByte(2)
      ..write(obj.tasks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FormConfigurationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
