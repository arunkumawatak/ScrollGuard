// lib/presentation/widgets/limit_card.dart
import 'package:flutter/material.dart';
import '../../data/models/limit_model.dart';

class LimitCard extends StatelessWidget {
  final AppLimit limit;
  final VoidCallback onEdit;

  const LimitCard({
    super.key,
    required this.limit,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isBlockMode = limit.mode == "block";

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isBlockMode ? Icons.block : Icons.notifications_active,
              color: isBlockMode ? Colors.red : Colors.orange,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${limit.limitMinutes} minutes per day',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isBlockMode ? 'Block Mode' : 'Notification Mode',
                    style: TextStyle(
                      color: isBlockMode ? Colors.red : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }
}