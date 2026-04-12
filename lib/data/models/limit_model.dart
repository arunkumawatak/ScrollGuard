// lib/data/models/limit_model.dart
class AppLimit {
  final String packageName;
  final int limitMinutes;
  final String mode; // Constants.notificationMode or blockMode
  final DateTime? startTime;
  final DateTime? endTime;

  AppLimit({
    required this.packageName,
    required this.limitMinutes,
    required this.mode,
    this.startTime,
    this.endTime,
  });

  Map<String, dynamic> toJson() => {
        'packageName': packageName,
        'limitMinutes': limitMinutes,
        'mode': mode,
        'startTime': startTime?.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
      };

  factory AppLimit.fromJson(Map<String, dynamic> json) => AppLimit(
        packageName: json['packageName'],
        limitMinutes: json['limitMinutes'],
        mode: json['mode'],
        startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
        endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      );
}