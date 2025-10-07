import 'package:card_mind/core/public/navigation_service.dart';
import 'package:card_mind/core/routes/routers.dart';
import 'package:card_mind/core/theme/app_theme.dart';
import 'package:card_mind/core/theme/theme_cubit.dart';
import 'package:card_mind/modules/dashboard/screen/dashboard_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder:
            (context, themeMode) => MaterialApp(
              builder: (context, child) {
                return ResponsiveBreakpoints.builder(
                  child: child!,
                  breakpoints: [
                    const Breakpoint(start: 0, end: 450, name: MOBILE),
                    const Breakpoint(start: 451, end: 800, name: TABLET),
                    const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                    const Breakpoint(
                      start: 1921,
                      end: double.infinity,
                      name: '4K',
                    ),
                  ],
                );
              },
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: themeMode,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              routes: Routers.routes,
              initialRoute: DashboardScreen.routeName,
              onGenerateRoute: Routers.generateRoute,
              navigatorKey: NavigationService.navigatorKey,
              navigatorObservers: [NavigationService.routeObserver],
            ),
      ),
    );
  }
}
