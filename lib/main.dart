import 'package:card_mind/core/app_bloc_observer.dart';
import 'package:card_mind/core/helpers/local_storage_helper.dart';
import 'package:card_mind/core/services/sample_data_service.dart';
import 'package:card_mind/core/services/notification_service.dart';
import 'package:card_mind/providers/provider_setup.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/theme/theme_service.dart';
import 'modules/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase cho tất cả platforms (Android, Web)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Bloc.observer = AppBlocObserver();
  await EasyLocalization.ensureInitialized();
  await ThemeService.init();
  await Hive.initFlutter();
  await LocalStorageHelper.initLocalStorageHelper();

  // Khởi tạo notification service
  await NotificationService().initialize();

  // Request notification permissions
  await NotificationService().requestPermissions();

  // Force enable notifications if disabled (for development/testing)
  // TODO: Remove this in production, let user control via settings
  await NotificationService().setNotificationsEnabled(true);

  // Schedule daily reminders (sáng, trưa, tối)
  // Note: Mỗi lần mở app sẽ reschedule để đảm bảo notifications không bị mất
  await NotificationService().scheduleDailyReminders();

  // Reschedule tất cả review notifications khi app mở lại
  // Điều này đảm bảo notifications không bị mất khi app ở background
  await NotificationService().rescheduleAllReviewNotifications();

  // Khởi tạo sample data nếu cần
  await SampleDataService.initializeSampleData();

  Locale defaultLocale = const Locale('en', 'US');

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('vi', 'VN')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      startLocale: defaultLocale,
      child: MultiProvider(
        providers: ProviderSetup.getProviders(),
        child: const App(),
      ),
    ),
  );
}
