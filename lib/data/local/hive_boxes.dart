import 'package:hive_flutter/hive_flutter.dart';
import '../models/app_limit.dart';
import '../models/daily_usage.dart';

class HiveBoxes {
  static const String limitsBox = 'app_limits';
  static const String usageBox = 'daily_usage';
  static const String settingsBox = 'app_settings';

  static Future<void> init() async {
    // Register Adapters
    // Hive.registerAdapter(AppLimitAdapter());
    // Hive.registerAdapter(DailyUsageAdapter());
    // Hive.registerAdapter(AppUsageAdapter());

    // // Open Boxes
    // await Hive.openBox<AppLimit>(limitsBox);
    // await Hive.openBox<DailyUsage>(usageBox);
    // await Hive.openBox(settingsBox);
  }
}