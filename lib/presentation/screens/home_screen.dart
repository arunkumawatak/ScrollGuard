import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollguard/presentation/widgets/app_card.dart';

import '../../core/method_channel.dart';
import '../viewmodels/app_list_viewmodel.dart';

import 'app_detail_screen.dart';
import 'analytics_screen.dart';
import 'profile_screen.dart';
import 'about_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScrollGuardChannel.startMonitoring();
    });
  }
//bottom bar list
  final List<Widget> _screens = [
    const AppListTab(),
    const AnalyticsScreen(),
    const ProfileScreen(),
    const AboutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ScrollGuard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(appListViewModelProvider.notifier).loadInstalledApps(),
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'Apps'),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
        ],
      ),
    );
  }
}

class AppListTab extends ConsumerWidget {
  const AppListTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appListState = ref.watch(appListViewModelProvider);

    if (appListState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (appListState.error != null) {
      return Center(
        child: Text(
          'Error: ${appListState.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (appListState.apps.isEmpty) {
      return const Center(child: Text('No apps found'));
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(appListViewModelProvider.notifier).loadInstalledApps(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: appListState.apps.length,
        itemBuilder: (context, index) {
          final app = appListState.apps[index];
          final limit = ref
              .read(appListViewModelProvider.notifier)
              .getLimitForApp(app.packageName);

          return AppCard(
            app: app,
            limit: limit,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AppDetailScreen(app: app)),
              ).then((_) {
                ref.read(appListViewModelProvider.notifier).loadInstalledApps();
              });
            },
          );
        },
      ),
    );
  }
}
