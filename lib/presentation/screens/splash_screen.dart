import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import '../../utils/permission_helper.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!context.mounted) return;

      if (authState.user != null) {
        // Logged in user → Handle Permissions
        await _handlePermissionsAndNavigate(context);
      } else {
        // Not logged in → Go to Login
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      }
    });

    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_outlined, size: 90, color: Colors.deepPurple),
            SizedBox(height: 24),
            Text(
              'ScrollGuard',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Reclaim your focus', style: TextStyle(fontSize: 16)),
            SizedBox(height: 40),
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Initializing...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePermissionsAndNavigate(BuildContext context) async {
    // First show loading for a moment
    await Future.delayed(const Duration(milliseconds: 800));

    if (!context.mounted) return;

    // Request permissions
    final allGranted = await PermissionHelper.requestAllPermissions(context);

    if (!context.mounted) return;

    // Navigate to Home regardless (user can use limited features)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );

    // Optional: Show snackbar if permissions were not fully granted
    if (!allGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Some permissions are missing. App blocking may not work fully.'),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }
}