import 'package:flutter_riverpod/legacy.dart';
import '../../data/models/limit_model.dart';
import '../../data/repositories/hive_repository.dart';
import '../../core/method_channel.dart';

final appDetailViewModelProvider = StateNotifierProvider.family<AppDetailViewModel, AppDetailState, String>(
  (ref, packageName) => AppDetailViewModel(packageName),
);

class AppDetailState {
  final AppLimit? currentLimit;
  final bool isSaving;
  final String? error;

  AppDetailState({this.currentLimit, this.isSaving = false, this.error});

  AppDetailState copyWith({AppLimit? currentLimit, bool? isSaving, String? error}) {
    return AppDetailState(
      currentLimit: currentLimit ?? this.currentLimit,
      isSaving: isSaving ?? this.isSaving,
      error: error ?? this.error,
    );
  }
}

class AppDetailViewModel extends StateNotifier<AppDetailState> {
  final String packageName;

  AppDetailViewModel(this.packageName) : super(AppDetailState()) {
    loadCurrentLimit();
  }

  void loadCurrentLimit() {
    final limit = HiveRepository.getAppLimit(packageName);
    state = state.copyWith(currentLimit: limit);
  }

  Future<void> saveLimit({
    required int limitMinutes,
    required String mode,
  }) async {
    state = state.copyWith(isSaving: true, error: null);

    try {
      final limit = AppLimit(
        packageName: packageName,
        limitMinutes: limitMinutes,
        mode: mode,
      );

      await HiveRepository.saveAppLimit(limit);
      await ScrollGuardChannel.setAppLimit(
        packageName: packageName,
        limitMinutes: limitMinutes,
        mode: mode,
      );

      state = state.copyWith(currentLimit: limit, isSaving: false);
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }
}