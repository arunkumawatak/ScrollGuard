import 'package:flutter/services.dart';
import 'constants.dart';

class ScrollGuardChannel {
  static const platform = MethodChannel(Constants.methodChannel);

  static Future<List<Map<String, dynamic>>> getInstalledApps() async {
    try {
      final List<dynamic> result = await platform.invokeMethod(
        'getInstalledApps',
      );
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
      print('Error starting monitoring: $e');
    }
  }

  static Future<void> setAppLimit({
    required String packageName,
    required int limitMinutes,
    required String mode,
  }) async {
    try {
      await platform.invokeMethod('setAppLimit', {
        'packageName': packageName,
        'limitMinutes': limitMinutes,
        'mode': mode,
      });
    } catch (e) {
      print('Error setting limit: $e');
    }
  }
}