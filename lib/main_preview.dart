import 'package:card_mind/core/public/navigation_service.dart';
import 'package:card_mind/core/routes/routers.dart';
import 'package:card_mind/core/theme/app_theme.dart';
import 'package:card_mind/core/theme/theme_cubit.dart';
import 'package:card_mind/core/theme/theme_service.dart';
import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await EasyLocalization.ensureInitialized();
  await ThemeService.init();

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
            child: const MyApp(),
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
        builder: (context, themeMode) => MaterialApp(
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
          initialRoute: '/',
          navigatorKey: NavigationService.navigatorKey,
          navigatorObservers: [NavigationService.routeObserver],
        ),
      ),
    );
  }
}
