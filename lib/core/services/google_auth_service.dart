import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

/// Service for handling Google Sign-In with Firebase Authentication
class GoogleAuthService {
  // Singleton pattern
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  /// Sign in with Google
  /// Returns UserCredential on success, null on failure/cancellation
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('🔐 [GoogleAuth] Starting Google Sign-In...');

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        print('🔐 [GoogleAuth] ❌ User canceled sign-in');
        return null;
      }

      print('🔐 [GoogleAuth] ✅ Google account selected: ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      print('🔐 [GoogleAuth] ✅ Got Google authentication tokens');

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      print('🔐 [GoogleAuth] ✅ Successfully signed in to Firebase');
      print('🔐 [GoogleAuth] User: ${userCredential.user?.displayName}');
      print('🔐 [GoogleAuth] Email: ${userCredential.user?.email}');
      print('🔐 [GoogleAuth] Photo: ${userCredential.user?.photoURL}');

      return userCredential;
    } catch (e, stackTrace) {
      print('🔐 [GoogleAuth] ❌ Error during sign-in: $e');
      if (kDebugMode) {
        print('Stack trace: $stackTrace');
      }
      return null;
    }
  }

  /// Sign out from both Google and Firebase
  Future<void> signOut() async {
    try {
      print('🔐 [GoogleAuth] Signing out...');

      // Sign out from Google
      await _googleSignIn.signOut();

      // Sign out from Firebase
      await _auth.signOut();

      print('🔐 [GoogleAuth] ✅ Successfully signed out');
    } catch (e) {
      print('🔐 [GoogleAuth] ❌ Error during sign-out: $e');
      rethrow;
    }
  }

  /// Get user info
  Map<String, dynamic>? getUserInfo() {
    final user = currentUser;
    if (user == null) return null;

    return {
      'uid': user.uid,
      'displayName': user.displayName,
      'email': user.email,
      'photoURL': user.photoURL,
      'emailVerified': user.emailVerified,
    };
  }
}
