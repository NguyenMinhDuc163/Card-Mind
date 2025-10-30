import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:card_mind/core/services/google_auth_service.dart';

/// Provider for managing authentication state
class AuthProvider extends ChangeNotifier {
  final GoogleAuthService _authService = GoogleAuthService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  /// Current user
  User? get user => _user;

  /// Loading state
  bool get isLoading => _isLoading;

  /// Error message
  String? get errorMessage => _errorMessage;

  /// Check if user is signed in
  bool get isSignedIn => _user != null;

  /// User display name
  String? get displayName => _user?.displayName;

  /// User email
  String? get email => _user?.email;

  /// User photo URL
  String? get photoURL => _user?.photoURL;

  AuthProvider() {
    _initializeAuth();
  }

  /// Initialize authentication and listen to auth state changes
  void _initializeAuth() {
    // Set initial user
    _user = _authService.currentUser;

    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      _errorMessage = null;
      notifyListeners();

      if (user != null) {
        print('🔐 [AuthProvider] User signed in: ${user.displayName}');
      } else {
        print('🔐 [AuthProvider] User signed out');
      }
    });
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userCredential = await _authService.signInWithGoogle();

      _isLoading = false;

      if (userCredential == null) {
        // User canceled or error occurred
        _errorMessage = 'Đăng nhập bị hủy';
        notifyListeners();
        return false;
      }

      // Success - user will be updated via authStateChanges stream
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Lỗi đăng nhập: $e';
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signOut();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Lỗi đăng xuất: $e';
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
