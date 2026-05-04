import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import '../../utils/permission_helper.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    if (_initialized) return;
    _initialized = true;

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    final authState = ref.read(authViewModelProvider);

    // ✅ Handle permissions once
    final allGranted =
        await PermissionHelper.requestAllPermissions(context);

    if (!mounted) return;

    // ✅ Navigate
    if (authState.user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }

    // ✅ Show warning
    if (!allGranted && mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Some permissions are missing. App blocking may not work fully.',
            ),
            duration: Duration(seconds: 4),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Text('Reclaim your focus'),
            SizedBox(height: 40),
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Initializing...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}