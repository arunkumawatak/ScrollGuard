// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_usage.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyUsageAdapter extends TypeAdapter<DailyUsage> {
  @override
  final int typeId = 1;

  @override
  DailyUsage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyUsage(
      date: fields[0] as String,
      totalMinutes: fields[1] as int,
      apps: (fields[2] as List).cast<AppUsage>(),
    );
  }

  @override
  void write(BinaryWriter writer, DailyUsage obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.totalMinutes)
      ..writeByte(2)
      ..write(obj.apps);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyUsageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppUsageAdapter extends TypeAdapter<AppUsage> {
  @override
  final int typeId = 2;

  @override
  AppUsage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppUsage(
      packageName: fields[0] as String,
      appName: fields[1] as String,
      usageMinutes: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AppUsage obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.packageName)
      ..writeByte(1)
      ..write(obj.appName)
      ..writeByte(2)
      ..write(obj.usageMinutes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUsageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
