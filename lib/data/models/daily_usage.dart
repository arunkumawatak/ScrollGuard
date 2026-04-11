import 'package:hive/hive.dart';


@HiveType(typeId: 1)
class DailyUsage extends HiveObject {
  @HiveField(0)
  final String date;                    // "2026-04-11"

  @HiveField(1)
  final int totalMinutes;

  @HiveField(2)
  final List<AppUsage> apps;

  DailyUsage({
    required this.date,
    required this.totalMinutes,
    required this.apps,
  });
}

@HiveType(typeId: 2)
class AppUsage extends HiveObject {
  @HiveField(0)
  final String packageName;

  @HiveField(1)
  final String appName;

  @HiveField(2)
  final int usageMinutes;

  AppUsage({
    required this.packageName,
    required this.appName,
    required this.usageMinutes,
  });
}