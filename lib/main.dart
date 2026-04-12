import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ ADD THIS
import 'data/repositories/hive_repository.dart';
import 'presentation/screens/splash_screen.dart';
import 'core/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await HiveRepository.init();

  runApp(
    const ProviderScope(   // ✅ THIS FIXES YOUR ERROR
      child: ScrollGuardApp(),
    ),
  );
}

class ScrollGuardApp extends StatelessWidget {
  const ScrollGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScrollGuard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}