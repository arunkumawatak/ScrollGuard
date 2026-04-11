// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_limit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppLimitAdapter extends TypeAdapter<AppLimit> {
  @override
  final int typeId = 0;

  @override
  AppLimit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppLimit(
      packageName: fields[0] as String,
      appName: fields[1] as String,
      maxMinutes: fields[2] as int,
      isNotificationMode: fields[3] as bool,
      startTime: fields[4] as DateTime?,
      endTime: fields[5] as DateTime?,
      isActive: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppLimit obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.packageName)
      ..writeByte(1)
      ..write(obj.appName)
      ..writeByte(2)
      ..write(obj.maxMinutes)
      ..writeByte(3)
      ..write(obj.isNotificationMode)
      ..writeByte(4)
      ..write(obj.startTime)
      ..writeByte(5)
      ..write(obj.endTime)
      ..writeByte(6)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppLimitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
