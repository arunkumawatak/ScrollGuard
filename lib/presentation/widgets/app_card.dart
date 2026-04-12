// lib/presentation/widgets/app_card.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../data/models/app_info.dart';
import '../../data/models/limit_model.dart';

class AppCard extends StatelessWidget {
  final AppInfo app;
  final AppLimit? limit;
  final VoidCallback onTap;

  const AppCard({
    super.key,
    required this.app,
    this.limit,
    required this.onTap,
  });
  Uint8List? _safeDecode(String? base64Str) {
    try {
      if (base64Str == null || base64Str.isEmpty) return null;

      // ✅ Remove invalid characters (VERY IMPORTANT)
      final cleaned = base64Str.replaceAll(RegExp(r'\s+'), '');

      return base64Decode(cleaned);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasLimit = limit != null;
    final iconBytes = _safeDecode(app.iconBase64);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: iconBytes != null
              ? Image.memory(
                  iconBytes,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                )
              : const Icon(Icons.android, size: 48),
        ),
        title: Text(
          app.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: hasLimit
            ? Text(
                '${limit!.limitMinutes} min • ${limit!.mode == "block" ? "Block" : "Notify"}',
                style: TextStyle(
                  color: limit!.mode == "block" ? Colors.red : Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              )
            : const Text('No limit set'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
