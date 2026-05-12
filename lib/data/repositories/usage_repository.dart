import 'package:hive_flutter/hive_flutter.dart';
import '../models/usage_stats.dart';

class UsageRepository {
  static const String USAGE_BOX = 'usage_stats';

  Future<void> init() async {
    await Hive.openBox<UsageStats>(USAGE_BOX);
  }

  Future<void> saveUsage(String packageName, int minutes, DateTime date) async {
    final box = Hive.box<UsageStats>(USAGE_BOX);
    final key = '${packageName}_${date.toIso8601String().split('T')[0]}';

    final stats = UsageStats(
      packageName: packageName,
      totalTimeMinutes: minutes,
      date: date,
    );
    await box.put(key, stats);
  }

  Future<Map<String, int>> getWeeklyUsage() async {
    final box = Hive.box<UsageStats>(USAGE_BOX);
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final Map<String, int> weekly = {
      'Mon': 0, 'Tue': 0, 'Wed': 0, 'Thu': 0, 'Fri': 0, 'Sat': 0, 'Sun': 0,
    };

    for (var stats in box.values) {
      if (stats.date.isAfter(weekAgo)) {
        final dayName = _getDayName(stats.date);
        weekly[dayName] = (weekly[dayName] ?? 0) + stats.totalTimeMinutes;
      }
    }
    return weekly;
  }

  String _getDayName(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  Future<List<UsageStats>> getMostUsedApps({int limit = 5}) async {
    final box = Hive.box<UsageStats>(USAGE_BOX);
    final Map<String, int> totals = {};

    for (var stats in box.values) {
      totals[stats.packageName] = (totals[stats.packageName] ?? 0) + stats.totalTimeMinutes;
    }

    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(limit).map((e) => UsageStats(
          packageName: e.key,
          totalTimeMinutes: e.value,
          date: DateTime.now(),
        )).toList();
  }
}

final usageRepository = UsageRepository();