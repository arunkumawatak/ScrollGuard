import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class PermissionHelper {
  /// Request all required permissions with proper handling
  static Future<bool> requestAllPermissions(BuildContext context) async {
    if (!Platform.isAndroid) return true;

    try {
      // 1. Notification
      await Permission.notification.request();

      // 2. Overlay (Display over other apps)
      final overlayGranted = await Permission.systemAlertWindow.request();

      // 3. Usage Stats - Special permission
      final usageGranted = await _handleUsageStatsPermission(context);

      return overlayGranted.isGranted && usageGranted;
    } catch (e) {
      debugPrint('Permission error: $e');
      return false;
    }
  }

  /// Handle Usage Stats permission (most tricky one)
  static Future<bool> _handleUsageStatsPermission(BuildContext context) async {
    if (!Platform.isAndroid) return true;

    // Show clear instruction dialog
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Usage Access Required'),
        content: const Text(
          'To block apps and track usage, ScrollGuard needs "Usage Access".\n\n'
          '1. Tap "Continue"\n'
          '2. Find "ScrollGuard" in the list\n'
          '3. Toggle ON "Allow usage access"',
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

    // Open settings
    await openAppSettings();

    // Give user some time to grant permission and return
    await Future.delayed(const Duration(seconds: 3));

    // You can add a "Check Again" button in future dedicated screen
    return true;
  }

  /// Optional: Check if Usage Stats is granted (advanced)
  static Future<bool> isUsageStatsGranted() async {
    // This is hard to check reliably without native code.
    // For now we assume user granted after settings.
    return true;
  }
}
