// lib/presentation/viewmodels/auth_viewmodel.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/services/firebase_service.dart';
import '../../data/repositories/hive_repository.dart';

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>(
  (ref) => AuthViewModel(),
);

class AuthState {
  final bool isLoading;
  final User? user;
  final String? error;

  AuthState({this.isLoading = false, this.user, this.error});

  AuthState copyWith({bool? isLoading, User? user, String? error}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState> {
  AuthViewModel() : super(AuthState()) {
    _checkCurrentUser();
  }

  final FirebaseService _firebaseService = FirebaseService();

  void _checkCurrentUser() {
    final user = _firebaseService.currentUser;
    if (user != null) {
      _saveUserToHive(user);
      state = state.copyWith(user: user);
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _firebaseService.signInWithGoogle();

      if (user != null) {
        await _saveUserToHive(user);
        state = state.copyWith(user: user, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: "Sign in was cancelled or failed",
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Failed to sign in: ${e.toString()}",
      );
    }
  }

  Future<void> _saveUserToHive(User user) async {
    try {
      final userData = {
        'uid': user.uid,
        'name': user.displayName ?? 'User',
        'email': user.email ?? '',
        'photoUrl': user.photoURL ?? '',
      };
      await HiveRepository.userBox.put('currentUser', userData);
    } catch (e) {
      print('Error saving user to Hive: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseService.signOut();
      await HiveRepository.clearAll();
      state = AuthState();
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  // Getters for user info
  String? get userName => HiveRepository.userBox.get('currentUser')?['name'];
  String? get userEmail => HiveRepository.userBox.get('currentUser')?['email'];
  String? get photoUrl => HiveRepository.userBox.get('currentUser')?['photoUrl'];
}