import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants.dart';
import '../models/limit_model.dart';

class HiveRepository {
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map<dynamic, dynamic>>(Constants.hiveUserBox);
    await Hive.openBox<Map<dynamic, dynamic>>(Constants.hiveLimitsBox);
    await Hive.openBox<Map<dynamic, dynamic>>(Constants.hiveUsageBox);
  }

  static Box<Map> get userBox => Hive.box(Constants.hiveUserBox);

  static Box<Map> get limitsBox => Hive.box(Constants.hiveLimitsBox);

  static Future<void> saveAppLimit(AppLimit limit) async {
    await limitsBox.put(limit.packageName, limit.toJson());
  }

  static AppLimit? getAppLimit(String packageName) {
    final data = limitsBox.get(packageName);
    if (data == null) return null;
    return AppLimit.fromJson(Map<String, dynamic>.from(data));
  }

  static List<AppLimit> getAllLimits() {
    return limitsBox.values
        .map((e) => AppLimit.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Box<Map> get usageBox => Hive.box(Constants.hiveUsageBox);

  static Future<void> clearAll() async {
    await userBox.clear();
    await limitsBox.clear();
    await usageBox.clear();
  }
}
