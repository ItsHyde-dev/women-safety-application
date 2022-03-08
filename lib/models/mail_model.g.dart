// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mail_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MailAdapter extends TypeAdapter<Mail> {
  @override
  final int typeId = 1;

  @override
  Mail read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Mail()
      ..mail = fields[1] as String
      ..location = fields[2] as bool;
  }

  @override
  void write(BinaryWriter writer, Mail obj) {
    writer
      ..writeByte(2)
      ..writeByte(1)
      ..write(obj.mail)
      ..writeByte(2)
      ..write(obj.location);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MailAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
