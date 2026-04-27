// import 'package:flutter_riverpod/legacy.dart';
// import '../../core/method_channel.dart';
// import '../../data/models/app_info.dart';
// import '../../data/repositories/hive_repository.dart';
// import '../../data/models/limit_model.dart';

// final appListViewModelProvider = StateNotifierProvider<AppListViewModel, AppListState>(
//   (ref) => AppListViewModel(),
// );

// class AppListState {
//   final List<AppInfo> apps;
//   final bool isLoading;
//   final String? error;

//   AppListState({this.apps = const [], this.isLoading = false, this.error});

//   AppListState copyWith({List<AppInfo>? apps, bool? isLoading, String? error}) {
//     return AppListState(
//       apps: apps ?? this.apps,
//       isLoading: isLoading ?? this.isLoading,
//       error: error ?? this.error,
//     );
//   }
// }

// class AppListViewModel extends StateNotifier<AppListState> {
//   AppListViewModel() : super(AppListState()) {
//     loadInstalledApps();
//   }

//   Future<void> loadInstalledApps() async {
//     state = state.copyWith(isLoading: true, error: null);
//     try {
//       final rawApps = await ScrollGuardChannel.getInstalledApps();
//       final apps = rawApps.map((e) => AppInfo.fromMap(e)).toList();

//       apps.sort((a, b) {
//         final hasLimitA = HiveRepository.getAppLimit(a.packageName) != null;
//         final hasLimitB = HiveRepository.getAppLimit(b.packageName) != null;
//         if (hasLimitA && !hasLimitB) return -1;
//         if (!hasLimitA && hasLimitB) return 1;
//         return a.name.compareTo(b.name);
//       });

//       state = state.copyWith(apps: apps, isLoading: false);
//     } catch (e) {
//       state = state.copyWith(isLoading: false, error: e.toString());
//     }
//   }

//   AppLimit? getLimitForApp(String packageName) {
//     return HiveRepository.getAppLimit(packageName);
//   }
//  }



import 'package:flutter_riverpod/legacy.dart';
import '../../core/method_channel.dart';
import '../../data/models/app_info.dart';
import '../../data/repositories/hive_repository.dart';
import '../../data/models/limit_model.dart';

final appListViewModelProvider = StateNotifierProvider<AppListViewModel, AppListState>(
  (ref) => AppListViewModel(),
);

class AppListState {
  final List<AppInfo> apps;
  final bool isLoading;
  final String? error;

  AppListState({this.apps = const [], this.isLoading = false, this.error});

  AppListState copyWith({List<AppInfo>? apps, bool? isLoading, String? error}) {
    return AppListState(
      apps: apps ?? this.apps,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AppListViewModel extends StateNotifier<AppListState> {
  AppListViewModel() : super(AppListState()) {
    loadInstalledApps();
  }

  Future<void> loadInstalledApps() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final rawApps = await ScrollGuardChannel.getInstalledApps();
      final apps = rawApps.map((e) => AppInfo.fromMap(e)).toList();

      apps.sort((a, b) {
        final hasLimitA = HiveRepository.getAppLimit(a.packageName) != null;
        final hasLimitB = HiveRepository.getAppLimit(b.packageName) != null;
        if (hasLimitA && !hasLimitB) return -1;
        if (!hasLimitA && hasLimitB) return 1;
        return a.name.compareTo(b.name);
      });

      state = state.copyWith(apps: apps, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  AppLimit? getLimitForApp(String packageName) {
    return HiveRepository.getAppLimit(packageName);
  }
}