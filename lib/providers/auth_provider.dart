import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:card_mind/core/services/google_auth_service.dart';
import 'package:card_mind/core/services/data_sync_service.dart';

/// Provider for managing authentication state
class AuthProvider extends ChangeNotifier {
  final GoogleAuthService _authService = GoogleAuthService();

  User? _user;
  bool _isLoading = false;
  bool _isSyncing = false;
  String? _errorMessage;

  /// Current user
  User? get user => _user;

  /// Loading state
  bool get isLoading => _isLoading;

  /// Syncing state
  bool get isSyncing => _isSyncing;

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

    User? previousUser = _user;

    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) {
      final wasSignedOut = previousUser == null;
      final isNowSignedIn = user != null;

      _user = user;
      _errorMessage = null;
      notifyListeners();

      if (user != null) {
        print('🔐 [AuthProvider] User signed in: ${user.displayName}');

        // Nếu mới đăng nhập (transition từ null -> user), trigger sync
        if (wasSignedOut && isNowSignedIn) {
          print('🔐 [AuthProvider] New sign-in detected, starting sync...');
          _syncDataInBackground();
        }
      } else {
        print('🔐 [AuthProvider] User signed out');
      }

      previousUser = user;
    });
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userCredential = await _authService.signInWithGoogle();

      if (userCredential == null) {
        // User canceled or error occurred
        _isLoading = false;
        _errorMessage = 'Đăng nhập bị hủy';
        notifyListeners();
        return false;
      }

      // Success - user will be updated via authStateChanges stream
      // Auth state listener sẽ tự động gọi _syncDataInBackground()
      // GIỮ _isLoading = true để hiển thị loading cho đến khi sync xong (trong listener)
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Lỗi đăng nhập: $e';
      notifyListeners();
      return false;
    }
  }

  /// Đồng bộ dữ liệu ngầm (không block UI)
  void _syncDataInBackground() async {
    try {
      _isSyncing = true;
      notifyListeners();
      print('🔄 [AuthProvider] Starting background sync...');

      await DataSyncService().syncAllData();
      print('✅ [AuthProvider] Background sync completed');

      // Tắt cả loading và syncing
      _isLoading = false;
      _isSyncing = false;
      // Trigger refresh UI sau khi sync xong
      notifyListeners();
      print('✅ [AuthProvider] UI refresh triggered after sync');
    } catch (error) {
      _isLoading = false;
      _isSyncing = false;
      notifyListeners();
      print('🔄 [AuthProvider] Background sync failed: $error');
      // Không hiển thị lỗi cho user, sync sẽ retry lần sau
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Clear local data and load sample data FIRST (before auth state changes)
      print('🔄 [AuthProvider] Clearing local data and loading sample...');
      await DataSyncService().clearLocalDataAndLoadSample();
      print('✅ [AuthProvider] Sample data loaded');

      // 2. THEN sign out from Firebase (this will trigger auth state listeners)
      print('🔄 [AuthProvider] Signing out from Firebase...');
      await _authService.signOut();
      print('✅ [AuthProvider] Firebase sign out completed');

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
