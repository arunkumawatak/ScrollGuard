// lib/data/services/firebase_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Use the singleton instance (required in v7+)
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Google Sign In (Updated for google_sign_in ^7.x)
  Future<User?> signInWithGoogle() async {
    try {
      // Ensure initialization (important for new version)
      await _googleSignIn.initialize();

      // New method: authenticate() instead of signIn()
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();

      if (googleUser == null) {
        print('Google Sign-In cancelled by user');
        return null;
      }

      // Get authentication details (idToken is usually sufficient for Firebase)
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        // accessToken is optional in most cases for Firebase Auth
        // accessToken: googleAuth.accessToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print('Google Sign-In error: $e');
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();   // or disconnect() if you want to revoke
      await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;
}