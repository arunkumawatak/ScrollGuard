// lib/presentation/widgets/custom_graph.dart
import 'package:flutter/material.dart';

class CustomBarGraph extends StatelessWidget {
  final Map<String, int> data;

  const CustomBarGraph({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final maxValue = data.values.isNotEmpty ? data.values.reduce((a, b) => a > b ? a : b) : 100;
    final days = data.keys.toList();

    return Container(
      height: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: days.map((day) {
                final value = data[day] ?? 0;
                final height = (value / maxValue) * 180;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('${value}min', style: const TextStyle(fontSize: 10)),
                    const SizedBox(height: 4),
                    Container(
                      width: 24,
                      height: height,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(day, style: const TextStyle(fontSize: 12)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}