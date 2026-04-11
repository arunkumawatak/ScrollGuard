import 'package:hive/hive.dart';


@HiveType(typeId: 0)
class AppLimit extends HiveObject {
  @HiveField(0)
  final String packageName;

  @HiveField(1)
  final String appName;

  @HiveField(2)
  final int maxMinutes;           // e.g., 60 for 1 hour

  @HiveField(3)
  final bool isNotificationMode;  // true = notify, false = block

  @HiveField(4)
  final DateTime? startTime;      // optional allowed window

  @HiveField(5)
  final DateTime? endTime;        // optional allowed window

  @HiveField(6)
  final bool isActive;

  AppLimit({
    required this.packageName,
    required this.appName,
    required this.maxMinutes,
    this.isNotificationMode = true,
    this.startTime,
    this.endTime,
    this.isActive = true,
  });

  // Copy with method for easy updates
  AppLimit copyWith({
    int? maxMinutes,
    bool? isNotificationMode,
    DateTime? startTime,
    DateTime? endTime,
    bool? isActive,
  }) {
    return AppLimit(
      packageName: packageName,
      appName: appName,
      maxMinutes: maxMinutes ?? this.maxMinutes,
      isNotificationMode: isNotificationMode ?? this.isNotificationMode,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isActive: isActive ?? this.isActive,
    );
  }
}