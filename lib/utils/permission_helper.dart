import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class PermissionHelper {
  static Future<bool> requestUsageStatsPermission() async {
    if (!Platform.isAndroid) return false;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt >= 30) {
      final status = await Permission.manageExternalStorage.status;
      if (!status.isGranted) {
        await openAppSettings();
        return false;
      }
    }
    return true;
  }

  static Future<bool> requestOverlayPermission() async {
    if (!Platform.isAndroid) return false;
    final status = await Permission.systemAlertWindow.status;
    if (!status.isGranted) {
      final result = await Permission.systemAlertWindow.request();
      return result.isGranted;
    }
    return true;
  }

  static Future<void> requestAllPermissions() async {
    await requestUsageStatsPermission();
    await requestOverlayPermission();
    await Permission.notification.request();
  }
} 