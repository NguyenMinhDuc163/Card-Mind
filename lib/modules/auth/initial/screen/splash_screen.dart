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
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _syncStatus = 'splash_screen.initializing'.tr();
        });
      }
    });
    _initializeAndSync();
  }

  
  Future<void> _initializeAndSync() async {
    try {
      
      await Future.delayed(const Duration(milliseconds: 100));

      
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        
        if (mounted) {
          setState(() {
            _syncStatus = 'splash_screen.syncing_data'.tr();
          });
        }

        print('🔄 [Splash] User logged in, syncing data...');
        await DataSyncService().syncAllData();
        print('✅ [Splash] Sync completed');
      } else {
        
        if (mounted) {
          setState(() {
            _syncStatus = 'splash_screen.loading_data'.tr();
          });
        }
        print('ℹ️ [Splash] User not logged in, skip sync');
      }

      
      await Future.delayed(const Duration(milliseconds: 500));

      
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(DashboardScreen.routeName);
      }
    } catch (e) {
      print('❌ [Splash] Error during initialization: $e');

      
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
          
          if (_isSyncing)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  const Icon(
                    Icons.credit_card,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 24),
                  
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  const SizedBox(height: 16),
                  
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
