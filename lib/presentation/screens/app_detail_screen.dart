import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/app_info.dart';
import '../../data/models/limit_model.dart';
import '../../data/repositories/hive_repository.dart';
import '../../core/method_channel.dart';
import '../../core/constants.dart';

class AppDetailScreen extends ConsumerStatefulWidget {
  final AppInfo app;

  const AppDetailScreen({super.key, required this.app});

  @override
  ConsumerState<AppDetailScreen> createState() => _AppDetailScreenState();
}

class _AppDetailScreenState extends ConsumerState<AppDetailScreen> {
  String selectedMode = Constants.notificationMode;
  int selectedLimit = 60;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  Uint8List? _decodeIcon(String? base64Str) {
    try {
      if (base64Str == null || base64Str.isEmpty) return null;
      return base64Decode(base64Str);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final existingLimit = HiveRepository.getAppLimit(widget.app.packageName);

    if (existingLimit != null) {
      selectedMode = existingLimit.mode;
      selectedLimit = existingLimit.limitMinutes;
    }
    final iconBytes = _decodeIcon(widget.app.iconBase64);
    return Scaffold(
      appBar: AppBar(title: Text(widget.app.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: iconBytes != null
                        ? Image.memory(iconBytes, width: 100, height: 100)
                        : const Icon(Icons.android, size: 100),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.app.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.app.packageName,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            const Text(
              "Set Daily Limit",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
//show minutes here
            Wrap(
              spacing: 8,
              children: Constants.predefinedLimits.map((minutes) {
                return ChoiceChip(
                  label: Text('$minutes min'),
                  selected: selectedLimit == minutes,
                  onSelected: (selected) {
                    if (selected) setState(() => selectedLimit = minutes);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            const Text(
              "Mode",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: "notification", label: Text("Notify")),
                ButtonSegment(value: "block", label: Text("Block")),
              ],
              selected: {selectedMode},
              onSelectionChanged: (set) =>
                  setState(() => selectedMode = set.first),
            ),

            const SizedBox(height: 32),

            ElevatedButton.icon(
              onPressed: () async {
                final limit = AppLimit(
                  packageName: widget.app.packageName,
                  limitMinutes: selectedLimit,
                  mode: selectedMode,
                  startTime: startTime != null
                      ? DateTime(2024, 1, 1, startTime!.hour, startTime!.minute)
                      : null,
                  endTime: endTime != null
                      ? DateTime(2024, 1, 1, endTime!.hour, endTime!.minute)
                      : null,
                );

                await HiveRepository.saveAppLimit(limit);
                await ScrollGuardChannel.setAppLimit(
                  packageName: widget.app.packageName,
                  limitMinutes: selectedLimit,
                  mode: selectedMode,
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Limit saved successfully!')),
                  );
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.save),
              label: const Text("Save Limit"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
