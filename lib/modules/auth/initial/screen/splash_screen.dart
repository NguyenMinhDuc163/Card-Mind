import 'package:card_mind/init.dart';
import 'package:card_mind/modules/dashboard/screen/dashboard_screen.dart';
import 'package:card_mind/core/services/data_sync_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const String routeName = '/splash_screen';
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isSyncing = true;
  String _syncStatus = '';

  @override
  void initState() {
    super.initState();
    // Set initial status after first frame to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _syncStatus = 'splash_screen.initializing'.tr();
        });
      }
    });
    _initializeAndSync();
  }

  /// Khởi tạo và đồng bộ dữ liệu trước khi vào Dashboard
  Future<void> _initializeAndSync() async {
    try {
      // Đợi context ready
      await Future.delayed(const Duration(milliseconds: 100));

      // Kiểm tra user đã đăng nhập chưa
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // User đã đăng nhập → Đồng bộ dữ liệu từ Firestore
        if (mounted) {
          setState(() {
            _syncStatus = 'splash_screen.syncing_data'.tr();
          });
        }

        print('🔄 [Splash] User logged in, syncing data...');
        await DataSyncService().syncAllData();
        print('✅ [Splash] Sync completed');
      } else {
        // User chưa đăng nhập → Chỉ load local data
        if (mounted) {
          setState(() {
            _syncStatus = 'splash_screen.loading_data'.tr();
          });
        }
        print('ℹ️ [Splash] User not logged in, skip sync');
      }

      // Đợi tối thiểu 500ms để hiển thị splash screen
      await Future.delayed(const Duration(milliseconds: 500));

      // Chuyển sang Dashboard
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(DashboardScreen.routeName);
      }
    } catch (e) {
      print('❌ [Splash] Error during initialization: $e');

      // Vẫn cho vào app dù sync thất bại (offline-first)
      if (mounted) {
        setState(() {
          _syncStatus = 'common.loading'.tr();
        });
      }

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.of(context).pushReplacementNamed(DashboardScreen.routeName);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lavenderColor,
      body: Stack(
        children: [
          Positioned.fill(child: Container(color: AppColors.lavenderColor)),
          // Loading indicator và status
          if (_isSyncing)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo hoặc icon
                  const Icon(
                    Icons.credit_card,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 24),
                  // Loading spinner
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  const SizedBox(height: 16),
                  // Status text
                  Text(
                    _syncStatus,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
