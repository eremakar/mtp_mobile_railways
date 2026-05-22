// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'form_task_field.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FormTaskFieldAdapter extends TypeAdapter<FormTaskField> {
  @override
  final int typeId = 12;

  @override
  FormTaskField read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FormTaskField(
      name: fields[0] as String,
      type: fields[1] as String,
      label: fields[2] as String,
      placeholder: fields[3] as String?,
      widthPercent: fields[4] as int?,
      lines: fields[5] as int?,
      answerOptions: (fields[6] as List?)?.cast<String>(),
      fileTypes: (fields[7] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, FormTaskField obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.label)
      ..writeByte(3)
      ..write(obj.placeholder)
      ..writeByte(4)
      ..write(obj.widthPercent)
      ..writeByte(5)
      ..write(obj.lines)
      ..writeByte(6)
      ..write(obj.answerOptions)
      ..writeByte(7)
      ..write(obj.fileTypes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FormTaskFieldAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
