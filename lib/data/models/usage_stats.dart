// lib/data/models/usage_stats.dart
class UsageStats {
  final String packageName;
  final int totalTimeMinutes;
  final DateTime date;

  UsageStats({
    required this.packageName,
    required this.totalTimeMinutes,
    required this.date,
  });

  factory UsageStats.fromMap(Map<String, dynamic> map) {
    return UsageStats(
      packageName: map['packageName'] ?? '',
      totalTimeMinutes: map['totalTime'] ?? 0,
      date: DateTime.now(), // You can enhance this later
    );
  }

  Map<String, dynamic> toJson() => {
        'packageName': packageName,
        'totalTimeMinutes': totalTimeMinutes,
        'date': date.toIso8601String(),
      };
}