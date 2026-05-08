import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'constants.dart';

class ScrollGuardChannel {
  static const platform = MethodChannel(Constants.methodChannel);

  static Future<List<Map<String, dynamic>>> getInstalledApps() async {
    try {
      final List<dynamic> result = await platform.invokeMethod('getInstalledApps');
      return result.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      print('Error getting installed apps: $e');
      return [];
    }
  }

  static Future<void> startMonitoring() async {
    try {
      await platform.invokeMethod('startMonitoring');
    } catch (e) {
      if (kDebugMode) {
        print('Error starting monitoring: $e');
      }
    }
  }

  // 🔥 FIXED - Now returns bool (success/failure)
  static Future<bool> setAppLimit({
    required String packageName,
    required int limitMinutes,
    required String mode,
  }) async {
    try {
      final result = await platform.invokeMethod<bool>(
        'setAppLimit',
        {
          'packageName': packageName,
          'limitMinutes': limitMinutes,
          'mode': mode,
        },
      );
      return result ?? false;
    } catch (e) {
      print('Error setting limit: $e');
      return false;
    }
  }
}