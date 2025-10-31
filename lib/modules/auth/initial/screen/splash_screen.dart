import 'package:card_mind/init.dart';
import 'package:card_mind/modules/dashboard/screen/dashboard_screen.dart';
import 'package:card_mind/core/services/data_sync_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const String routeName = '/splash_screen';
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isSyncing = true;
  String _syncStatus = 'Đang khởi tạo...';

  @override
  void initState() {
    super.initState();
    _initializeAndSync();
  }

  /// Khởi tạo và đồng bộ dữ liệu trước khi vào Dashboard
  Future<void> _initializeAndSync() async {
    try {
      // Kiểm tra user đã đăng nhập chưa
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // User đã đăng nhập → Đồng bộ dữ liệu từ Firestore
        setState(() {
          _syncStatus = 'Đang đồng bộ dữ liệu...';
        });

        print('🔄 [Splash] User logged in, syncing data...');
        await DataSyncService().syncAllData();
        print('✅ [Splash] Sync completed');
      } else {
        // User chưa đăng nhập → Chỉ load local data
        setState(() {
          _syncStatus = 'Đang tải dữ liệu...';
        });
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
      setState(() {
        _syncStatus = 'Đang tải...';
      });

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
                  Icon(
                    Icons.credit_card,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 24),
                  // Loading spinner
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  const SizedBox(height: 16),
                  // Status text
                  Text(
                    _syncStatus,
                    style: TextStyle(
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
