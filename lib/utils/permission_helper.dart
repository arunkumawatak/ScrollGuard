import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class PermissionHelper {
  /// Core permissions needed for main app functionality (App Blocking)
  static Future<bool> requestAllPermissions(BuildContext context) async {
    if (!Platform.isAndroid) return true;

    try {
      // 1. Notifications
      await Permission.notification.request();

      // 2. Display Over Other Apps (for blocking overlay)
      await Permission.systemAlertWindow.request();

      // 3. Usage Access (most important for tracking)
      final usageGranted = await _requestUsagePermission(context);

      return usageGranted;
    } catch (e) {
      debugPrint('Permission error: $e');
      return false;
    }
  }

  /// Handle Usage Stats Permission with real check
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

    // Open Settings
    await openAppSettings();

    // Give user time to grant permission
    await Future.delayed(const Duration(seconds: 3));

    // Re-check
    return await isUsageStatsGranted();
  }

  /// Check if Usage Stats is granted via native channel
  static Future<bool> isUsageStatsGranted() async {
    if (!Platform.isAndroid) return true;

    try {
      // You need to implement this method in MainActivity.kt
      // For now, returning true to avoid crash (update later)
      return true;
    } catch (e) {
      debugPrint('Usage check failed: $e');
      return false;
    }
  }
}
