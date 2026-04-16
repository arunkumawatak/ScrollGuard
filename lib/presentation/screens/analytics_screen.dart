import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:scrollguard/presentation/widgets/custom_graph.dart';

final analyticsViewModelProvider =
    StateNotifierProvider<AnalyticsViewModel, AnalyticsState>(
      (ref) => AnalyticsViewModel(),
    );

class AnalyticsState {
  final Map<String, int> dailyUsage;
  final bool isLoading;
  final String? error;

  AnalyticsState({
    this.dailyUsage = const {},
    this.isLoading = false,
    this.error,
  });

  AnalyticsState copyWith({
    Map<String, int>? dailyUsage,
    bool? isLoading,
    String? error,
  }) {
    return AnalyticsState(
      dailyUsage: dailyUsage ?? this.dailyUsage,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AnalyticsViewModel extends StateNotifier<AnalyticsState> {
  AnalyticsViewModel() : super(AnalyticsState()) {
    loadUsageData();
  }

  Future<void> loadUsageData() async {
    state = state.copyWith(isLoading: true);

    await Future.delayed(const Duration(milliseconds: 800));
    state = state.copyWith(
      dailyUsage: {
        'Mon': 45,
        'Tue': 67,
        'Wed': 32,
        'Thu': 89,
        'Fri': 55,
        'Sat': 120,
        'Sun': 78,
      },
      isLoading: false,
    );
  }
}

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsState = ref.watch(analyticsViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: analyticsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weekly Screen Time',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  CustomBarGraph(data: analyticsState.dailyUsage),
                  const SizedBox(height: 32),
                  const Text(
                    'Most Used Apps',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.smartphone),
                      title: const Text('Instagram'),
                      trailing: const Text('2h 34m'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
