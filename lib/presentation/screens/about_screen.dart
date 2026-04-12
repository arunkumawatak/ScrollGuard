import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ScrollGuard',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 32),
            Text(
              'ScrollGuard helps you reduce screen addiction by tracking usage, setting limits, and blocking apps when limits are reached.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 24),
            Text(
              '• Track daily app usage\n'
              '• Set time limits per app\n'
              '• Choose between notification or block mode\n'
              '• Full-screen blocking overlay\n'
              '• Clean & modern UI',
              style: TextStyle(fontSize: 16, height: 1.6),
            ),
            Spacer(),
            Center(
              child: Text(
                'Made with ❤️ to help you reclaim your time',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}