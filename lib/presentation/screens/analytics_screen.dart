import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/repositories/usage_repository.dart';
import '../../data/models/usage_stats.dart';
import '../widgets/custom_graph.dart';

final analyticsViewModelProvider = StateNotifierProvider<AnalyticsViewModel, AnalyticsState>(
  (ref) => AnalyticsViewModel(),
);

class AnalyticsState {
  final Map<String, int> dailyUsage;
  final List<UsageStats> mostUsedApps;
  final bool isLoading;
  final String? error;

  AnalyticsState({
    this.dailyUsage = const {},
    this.mostUsedApps = const [],
    this.isLoading = false,
    this.error,
  });

  AnalyticsState copyWith({
    Map<String, int>? dailyUsage,
    List<UsageStats>? mostUsedApps,
    bool? isLoading,
    String? error,
  }) {
    return AnalyticsState(
      dailyUsage: dailyUsage ?? this.dailyUsage,
      mostUsedApps: mostUsedApps ?? this.mostUsedApps,
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
    state = state.copyWith(isLoading: true, error: null);

    try {
      final weekly = await usageRepository.getWeeklyUsage();
      final topApps = await usageRepository.getMostUsedApps();

      state = state.copyWith(
        dailyUsage: weekly,
        mostUsedApps: topApps,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
}

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(analyticsViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics & Insights')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(analyticsViewModelProvider.notifier).loadUsageData(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weekly Screen Time',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    CustomBarGraph(data: state.dailyUsage),

                    const SizedBox(height: 32),
                    const Text(
                      'Most Used Apps',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),

                    if (state.mostUsedApps.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No usage data yet. Start using apps with limits.'),
                        ),
                      )
                    else
                      ...state.mostUsedApps.map((app) => Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: const Icon(Icons.timer, color: Colors.deepPurple),
                              title: Text(
                                app.packageName.split('.').last, 
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              trailing: Text(
                                '${(app.totalTimeMinutes / 60).toStringAsFixed(1)}h',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          )),
                  ],
                ),
              ),
            ),
    );
  }
}