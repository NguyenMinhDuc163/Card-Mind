import 'package:card_mind/core/app_bloc_observer.dart';
import 'package:card_mind/core/helpers/local_storage_helper.dart';
import 'package:card_mind/core/public/navigation_service.dart';
import 'package:card_mind/core/routes/routers.dart';
import 'package:card_mind/core/theme/app_theme.dart';
import 'package:card_mind/core/theme/theme_cubit.dart';
import 'package:card_mind/core/theme/theme_service.dart';
import 'package:card_mind/core/services/sample_data_service.dart';
import 'package:card_mind/core/services/notification_service.dart';
import 'package:card_mind/providers/provider_setup.dart';
import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'modules/dashboard/screen/dashboard_screen.dart';

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
    DevicePreview(
      enabled: true,
      builder:
          (context) => EasyLocalization(
            supportedLocales: const [Locale('en', 'US'), Locale('vi', 'VN')],
            path: 'assets/translations',
            fallbackLocale: const Locale('en', 'US'),
            startLocale: defaultLocale,
            child: MultiProvider(providers: ProviderSetup.getProviders(), child: const MyApp()),
          ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder:
            (context, themeMode) => MaterialApp(
              builder: (context, child) {
                return ResponsiveBreakpoints.builder(
                  child: DevicePreview.appBuilder(context, child),
                  breakpoints: [
                    const Breakpoint(start: 0, end: 450, name: MOBILE),
                    const Breakpoint(start: 451, end: 800, name: TABLET),
                    const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                    const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
                  ],
                );
              },
              debugShowCheckedModeBanner: false,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: DevicePreview.locale(context),
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: themeMode,
              onGenerateRoute: Routers.generateRoute,
              routes: Routers.routes,
              initialRoute: DashboardScreen.routeName,
              navigatorKey: NavigationService.navigatorKey,
              navigatorObservers: [NavigationService.routeObserver],
            ),
      ),
    );
  }
}
