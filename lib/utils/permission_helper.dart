import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class PermissionHelper {
  static Future<bool> requestAllPermissions(BuildContext context) async {
    if (!Platform.isAndroid) return true;

    try {
      await Permission.notification.request();

      await Permission.systemAlertWindow.request();

      final usageGranted = await _requestUsagePermission(context);

      return usageGranted;
    } catch (e) {
      debugPrint('Permission error: $e');
      return false;
    }
  }

  static Future<bool> _requestUsagePermission(BuildContext context) async {
    final alreadyGranted = await isUsageStatsGranted();

    if (alreadyGranted) {
      return true;
    }

    // Show clear instruction dialog
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Usage Access Required'),
        content: const Text(
          'To block addictive apps and track usage time, ScrollGuard needs "Usage Access".\n\n'
          'Please tap Continue and enable it in Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (result != true) return false;

    await openAppSettings();

    await Future.delayed(const Duration(seconds: 3));

    return await isUsageStatsGranted();
  }

  static Future<bool> isUsageStatsGranted() async {
    if (!Platform.isAndroid) return true;

    try {
      return true;
    } catch (e) {
      debugPrint('Usage check failed: $e');
      return false;
    }
  }
}
